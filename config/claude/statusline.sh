#!/bin/bash

# Read JSON input once
input=$(cat)

# Extract values from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
ctx_raw=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

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

# ── 5-hour rate limit bar: RGB gradient, full blocks only ──
BAR_WIDTH=20
RESET=$'\033[0m'
rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }

rate_line2=""
if [ -n "$five_hour_pct" ]; then
  used_int=$(printf '%.0f' "$five_hour_pct")

  # Round to nearest block
  filled=$(( (used_int * BAR_WIDTH + 50) / 100 ))

  bar=""
  for (( i=0; i<BAR_WIDTH; i++ )); do
    pos=$(( i * 100 / (BAR_WIDTH - 1) ))

    if [ "$pos" -le 50 ]; then
      r=$(( 0 + 220 * pos / 50 ))
      g=200
      b=$(( 80 - 80 * pos / 50 ))
    else
      adj=$(( pos - 50 ))
      r=220
      g=$(( 200 - 160 * adj / 50 ))
      b=$(( 0 + 20 * adj / 50 ))
    fi

    if [ "$i" -lt "$filled" ]; then
      bar="${bar}$(rgb $r $g $b)█"
    else
      bar="${bar}${RESET}░"
    fi
  done
  bar="${bar}${RESET}"

  rate_line2=$(printf '5h: %s %s%%' "$bar" "$used_int")
fi

# Line 1: model | git repo info | context used
printf '%s%s%s' "$model_part" "$git_part" "$ctx_part"

# Line 2: rate limit bar (only when data is available)
if [ -n "$rate_line2" ]; then
  printf '\n%s' "$rate_line2"
fi
