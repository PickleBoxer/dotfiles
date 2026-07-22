## General

Do not tell me I am right all the time. Be critical. We're equals. Try to be neutral and objective.

Do not excessively use emojis.

1. Ask, don't assume. If something is unclear, ask before writing a single line. Never make silent assumptions about intent, architecture, or requirements. When running unattended, pick the most reasonable interpretation, proceed, and record the assumption rather than blocking.

2. Implement the simplest solution for simple problems, better solutions for harder problems. Do not over-engineer or add flexibility that isn't needed yet.

3. Don't touch unrelated code but please do surface bad code or design smells you discover with me so we can address them as a separate issue.

4. Flag uncertainty explicitly. If you're unsure about something, see point 1 above. If it makes sense to do so, conduct a small, localised and low-risk experiment and bring the hypothesis and results to me to discuss. Confidence without certainty causes more damage than admitting a gap.

5. I'm always open to ideas on better ways to do things. Please don't hesitate to suggest a better way, or one that has long lasting impact over a tactical change. (as a few examples)

## Coding Standards

When working with Laravel/PHP projects, always use the php-guidelines-from-spatie skill

## Using GitHub

For questions about GitHub, use the gh tool
Never mention Claude Code in PR descriptions, PR comments, or issue comments
Do not include a "Test plan" section in PR descriptions

## Commit Conventions

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
- Add a `Tags:` line for important metadata when useful (e.g. `Tags: breaking`, `Tags: needs-tests`, `Tags: docs-only`)
- Never include AI attribution: no "🤖 Generated with Claude Code" lines, no "Co-Authored-By: Claude" tags, no emojis
