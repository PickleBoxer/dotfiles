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
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

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

branch_icon='⎇'

# Build git repo info segment (colored cyan)
if [ -n "$repo" ] && [ -n "$git_branch" ]; then
  git_part=$(printf ' \033[01;36m%s\033[00m \033[00;37m(%s %s)\033[00m' "$repo" "$branch_icon" "$git_branch")
elif [ -n "$repo" ]; then
  git_part=$(printf ' \033[01;36m%s\033[00m' "$repo")
elif [ -n "$git_branch" ]; then
  git_part=$(printf ' \033[00;37m(%s %s)\033[00m' "$branch_icon" "$git_branch")
else
  git_part=""
fi

# Model label
model_part=$(printf '\033[00;35m%s\033[00m' "$model")

# Format remaining time as "Xd Yh", "Xh Ym", or "Xm"
format_remaining() {
  local diff=$1

  if [ "$diff" -le 0 ]; then
    printf 'resetting...'
    return
  fi

  local mins=$(( diff / 60 ))
  local hrs=$(( mins / 60 ))
  local days=$(( hrs / 24 ))

  if [ "$days" -gt 0 ]; then
    printf '%dd %dh' "$days" "$(( hrs % 24 ))"
  elif [ "$hrs" -gt 0 ]; then
    printf '%dh %dm' "$hrs" "$(( mins % 60 ))"
  else
    printf '%dm' "$mins"
  fi
}

# Build a rate-limit segment: " | <label>: XX% (remaining)"
build_rate_part() {
  local label=$1
  local pct=$2
  local resets_at=$3

  [ -z "$pct" ] && return

  local used_int
  used_int=$(printf '%.0f' "$pct")

  local rate_color
  if [ "$used_int" -ge 60 ]; then
    rate_color='\033[01;31m' # red
  elif [ "$used_int" -ge 40 ]; then
    rate_color='\033[01;33m' # yellow
  else
    rate_color='\033[01;32m' # green
  fi

  local remaining_part=""
  if [ -n "$resets_at" ]; then
    local now diff
    now=$(date +%s)
    diff=$(( resets_at - now ))
    remaining_part=$(printf ' (%s)' "$(format_remaining "$diff")")
  fi

  printf ' | %s: %b%s%%\033[00m%s' "$label" "$rate_color" "$used_int" "$remaining_part"
}

five_hour_part=$(build_rate_part "5h" "$five_hour_pct" "$five_hour_resets")
seven_day_part=$(build_rate_part "7d" "$seven_day_pct" "$seven_day_resets")

# Single line: model | git repo info | context used | 5h rate limit | 7d rate limit
printf '%s%s%s%s%s' "$model_part" "$git_part" "$ctx_part" "$five_hour_part" "$seven_day_part"
