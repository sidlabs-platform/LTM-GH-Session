---
title: "GitHub Copilot in the CLI"
description: "Bring AI assistance to your terminal. Learn to use gh copilot suggest and gh copilot explain to generate shell commands, understand complex pipelines, and boost your command-line productivity."
difficulty: intermediate
duration: "30 minutes"
icon: "🖥️"
tags: ["copilot-cli", "terminal", "shell", "git", "gh-cli"]
prerequisites: ["GitHub CLI (gh) installed", "Copilot in the CLI extension installed", "Comfortable with basic terminal commands"]
objectives:
  - "Install and configure Copilot in the CLI"
  - "Use gh copilot suggest to generate shell commands from natural language"
  - "Use gh copilot explain to understand complex commands"
  - "Generate git commands for common and advanced workflows"
  - "Chain suggestions to build multi-step command pipelines"
lastUpdated: 2026-04-08
order: 3
---

You don't have to leave the terminal to get help from Copilot. The GitHub CLI extension **Copilot in the CLI** lets you describe what you want in plain English and get back a ready-to-run command. It can also explain commands you've found in documentation or Stack Overflow so you know exactly what they do before you execute them. This workshop gets you comfortable with both `suggest` and `explain` through real-world exercises.

## What You'll Learn

- How to install and set up Copilot in the CLI
- Generating shell commands with `gh copilot suggest`
- Explaining commands with `gh copilot explain`
- Choosing the right command type: `generic shell`, `git`, or `gh` command
- Building multi-step workflows by chaining suggestions

## Prerequisites

