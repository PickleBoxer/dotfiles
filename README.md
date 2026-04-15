# My dotfiles

![Terminal](images/terminal.jpeg)

Personal dotfiles with modern shell tooling, optimized for Laravel/PHP development. Features fast startup times, smart directory navigation, and modern CLI tools.

## Key Features

- **Starship Prompt** - Fast, cross-shell prompt with Powerline style (configured via `config/starship.toml`)
- **Version-Controlled Skills & Agents** - All Claude Code skills and agents synced via dotfiles
- **Fast Tools** - fnm, zoxide, ripgrep, bat, eza (all Rust-based for speed)
- **Nerd Fonts** - Installed automatically via Brewfile for perfect icon support
- **One Command Install** - `bin/install` sets up everything including Claude Code

---

## Quick Start

### 1. SSH Key (if you don't have one yet)

```bash
curl -fsSL https://raw.githubusercontent.com/PickleBoxer/dotfiles/main/ssh.sh | sh -s your@email.com
```

This generates an `ed25519` SSH key, configures `~/.ssh/config`, adds it to the keychain, and copies the public key to your clipboard so you can paste it into [GitHub SSH settings](https://github.com/settings/ssh/new).

### 2. Install dotfiles

```bash
git clone git@github.com:PickleBoxer/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bin/install
```

---

## What's Included

### Shell & Prompt

- **Starship** - Fast, minimal cross-shell prompt (replaces Oh My Zsh)
- **zoxide** - Smart directory jumping based on frecency
- **fzf** - Fuzzy finder for files and history
- **direnv** - Automatic environment variables per directory

### Modern CLI Tools

- **fnm** - Fast Node.js version manager
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls replacement with icons
- **ripgrep** - Fast grep alternative
- **fd** - Fast find alternative
- **git-delta** - Better git diffs
- **jq** - JSON processor and formatter
- **yq** - YAML processor and formatter
- **bottom** - Modern system monitor

### Development Tools

- **PHP** - Latest version via Homebrew
- **Composer** - Dependency manager via Homebrew
- **Node.js** - LTS version managed via fnm
- **DDEV** - Local development environment (Docker-based, used for all projects)
- **Laravel Valet** - Lightweight alternative for local development (optional, see below)

### QuickLook Plugins

Instant file previews in Finder: code files, markdown, JSON, CSV, patches, and archives.

---

## How It Works

### Symlinked Files

The installation creates symlinks from your home directory to the dotfiles repository. This allows you to version control your configuration while keeping files in their expected locations.

| Symlink Location                      | Points To                                             | Purpose                                                |
| ------------------------------------- | ----------------------------------------------------- | ------------------------------------------------------ |
| `~/.zshrc`                            | `~/.dotfiles/home/.zshrc`                             | Main Zsh configuration (Starship prompt, no Oh My Zsh) |
| `~/.gitconfig`                        | `~/.dotfiles/home/.gitconfig`                         | Git configuration with delta diff viewer               |
| `~/.global-gitignore`                 | `~/.dotfiles/home/.global-gitignore`                  | Global Git ignore patterns                             |
| `~/.mackup.cfg`                       | `~/.dotfiles/macos/.mackup.cfg`                       | Mackup backup configuration                            |
| `~/.claude/skills`                    | `~/.dotfiles/config/claude/skills/`                   | All Claude Code skills (version-controlled)            |
| `~/.claude/agents`                    | `~/.dotfiles/config/claude/agents/`                   | All Claude Code agents (version-controlled)            |
| `~/.claude/CLAUDE.md`                 | `~/.dotfiles/config/claude/CLAUDE.md`                 | Claude Code configuration                              |
| `~/.claude/laravel-php-guidelines.md` | `~/.dotfiles/config/claude/laravel-php-guidelines.md` | Laravel coding standards                               |
| `~/.claude/settings.json`             | `~/.dotfiles/config/claude/settings.json`             | Claude Code settings                                   |

### Sourced Files

These files are loaded by `.zshrc` but remain in the dotfiles directory:

- `home/.aliases` - Shell command aliases
- `home/.functions` - Custom shell functions
- `home/.exports` - Environment variables

### Starship Prompt

The prompt is configured in `config/starship.toml` and uses a Powerline-style agnoster look:

**Features:**

- Powerline arrows for segment separators
- Git branch and status indicators
- Error color on non-zero exit codes
- Requires Nerd Font with powerline glyphs

**Git Status Symbols:**

- `!` - Modified files
- `+` - Staged changes
- `?` - Untracked files
- `✘` - Conflicted files

### Switching Prompts

Both shell configs are kept for easy switching:

| File                  | Description                                         |
| --------------------- | --------------------------------------------------- |
| `home/.zshrc`         | **Active** — Starship prompt, no Oh My Zsh overhead |
| `home/.zshrc.ohmyzsh` | Backup — Oh My Zsh with custom agnoster theme       |

To switch back to Oh My Zsh:

```bash
cd ~/.dotfiles
mv home/.zshrc home/.zshrc.starship
mv home/.zshrc.ohmyzsh home/.zshrc
ln -sf ~/.dotfiles/home/.zshrc ~/.zshrc && exec zsh
```

---

## Daily Usage

### Smart Navigation

```bash
z dotfiles          # Jump to frequently used directories
zi                  # Interactive directory picker
Ctrl+R              # Fuzzy search command history
Ctrl+T              # Fuzzy find files
Alt+C               # Fuzzy change directory
```

### Laravel/PHP Shortcuts

```bash
a                   # php artisan
p                   # Run Pest/PHPUnit tests
c                   # composer
mfs                 # php artisan migrate:fresh --seed
nah                 # git reset --hard; git clean -df
```

### Data Processing

```bash
# JSON processing with jq
curl api.github.com/users/PickleBoxer | jq
cat composer.json | jq '.require'
php artisan tinker --execute="echo json_encode(User::first());" | jq

# YAML processing with yq
yq '.jobs' .github/workflows/ci.yml
yq -o json docker-compose.yml

# System monitoring
btm                 # Modern system monitor (aliased from top/htop)
```

### Maintenance Commands

```bash
bin/update          # Update all packages and tools
```

### Syncing Changes from Upstream (freekmurze/dotfiles)

This repo is forked from [freekmurze/dotfiles](https://github.com/freekmurze/dotfiles). To check and selectively apply upstream changes:

**1. Check what is new:**

```bash
cd ~/.dotfiles
git fetch upstream
git log upstream-synced..upstream/main --format="%h %ci %s"
```

Empty output means you are fully up to date.

**2. Inspect a specific commit:**

```bash
git show <commit-hash> --stat
```

**3. Cherry-pick files you want from upstream:**

```bash
git checkout upstream/main -- path/to/file-or-folder
```

**4. Mark as synced after applying changes:**

```bash
git tag -f upstream-synced upstream/main
```

---

## Version Management

### Node.js (via fnm)

```bash
fnm install --lts     # Install latest LTS
fnm use lts-latest    # Use latest LTS
fnm install 20        # Install specific version
fnm use 20            # Switch to specific version
fnm list              # Show installed versions
```

### PHP & Composer (via Homebrew)

```bash
brew upgrade php      # Update PHP to latest
brew upgrade composer # Update Composer
```

### Local Development: DDEV vs Valet

This setup uses **DDEV** (Docker-based) as the primary local development environment. It manages PHP versions, databases, and services per-project with zero global config.

**Laravel Valet** is available as a lightweight alternative — faster to start, no Docker required, but shares a single global PHP version. To install:

```bash
composer global require laravel/valet
valet install
```

Both can coexist. DDEV is preferred for projects that need specific PHP versions or services (MySQL, Redis, etc.).

---

## Package Management

All Homebrew packages are declared in `config/Brewfile`. To add a new tool:

```bash
echo 'brew "neovim"' >> ~/.dotfiles/config/Brewfile
brew bundle --file=~/.dotfiles/config/Brewfile
```

**Complete package list:**

- **Core**: node, php, composer, pkg-config, wget, httpie, ncdu, hub, ack, doctl, 1password-cli, git-secret, imagemagick, yarn, ghostscript, mackup
- **Modern CLI**: zoxide, bat, eza, ripgrep, fd, git-delta, fnm, fzf, direnv, jq, yq, bottom, zsh-autosuggestions
- **Fonts**: font-meslo-lg-nerd-font (powerline icons and modern glyphs)
- **QuickLook**: qlcolorcode, qlstephen, qlmarkdown, quicklook-json, qlprettypatch, quicklook-csv, betterzip, suspicious-package
- **PHP Extensions**: imagick, memcached, xdebug, redis
- **Global npm**: agent-browser
- **Global Composer**: laravel/envoy, spatie/phpunit-watcher

---

## DDEV SSH Commit Signing

The install script automatically sets up one-time host configuration so all DDEV containers inherit your git identity and SSH commit signing:

- Symlinks `~/.gitconfig` into `~/.ddev/homeadditions/` so every container picks up your signing config
- Symlinks `~/.ssh/id_ed25519.pub` into the container's `~/.ssh/` (git needs the public key file present)
- Adds your SSH key to the host agent

After each reboot, run once to forward the agent into containers:

```bash
ddev auth ssh
```

If you also need custom SSH host entries inside containers (e.g. a self-hosted GitLab), add them to `~/.ddev/homeadditions/.ssh/config.d/custom.conf`.

---

## Claude Code Integration

### Quick Install (Standalone)

Install just Claude Code without the full dotfiles:

```bash
curl -fsSL https://raw.githubusercontent.com/PickleBoxer/dotfiles/main/bin/install-claude-code | bash
```

### What's Included

- **Claude Code CLI** - Installed via Homebrew
- **Custom configuration** - CLAUDE.md with coding guidelines, laravel-php-guidelines.md
- **Version-controlled skills** - Entire `~/.claude/skills` directory symlinked to dotfiles
- **Version-controlled agents** - Entire `~/.claude/agents` directory symlinked to dotfiles

### Skills (Version Controlled)

All skills are stored in `config/claude/skills/` and version-controlled with your dotfiles. When you run the installer on a new Mac, all skills are immediately available.

**Custom Skills:**

- `ray-skill` - Ray debugging integration
- `fix-github-issue` - GitHub issue automation
- `convert-issue-to-discussion` - GitHub workflow helpers

**Community Skills:**

- `vercel-labs/agent-skills` - Web design guidelines and React best practices
- `anthropics/skills` - Frontend design and skill creation tools
- `vercel-labs/agent-browser` - Browser automation
- `expo/skills` - React Native with Expo
- `callstackincubator/agent-skills` - React Native performance
- `coreyhaines31/marketingskills` - Copywriting and programmatic SEO
- `copy-editing` - Marketing copy editing
- `copywriting` - Marketing copywriting
- `frontend-design` - Frontend design patterns
- `pdf` - PDF manipulation
- `seo-audit` - SEO auditing
- `web-design-guidelines` - Web design best practices

### Adding New Skills

```bash
# Install a new skill (adds directly to your dotfiles)
npx skills add <owner/repo>

# Commit to version control
cd ~/.dotfiles
git add config/claude/skills/
git commit -m "Add new skill"
git push
```

Browse more skills at [skills.sh](https://skills.sh)

### Agents (Version Controlled)

All custom agents are stored in `config/claude/agents/` and version-controlled with your dotfiles. When you run the installer on a new Mac, all agents are immediately available.

**Custom Agents:**

- `laravel-simplifier` - Simplifies and refines PHP/Laravel code for clarity and maintainability
- `laravel-debugger` - Diagnoses and fixes issues in Laravel applications
- `laravel-feature-builder` - Implements new features in Laravel applications
- `task-planner` - Breaks down complex tasks into actionable steps

---

## Customization

### Personal Aliases & Functions

Create custom configurations that won't be committed:

```bash
mkdir -p ~/.dotfiles-custom/shell
vim ~/.dotfiles-custom/shell/.aliases
```

These files are automatically loaded by `.zshrc` if they exist.

### Project-Specific Variables

Use `direnv` for automatic environment loading:

```bash
cd my-project
echo 'export DEBUG=true' > .envrc
direnv allow
```

Variables load when you enter the directory and unload when you leave.

---

## Post-Installation

1. **Restore settings** (optional): Run `mackup restore` if you have backups

2. **Migrate history** (upgrading only): Run `migration/migrate-z-to-zoxide.sh` if you have `~/.z`

---

## Tool Comparisons

| Old Tool        | New Tool | Why Better                              |
| --------------- | -------- | --------------------------------------- |
| z.sh / autojump | zoxide   | Smarter frecency algorithm, Rust speed  |
| nvm             | fnm      | 40x faster, simpler, Rust-based         |
| cat             | bat      | Syntax highlighting, git integration    |
| ls              | eza      | Icons, tree view, git status            |
| grep            | ripgrep  | 5-10x faster, respects .gitignore       |
| find            | fd       | Simpler syntax, 10x faster              |
| diff            | delta    | Side-by-side diffs, syntax highlighting |
| htop            | bottom   | Better UI, graphs, Rust-based           |

---

## Utilities

The `bin/` directory contains helper scripts:

- **install** - Main installation script (idempotent, safe to re-run)
- **install-claude-code** - Standalone Claude Code installer
- **update** - Update dotfiles, Homebrew, npm, and Composer packages
- **doctor** - Health check and diagnostic tool

---

## Credits

Created by [Freek Van der Herten](https://github.com/freekmurze). Used by many at [Spatie](https://spatie.be).

See `config/Brewfile` for complete package list.
