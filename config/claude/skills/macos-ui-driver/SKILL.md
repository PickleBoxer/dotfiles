---
name: macos-ui-driver
description: Drive and visually verify a REAL, already-built native macOS app (not the iOS Simulator) using AppleScript/System Events for clicks and `screencapture` for visual confirmation. Use this whenever a task needs to confirm that a menu, toggle, tooltip, disabled state, or any other interactive UI behavior actually looks and works right in the live app - not just that it compiles or renders in a static SwiftUI #Preview. Also use this after XcodeBuildMCP's build_run_macos has launched an app and the user wants it interacted with, not just confirmed running. Trigger proactively whenever reviewing SwiftUI/AppKit changes involving context menus, status-bar/menu-bar extras, tooltips, or conditional enabled/disabled controls.
---

# Driving a Real macOS App

SwiftUI `#Preview` and a green build both stop short of proving a menu opens correctly, a
tooltip renders, or a control is actually grayed out the way the code intends. This skill
scripts the real, running app with AppleScript (`osascript` + System Events) for interaction
and `screencapture` for verification, reading the resulting screenshots back with the Read tool.

The one thing this skill is stricter about than almost anything else: **never capture more of
the screen than the target app's own window.** A user's desktop routinely has confidential
content on it - other apps, browser tabs with client/work data, unrelated terminal sessions -
and a full-screen or full-display capture drags all of it into the conversation permanently.
This isn't a theoretical risk; it happens the first time you reach for a quick full-screen
shot instead of scoping the capture. Treat every screenshot as scoped-or-stop, never
scoped-or-guess-wider.

## 1. Check prerequisites, every time

Two macOS permissions gate this entirely: Accessibility (for clicking/querying UI) and Screen
Recording (for `screencapture`). Both are granted to whichever **GUI app hosts the current
shell** - not to `osascript` or `screencapture` themselves, since macOS's TCC privacy system
attributes the permission to the responsible parent process. Find it first:

```bash
ps -o pid,ppid,comm -p $$
# then walk up ppid with: ps -o comm= -p <pid>
# until you hit a .app bundle, e.g. Ghostty.app, Terminal.app, iTerm.app, WarpTerminal.app
```

Test Screen Recording:

```bash
screencapture -x /tmp/perm_test.png && ls -la /tmp/perm_test.png && rm -f /tmp/perm_test.png
```

A real screenshot is hundreds of KB at minimum. A missing/near-empty file or an error means
it's not granted.

Test Accessibility:

```bash
osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'
```

An app name comes back if granted; an error (often -1743) means it isn't.

If either is missing, stop and tell the user exactly which permission is missing and which app
(identified above) needs it granted, via System Settings → Privacy & Security → Accessibility /
Screen Recording. Flag explicitly that Screen Recording changes usually require restarting the
granted app to take effect - and if that app is the very terminal hosting this Claude Code
session, restarting it will kill the session. Don't restart it for the user; let them choose
when.

## 2. Launch the target app

Use XcodeBuildMCP's `build_run_macos` (builds from the session's configured scheme/project and
launches it as a real process) or `launch_mac_app` if it's already built. Note the reported
`bundleId`/`processId`.

For System Events, address the app by its **process name** (usually the product name, e.g.
`"DDock"`), not the bundle ID. If unsure:

```bash
osascript -e 'tell application "System Events" to get name of every process whose bundle identifier is "com.example.App"'
```

## 3. Find and click UI elements - prefer accessibility queries over blind coordinates

Coordinate clicks break the moment layout shifts by a pixel. Addressing elements by their
accessible label is far more durable, and it's exactly what SwiftUI already gives you for free
via `.accessibilityLabel()` and button titles.

List windows:

```applescript
tell application "System Events" to tell process "AppName" to get name of every window
```

**Menu-bar-extra-only apps** (no window until interacted with) keep their status item in
`menu bar 2` (the "extras" bar). There can be several unrelated apps' items there, so confirm
which one first:

```applescript
tell application "System Events" to tell process "AppName" to get description of every menu bar item of menu bar 2
```

Then `click menu bar item 1 of menu bar 2` (adjust the index once confirmed).

**Finding a specific control**: walk the whole element tree and filter by its label, rather than
guessing where it is on screen:

```applescript
tell application "System Events"
    tell process "AppName"
        set allElems to entire contents of window 1
        repeat with e in allElems
            try
                if description of e is "the exact accessibility label" then
                    click e
                    exit repeat
                end if
            end try
        end repeat
    end tell
end tell
```

`click e` (the accessibility action on a found element) is more robust than a raw coordinate
click. Fall back to coordinates only when you have no element reference: get `position of` +
`size of` a known element or window, aim at its center, then
`tell application "System Events" to click at {x, y}`.

**Known rough edges**, found by working through this in practice rather than assumed:

- `right click at {x, y}` is not reliably supported by System Events in every configuration (it
  can throw "Can't make right into type UI element"). If the UI exposes an explicit trigger for
  the same menu - an "options"/"more"/ellipsis button that opens the identical content - click
  that instead of trying to simulate a right-click.
- A transient `NSMenu` popup (SwiftUI `Menu`/`.contextMenu` content) may not expose its own
  position/size through `menus of process`, `entire contents`, or a `windows` count, even while
  it's genuinely open and visible on screen. Don't treat this as a bug in your query - it's a
  real limitation of scripting transient popups. See the capture section below for how to handle
  it safely.

## 4. Capture and read the screen

1. Get the target's exact bounds via accessibility (`position of` + `size of` a `window` or
   element) **before** capturing anything.
2. Capture only that region:
   ```bash
   screencapture -x -R<x>,<y>,<w>,<h> /tmp/name.png
   ```
   On multi-monitor setups, accessibility positions can be negative (e.g. `-1437`) for displays
   arranged above/left of the main display - `-R` accepts these as ordinary global coordinates,
   no special-casing needed.
3. **If you can't determine precise bounds** (e.g. the transient-menu limitation above) and the
   only way forward is a wider guess: stop and ask the user before widening the region, rather
   than silently guessing. This is a real tradeoff between "get the verification" and "risk
   catching something you shouldn't" - it's the user's call, not a default to assume.
4. Read the PNG with the Read tool - it renders images directly.
5. Delete the file immediately after reading it (`rm -f /tmp/name.png`). Don't accumulate
   screenshots on disk across steps.
6. If a capture ever includes anything beyond the intended target - another app's window,
   browser content, unrelated UI - say so plainly when reporting results, and delete the file.
   Don't silently proceed as if it were clean, and don't repeat back the unrelated content
   beyond what's needed to flag that it happened.

## 5. Clean up afterward

Press Escape to close anything left open:

```bash
osascript -e 'tell application "System Events" to key code 53'
```

Then consider whether the launched app instance should be quit or left running - ask if it's
unclear, since it might be something the user wants to keep using rather than a throwaway test
run.
