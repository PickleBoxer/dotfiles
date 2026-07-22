# Commit Conventions

Follow Conventional Commits for every commit message drafted in any project. Format: `<type>(<scope>): <title>`, optionally followed by a body, optionally followed by a `Tags:` line.

Commit types:

- `feat`: Add, adjust, or remove a feature
- `fix`: Fix a bug from a previous `feat` commit
- `refactor`: Rewrite/restructure code without behavior change
- `perf`: Performance improvements
- `style`: Code style changes (formatting, whitespace)
- `test`: Add or correct tests
- `docs`: Documentation changes only
- `build`: Build tools, dependencies, packages
- `ops`: Infrastructure, deployment, CI/CD
- `chore`: Miscellaneous tasks

Rules:

- Use imperative, present tense: "add" not "added"
- Do not capitalize the first letter of the title
- No period at the end of the title
- Scopes are mandatory: `feat(api):`, `fix(auth):`, `docs(readme):`
- Simple, brief title (max ~50 chars); use the body for a more detailed "why"/"how" explanation on larger commits
- Structure the body with bullet points (`*`) when listing multiple changes or details
- Add a `Tags:` line for important metadata when useful (e.g. `Tags: breaking`, `Tags: needs-tests`, `Tags: docs-only`)
- Never include AI attribution: no "🤖 Generated with Claude Code" lines, no "Co-Authored-By: Claude" tags, no emojis

## Workflow

- Never run `git commit` yourself, in any repository, even when asked to "commit" or "create a commit"
- Instead, draft the commit message following the conventions above and present it in the chat
- Wait for the message to be copied and committed manually
- This applies to every repo, not just the one currently open