1. **GitHub CLI** (`gh`) version 2.40.0 or later — [install guide](https://cli.github.com/)
2. **Copilot in the CLI extension** installed:
   ```bash
   gh extension install github/gh-copilot
   ```
3. Authenticated with `gh auth login`
4. Comfortable with basic shell commands (`cd`, `ls`, `cat`, `grep`, etc.)

Verify your setup:

```bash
gh copilot --version
```

You should see the extension version printed. If not, re-run the install command above.

---

## Understanding the Two Commands

| Command | Purpose | When to use |
|---|---|---|
| `gh copilot suggest` | Generate a command from a natural-language description | You know *what* you want to do but not the exact syntax |
| `gh copilot explain` | Explain what an existing command does | You found a command and want to understand it before running it |

Both commands are interactive — they'll prompt you to select a command type and confirm before executing anything.

---

## Exercise 1 — Generating Shell Commands with `suggest`

**Goal:** Use natural-language prompts to generate common shell commands.

### Step 1: Ask for a simple command

```bash
gh copilot suggest "find all TypeScript files modified in the last 7 days"
```

Copilot will ask you to select a command type:

```
? What kind of command can I help you with?
> generic shell command
  git command
  gh command
```

Select **generic shell command**. Copilot suggests:

```bash
find . -name "*.ts" -mtime -7
```

### Step 2: Try a more complex request

```bash
gh copilot suggest "list the 10 largest files in the current directory tree, showing human-readable sizes"
```

Expected suggestion:

```bash
du -ah . | sort -rh | head -10
```

### Step 3: Execute or revise

After Copilot shows the suggestion, you'll see options:

```
? Select an option
> Copy to clipboard
  Explain command
  Execute command
  Revise command
```

Choose **Execute command** to run it directly, or **Revise command** to refine your prompt.

> **💡 Tip:** Be specific about operating system when it matters. "List all listening ports" produces different commands on macOS (`lsof -iTCP -sTCP:LISTEN`) vs. Linux (`ss -tlnp`). Add "on macOS" or "on Linux" to your prompt for accurate results.

---

## Exercise 2 — Understanding Commands with `explain`

**Goal:** Demystify complex commands you encounter in documentation, scripts, or code reviews.

### Step 1: Explain a pipeline

```bash
gh copilot explain "find . -type f -name '*.log' -mtime +30 -exec gzip {} \;"
```

Copilot returns a detailed breakdown:

> *"This command finds all files (`-type f`) with a `.log` extension in the current directory tree, filters to those modified more than 30 days ago (`-mtime +30`), and compresses each one with gzip. The `\;` terminates the `-exec` clause, causing gzip to run once per file."*

### Step 2: Explain a git command

```bash
gh copilot explain "git log --oneline --graph --all --decorate --since='2 weeks ago'"
```

Copilot will explain each flag:

> *"`--oneline`: Compact one-line format. `--graph`: ASCII branch graph. `--all`: Show all branches. `--decorate`: Show branch/tag names. `--since`: Only commits from the last two weeks."*

### Step 3: Explain a regex-heavy command

```bash
gh copilot explain "grep -rn --include='*.ts' -E 'import\s+\{[^}]*\}\s+from\s+['\''\"]\.' src/"
```

Copilot breaks down the regex pattern and each grep flag, making the command readable.

> **💡 Tip:** Pipe `explain` into your workflow whenever you encounter a command you didn't write. It's faster than reading man pages and gives you the context specific to the full command, not just individual flags.

---

## Exercise 3 — Git Commands

**Goal:** Let Copilot generate git commands for everyday and advanced workflows.

### Step 1: Common git operations

Try these prompts one at a time:

```bash
gh copilot suggest "undo the last commit but keep the changes staged"
```

Expected:

```bash
git reset --soft HEAD~1
```

```bash
gh copilot suggest "show me which files changed between main and my current branch"
```

Expected:

```bash
git diff --name-only main...HEAD
```

```bash
gh copilot suggest "create a new branch from main, cherry-pick commit abc1234, and push it"
```

Expected:

```bash
git checkout main && git pull && git checkout -b cherry-pick-branch && git cherry-pick abc1234 && git push -u origin cherry-pick-branch
```

### Step 2: Advanced git scenarios

```bash
gh copilot suggest "squash the last 3 commits into one with a new message"
```

Expected:

```bash
git reset --soft HEAD~3 && git commit -m "Your new commit message"
```

```bash
gh copilot suggest "find all commits that modified the file src/auth.ts in the last month"
```

Expected:

```bash
git log --oneline --since="1 month ago" -- src/auth.ts
```

> **💡 Tip:** Select **git command** as the command type when your request is git-related. This tells Copilot to use git-specific syntax and avoid generic shell alternatives.

---

## Exercise 4 — GitHub CLI Commands

**Goal:** Generate `gh` commands for GitHub operations without memorizing the API.

### Step 1: Working with issues and PRs

```bash
gh copilot suggest "list all open pull requests assigned to me"
```

Expected:

```bash
gh pr list --assignee @me --state open
```

```bash
gh copilot suggest "create an issue titled 'Fix login timeout' with the label 'bug'"
```

Expected:

```bash
gh issue create --title "Fix login timeout" --label "bug"
```

### Step 2: Repository operations

```bash
gh copilot suggest "show the workflow runs that failed in the last week"
```

Expected:

```bash
gh run list --status failure --limit 20
```

```bash
gh copilot suggest "download the artifact named 'build-output' from the latest workflow run"
```

Expected:

```bash
gh run download --name build-output
```

### Step 3: Code review workflow

```bash
gh copilot suggest "check out pull request 42 locally for testing"
```

Expected:

```bash
gh pr checkout 42
```

> **💡 Tip:** Select **gh command** as the command type to get suggestions using the GitHub CLI's subcommands (`gh pr`, `gh issue`, `gh run`, etc.) instead of raw API calls with `curl`.

---

## Exercise 5 — Chaining Suggestions for Complex Workflows

**Goal:** Build multi-step command pipelines by iterating with Copilot.

### Scenario: Clean up a repository

You want to find and delete all merged branches (except `main` and `develop`), then prune remote tracking branches.

### Step 1: Generate the first command

```bash
gh copilot suggest "list all local branches that have been merged into main except main and develop"
```

Expected:

```bash
git branch --merged main | grep -vE '^\*|main|develop'
```

### Step 2: Build on the result

Take the output and ask for the next step:

```bash
gh copilot suggest "delete all local branches output by: git branch --merged main | grep -vE 'main|develop'"
```

Expected:

```bash
git branch --merged main | grep -vE '^\*|main|develop' | xargs git branch -d
```

### Step 3: Add remote cleanup

```bash
gh copilot suggest "prune remote tracking branches that no longer exist on the remote"
```

Expected:

```bash
git remote prune origin
```

### Step 4: Combine into a one-liner

```bash
gh copilot suggest "delete all local branches merged into main (except main and develop), then prune remote tracking branches — as a single command"
```

Expected:

```bash
git branch --merged main | grep -vE '^\*|main|develop' | xargs git branch -d && git remote prune origin
```

> **💡 Tip:** Use the **Revise command** option to iterate on a suggestion without starting over. Each revision refines the result while keeping the conversation context.

---

## Tips & Tricks

- **Be descriptive, not technical.** Say "find files larger than 100MB" instead of trying to remember `find -size +100M`. That's the whole point.
- **Specify the command type.** Choosing `generic shell`, `git`, or `gh` upfront helps Copilot produce the most idiomatic command.
- **Use `explain` as a learning tool.** Run it on commands from your team's scripts to understand what they do — it's like having a senior engineer walk you through the code.
- **Revise iteratively.** If the first suggestion is close but not perfect, choose **Revise command** and add clarifications instead of starting a new `suggest`.
- **Combine with shell aliases.** Once you find a command you'll reuse, save it as a shell alias. Copilot generates the command; you decide if it earns a permanent spot in your dotfiles.
- **Check before executing.** Always review generated commands before choosing **Execute**, especially for destructive operations (`rm`, `git reset --hard`, `DROP TABLE`).

---

## Summary

In this workshop you learned how to:

1. **Generate commands** — Use `gh copilot suggest` to go from plain English to executable shell commands
2. **Explain commands** — Use `gh copilot explain` to break down complex pipelines, git operations, and regex patterns
3. **Work with git** — Generate git commands for everyday tasks and advanced workflows like squashing, cherry-picking, and branch cleanup
4. **Use the GitHub CLI** — Generate `gh` commands for issues, PRs, workflow runs, and repository management
5. **Chain suggestions** — Build multi-step workflows by iterating on Copilot's suggestions

---

## Next Steps

- **[← Code Completion](./code-completion)** — Master inline suggestions if you haven't already.
- **[← Copilot Chat](./copilot-chat)** — Learn the editor-based chat features that complement the CLI experience.
- Explore creating **shell aliases** for your most-used generated commands.
- Check out the [GitHub CLI documentation](https://cli.github.com/manual/) for more `gh` subcommands you can generate with Copilot.
