---
name: chunk-done
description: Finish a chunk of work in wize-back. Runs Pint, the 4 PHPStan configs and the changed tests in one script (with --full after the last chunk, also each touched container's suite and affected tests elsewhere), then updates the plan files, drafts the commit message and stops. It replaces running those checks by hand, so during a chunk run only the test being iterated on. Use after every implementation chunk in wize-back, or when asked to "run the checks", "verify the chunk" or "wrap up this chunk".
---

# chunk-done

Closes one chunk of planned work in wize-back. Follow the steps in order.

## 1. Run the checks

The script is the only verification step for the chunk. While working, run just the test you're iterating on; don't run Pint, PHPStan, the changed tests or container suites first, and don't rerun them by hand after the script passes.

From anywhere inside wize-back:

```bash
bash ~/.claude/skills/chunk-done/scripts/check-chunk.sh
```

- Default (per chunk): Pint, the 4 PHPStan configs and the changed test files, on PHP files changed since `HEAD` plus untracked ones. No container suites.
- `--full`: run once after the last chunk, before the PR. Base defaults to the branch point with `origin/master`, so it covers the whole branch. Adds each touched container's suite and the tests outside those containers that reference a changed class.
- `--base <ref>`: compare against another ref, for example the previous commit.
- `--dry-run`: list the files, containers and affected tests without running anything.
- Container names as arguments override the detected ones, for example `check-chunk.sh --full Shipping Observability`.
- Pint fixes files in place, so re-read any file you plan to edit again.

The script prints one line per step and, on failure, the last 40 lines of output. Exit code 0 means every step passed.

If a step fails, fix the cause and rerun. Don't weaken a test or add a `@phpstan-ignore` to get to green without saying so. If the cause is outside the chunk (a flaky test, an unrelated failure), report it with its output instead of working around it.

The script never runs the whole repo's suite or whole-repo `phpstan.neon` (it runs out of memory locally). CI covers both.

## 2. Update the plan

If the task has a plan folder (usually `.scratch/<task>/` at the workspace root):

- README: add the chunk to the progress section as "in the tree, awaiting commit", mark the previous chunk "committed" if `git log` shows it, and record any agreed deviation with its date and reason.
- todo: tick only items this chunk fully finishes. Strike through an item that was dropped or changed, with the date and the reason next to it.

## 3. Draft the commit message

Follow commit-conventions: `<type>(<scope>): <title>`, a `-` bullet body, no AI attribution. Never run `git commit`.

## 4. Report and stop

Reply with:

- what changed (short bullets);
- anything the user should know before committing (staged deletions, behavior changes, deferred follow-ups);
- the check results: test counts per step, Pint, PHPStan;
- what was ticked in todo;
- the commit message.

Then wait for the commit before starting the next chunk.

## Shell gotchas (if running commands by hand)

- zsh doesn't split `$FILES` on spaces; build an array, `FILES=(${(f)"$(...)"})`, or use bash.
- zsh treats `echo =====` as a command lookup; use `echo '---'`.
- Strip ANSI codes before grepping test output: `sed 's/\x1b\[[0-9;]*[A-Za-z]//g'`.
- PHP, Composer, Artisan and Pint run only in the container: `docker exec backend <command>`, from `project/`.
