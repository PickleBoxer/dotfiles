---
name: git-cleanup-branches
description: 'Clean up local git branches that track deleted remote branches. Use when asked to "clean git branches", "remove deleted branches", "prune branches", "cleanup stale branches", or when you see branches marked as "gone" in git status. Works on Windows, macOS, and Linux.'
---

# Git Branch Cleanup

Automatically identifies and removes local git branches that track remote branches that no longer exist (marked as "gone").

## When to Use This Skill

- User asks to "clean up git branches"
- User wants to "remove deleted branches"
- User mentions "prune branches" or "cleanup stale branches"
- Local branches show `[origin/branch: gone]` status
- After merging pull requests and deleting remote branches

## Prerequisites

- Git repository initialized
- **Must be on main/master branch** (not on a branch you want to delete)
- Active internet connection to fetch from remote

## Workflow

### 1. Switch to main branch (Required)

```bash
git checkout main
```

**Important**: You cannot delete a branch you're currently on. Always switch to main/master first.

### 2. Check current branch status

```bash
git branch -vv
```

Look for branches with `[origin/branch-name: gone]` - these track deleted remotes.

### 3. Prune remote tracking references

```bash
git fetch --prune
```

### 4. Find stale branches

**PowerShell:**
```powershell
git branch -vv | Select-String 'gone'
```

**Bash:**
```bash
git branch -vv | grep 'gone'
```

### 5. Delete stale branches

**Single branch:**
```bash
git branch -D <branch-name>
```

**Automated cleanup (PowerShell):**
```powershell
git branch -vv | Select-String 'gone' | ForEach-Object { 
    $branchName = $_.Line.Trim() -split '\s+' | Select-Object -First 1
    git branch -D $branchName
}
```

**Automated cleanup (Bash):**
```bash
git branch -vv | grep 'gone' | awk '{print $1}' | xargs -r git branch -D
```

### 6. Verify cleanup

```bash
git branch -vv
```

## Safety Notes

- **Always switch to main/master before cleaning** - you can't delete the branch you're on
- Use `-D` (force delete) - bypasses merge check
- Deleted local branches can't be easily recovered
- Remote branches are NOT affected - this only cleans local copies
- Backup branches (no remote tracking) won't be deleted by this process
