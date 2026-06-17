#!/bin/bash

# Read JSON input once
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')

# Format context percentage
if [ -n "$ctx_raw" ]; then
  ctx_pct=$(printf '%.0f' "$ctx_raw")
  if [ "$ctx_pct" -ge 60 ]; then
    ctx_color='\033[01;31m' # red
  elif [ "$ctx_pct" -ge 40 ]; then
    ctx_color='\033[01;33m' # yellow
  else
    ctx_color='\033[01;32m' # green
  fi
  ctx_part=$(printf ' | ctx: %b%s%%\033[00m' "$ctx_color" "$ctx_pct")
else
  ctx_part=""
fi

# Git branch from filesystem (fallback to worktree branch from JSON)
git_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
  || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null \
  || echo "$input" | jq -r '.worktree.branch // empty')

# Build location segment: prefer repo owner/name, fall back to basename of cwd
if [ -n "$repo" ]; then
  location="$repo"
elif [ -n "$git_branch" ]; then
  location=$(basename "$cwd")
else
  location="$cwd"
fi

# Model label (shortened for brevity)
model_part=$(printf '\033[00;35m%s\033[00m' "$model")

# context-mode segment: prefer the globally installed `context-mode` binary; if it is
# not on PATH (the status line may run with a minimal env), fall back to the plugin's
# CLI bundle, resolving the latest version so it survives upgrades. Feed it the same JSON.
cm_part=""
cm_status=""
cm_bin=$(command -v context-mode 2>/dev/null || ls "$HOME"/.npm-packages/bin/context-mode 2>/dev/null | head -1)
if [ -n "$cm_bin" ]; then
  cm_status=$(printf '%s' "$input" | "$cm_bin" statusline 2>/dev/null)
fi
if [ -z "$cm_status" ]; then
  cm_cli=$(ls -d "$HOME"/.claude/plugins/cache/context-mode/context-mode/*/cli.bundle.mjs 2>/dev/null | sort -V | tail -1)
  if [ -n "$cm_cli" ] && command -v node >/dev/null 2>&1; then
    cm_status=$(printf '%s' "$input" | node "$cm_cli" statusline 2>/dev/null)
  fi
fi
[ -n "$cm_status" ] && cm_part=$(printf ' | %s' "$cm_status")

# Assemble output
if [ -n "$git_branch" ]; then
  printf '%s \033[01;36m%s\033[00m \033[00;37m(%s)\033[00m%s%s' \
    "$model_part" "$location" "$git_branch" "$ctx_part" "$cm_part"
else
  printf '%s \033[01;36m%s\033[00m%s%s' \
    "$model_part" "$location" "$ctx_part" "$cm_part"
fi
