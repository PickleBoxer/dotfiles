# Working Style

How to work through planned tasks, in every project.

## Before starting

- If the task has a plan folder (README, todo, SPEC), read the README's progress and deviations first, then todo, with SPEC as reference.
- Check `git status`. If the previous chunk is still uncommitted, wait for my commit before starting the next one.
- Don't start the next task or create a branch until I say so.

## Chunks

- Work in small chunks, each one coherent commit. If a planned task is bigger than that, split it and say how before starting.
- After each chunk:
  - run the project's checks (in wize-back: the `chunk-done` skill, which replaces running them by hand; during the chunk run only the test being iterated on);
  - update the plan README's progress and tick what's done in todo;
  - give the commit message (see commit-conventions);
  - stop and wait.
- Report results as they are: test counts, failures with their output, anything skipped.

## Never without asking

- Don't commit, push, merge, rebase or cherry-pick unless I explicitly tell you to in this session. Otherwise give me the message or the commands.
- Ask before any write to Linear, New Relic or another external service, and list the exact change first.
- A change mentioned during analysis is a design question: give options with a recommendation, then wait.

## Decisions

- Ask, with a recommendation, when a choice touches shared code or infra, or changes the plan. Otherwise pick the conventional option and say which.
- Record agreed deviations from the spec in the plan README, with the date and the reason.
