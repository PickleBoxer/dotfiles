#!/bin/bash

# Read JSON input once
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

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

# Build git repo info segment (colored cyan)
if [ -n "$repo" ] && [ -n "$git_branch" ]; then
  git_part=$(printf ' \033[01;36m%s\033[00m \033[00;37m(%s)\033[00m' "$repo" "$git_branch")
elif [ -n "$repo" ]; then
  git_part=$(printf ' \033[01;36m%s\033[00m' "$repo")
elif [ -n "$git_branch" ]; then
  git_part=$(printf ' \033[00;37m(%s)\033[00m' "$git_branch")
else
  git_part=""
fi

# Model label
model_part=$(printf '\033[00;35m%s\033[00m' "$model")

# Format 5-hour rate limit percentage
five_hour_part=""
if [ -n "$five_hour_pct" ]; then
  used_int=$(printf '%.0f' "$five_hour_pct")
  if [ "$used_int" -ge 60 ]; then
    rate_color='\033[01;31m' # red
  elif [ "$used_int" -ge 40 ]; then
    rate_color='\033[01;33m' # yellow
  else
    rate_color='\033[01;32m' # green
  fi

  reset_part=""
  if [ -n "$five_hour_resets" ]; then
    now=$(date +%s)
    diff=$(( five_hour_resets - now ))
    if [ "$diff" -gt 0 ]; then
      mins=$(( diff / 60 ))
      hrs=$(( mins / 60 ))
      rem=$(( mins % 60 ))
      if [ "$hrs" -gt 0 ]; then
        reset_part=$(printf ' resets in %dh %dm' "$hrs" "$rem")
      else
        reset_part=$(printf ' resets in %dm' "$mins")
      fi
    else
      reset_part=" resetting..."
    fi
  fi

  five_hour_part=$(printf ' | 5h: %b%s%%\033[00m%s' "$rate_color" "$used_int" "$reset_part")
fi

# Single line: model | git repo info | context used | 5h rate limit
printf '%s%s%s%s' "$model_part" "$git_part" "$ctx_part" "$five_hour_part"
