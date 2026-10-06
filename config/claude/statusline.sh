#!/bin/bash

# Model, context, limits, repo and branch are shown by the burn and drift mods.
# This only lists the skills used this session, parsed from the transcript.
transcript_path=$(jq -r '.transcript_path // empty')
[ -f "$transcript_path" ] || exit 0

skills=$(jq -rs '
  [ .[]?.message?.content[]?
    | select(type == "object" and .type == "tool_use" and (.name | test("skill"; "i")))
    | (.input.skill // .input.command // .input.name // .input.skill_name // "")
    | select(. != "")
    | split(" ")[0]
    | sub("^/"; "")
  ]
  | unique
  | join(", ")
' "$transcript_path" 2>/dev/null)

[ -n "$skills" ] && printf '\033[38;5;214mSkills: %s\033[00m' "$skills"
exit 0
