---
title: "GitHub Copilot CLI Commands In Depth"
description: "A comprehensive reference for every gh copilot subcommand, flag, and option. Master suggest, explain, configuration, shell aliases, scripting, and pro-level workflows."
difficulty: advanced
duration: "60 minutes"
icon: "⌨️"
tags: ["copilot-cli", "gh-cli", "terminal", "shell", "scripting", "automation"]
prerequisites:
  - "GitHub CLI (gh) installed and authenticated"
  - "Copilot in the CLI extension installed (gh extension install github/gh-copilot)"
  - "Completed the 'GitHub Copilot in the CLI' workshop or equivalent experience"
objectives:
  - "Know every flag and option for gh copilot suggest and gh copilot explain"
  - "Configure target shell types for accurate suggestions"
  - "Create shell aliases and functions to integrate Copilot into daily workflows"
  - "Use gh copilot in scripts and CI pipelines"
  - "Understand environment variables that control Copilot CLI behaviour"
  - "Apply pro tips to get higher-quality suggestions on the first try"
lastUpdated: 2026-04-08
order: 8
---

You've used `gh copilot suggest` and `gh copilot explain` — but did you know each command has a full set of flags that dramatically change how they behave? This workshop dives into every subcommand, every option, shell integration tricks, and scripting patterns so Copilot CLI becomes a natural part of every terminal session.

## What You'll Learn

- The complete command reference for `gh copilot suggest` and `gh copilot explain`
- How to target specific shell types for precise, copy-paste-ready output
- Shell aliases, functions, and profile setup for zero-friction access
- Using `--target` flags to generate git, gh, and generic shell commands
- Scripting Copilot suggestions for automation and CI workflows
- Key environment variables and how they affect output

## Prerequisites

1. **GitHub CLI** (`gh`) version 2.40.0 or later — [install guide](https://cli.github.com/)
2. **Copilot in the CLI extension** installed:
   ```bash
   gh extension install github/gh-copilot
   ```
3. Authenticated with `gh auth login`
4. Completed the [GitHub Copilot in the CLI](./copilot-cli) workshop or equivalent hands-on experience

---

## Command Reference

### `gh copilot` — Top-Level Command

```sh
gh copilot [command] [flags]
```

| Subcommand | Purpose |
|-----------|---------|
| `suggest`  | Generate a command from a natural-language description |
| `explain`  | Explain what a given command does |
| `config`   | View or change Copilot CLI settings |
| `--version` | Display the installed extension version |
| `--help`   | Show help for any command |

---

## Exercise 1 — Mastering `gh copilot suggest`

**Goal:** Understand every flag for `suggest` and choose the right target type for your shell.

### Step 1: Basic Syntax

```sh
gh copilot suggest "<natural language description>"
```

Example:

```sh
gh copilot suggest "list all running docker containers and their memory usage"
```

### Step 2: The `--target` / `-t` Flag

By default, `suggest` asks interactively which type of command you want. Pass `--target` to skip the prompt:

| Value | When to use |
|-------|-------------|
| `shell` | Generic POSIX/bash/zsh commands |
| `gh`    | GitHub CLI (`gh`) commands |
| `git`   | Git commands and plumbing |

```sh
# Generate a git command without an interactive prompt
gh copilot suggest "undo the last commit but keep changes staged" --target git

# Generate a gh command
gh copilot suggest "create a draft PR from current branch to main" --target gh

# Force shell output
gh copilot suggest "recursively find files larger than 100MB" --target shell
```

### Step 3: The `--help` Flag

```sh
gh copilot suggest --help
```

Review the output — the `--target` shorthand `-t` and available values are listed here and may expand with new extension versions.

### Step 4: Try an Ambiguous Request

Run the same request with each `--target` value and compare the output:

```sh
gh copilot suggest "show recent changes" --target git
gh copilot suggest "show recent changes" --target gh
gh copilot suggest "show recent changes" --target shell
```

Notice how the target context steers suggestions toward completely different tools.

---

## Exercise 2 — Mastering `gh copilot explain`

**Goal:** Use `explain` to decode commands found in docs, Stack Overflow, or your own history.

### Step 1: Inline Explanation

```sh
gh copilot explain "<command>"
```

Example:

```sh
gh copilot explain "git log --oneline --graph --decorate --all"
```

### Step 2: Piping from Shell History

Retrieve a recent command and explain it without copy-pasting:

```sh
# Bash / Zsh — get last command
gh copilot explain "$(fc -ln -1)"

# Or use !! expansion  
gh copilot explain "!!"
```

### Step 3: Explain a Multi-Part Pipeline

Wrap complex pipelines in single quotes to treat them as one argument:

```sh
gh copilot explain 'find . -name "*.log" -mtime +7 | xargs rm -f'
```

### Step 4: `--help` for `explain`

```sh
gh copilot explain --help
```

---

## Exercise 3 — `gh copilot config`

**Goal:** Inspect and modify Copilot CLI settings.

### Step 1: View Current Config

```sh
gh copilot config
```

This shows the current settings, including whether usage data and optional features are enabled.

### Step 2: Toggle Optional Usage Data

```sh
# Opt out of usage data collection
gh copilot config --set optionalUsageData false

# Re-enable
gh copilot config --set optionalUsageData true
```

---

## Exercise 4 — Shell Aliases and Functions

**Goal:** Create shortcuts so `suggest` and `explain` are always one keystroke away.

### Step 1: Simple Aliases

Add these to your `~/.zshrc` or `~/.bashrc`:

```sh
# Short alias for suggest (defaults to interactive target selection)
alias '??'='gh copilot suggest'

# Short alias for explain
alias '?!'='gh copilot explain'

# Aliases per target type
alias 'gs'='gh copilot suggest --target shell'
alias 'gg'='gh copilot suggest --target git'
alias 'ggh'='gh copilot suggest --target gh'
```

> **💡 Tip:** The `??` and `?!` aliases are the ones recommended by the official gh-copilot docs.

### Step 2: A Smarter Shell Function

For bash/zsh, this function wraps `suggest` and immediately copies the result to your clipboard (macOS):

```sh
cpsuggest() {
  local result
  result=$(gh copilot suggest "$*" --target shell 2>&1)
  echo "$result"
  echo "$result" | pbcopy
  echo "(Copied to clipboard)"
}
```

Add, reload your shell, then run:

```sh
cpsuggest "set file permissions so only the owner can read and write"
```

### Step 3: Apply Your Aliases

```sh
source ~/.zshrc   # or source ~/.bashrc
?? "compress the current directory into a timestamped tar.gz"
```

---

## Exercise 5 — Scripting with `gh copilot`

**Goal:** Use the CLI non-interactively in scripts and pipelines.

### Step 1: Capture Output in a Variable

```sh
CMD=$(gh copilot suggest "list the 10 largest files in /var/log sorted by size" --target shell)
echo "Suggested: $CMD"
```

### Step 2: Extract Just the Command

`suggest` wraps the command in a block. Use `grep` and `sed` to extract it for automation:

```sh
gh copilot suggest "count lines in all .ts files" --target shell \
  | grep -A1 "command:" \
  | tail -1 \
  | sed 's/^[[:space:]]*//'
```

> **Note:** The exact output format may vary across extension versions. Always verify before using in production scripts.

### Step 3: Log Explanations for Audit Trails

In a CI script, log the intent of commands you're about to run:

```sh
COMMAND="kubectl rollout restart deployment/api"
echo "# Action: $(gh copilot explain "$COMMAND")" >> deploy.log
eval "$COMMAND"
```

---

## Exercise 6 — Environment Variables

**Goal:** Know which environment variables influence Copilot CLI behaviour.

| Variable | Effect |
|----------|--------|
| `GH_TOKEN` | Personal access token used by `gh`; Copilot CLI piggybacks on this auth |
| `GH_HOST` | Override the GitHub host (for GitHub Enterprise) |
| `NO_COLOR` | Set to any value to disable ANSI color codes in output |
| `GH_PAGER` | Override the pager (`less`, `cat`, etc.) for help output |

### Step 1: Test with a Different Host (GHE)

```sh
GH_HOST=github.mycompany.com gh copilot suggest "create a new repo" --target gh
```

### Step 2: Disable Colors for Script Parsing

```sh
NO_COLOR=1 gh copilot suggest "list branches merged into main" --target git
```

---

## Exercise 7 — Keeping the Extension Up to Date

**Goal:** Ensure you always have the latest Copilot CLI commands and improvements.

```sh
# Check current version
gh copilot --version

# Upgrade the extension
gh extension upgrade github/gh-copilot

# List all installed extensions and their versions
gh extension list
```

Set a reminder to run `gh extension upgrade github/gh-copilot` monthly to pick up new flags and model improvements.

---

## Tips & Tricks

- **Be specific about context.** Instead of `"delete a branch"`, write `"delete a local git branch named feature/login and its remote tracking branch"`.
- **State the output format you want.** Try appending `"output as a one-liner"` or `"use --porcelain format"` to your prompt.
- **Iterate.** After a suggestion, choose `Revise command` (interactive mode) to refine without re-typing the question.
- **Use `--target git` for all git operations.** Generic shell suggestions sometimes reach for less portable alternatives.
- **Chain with `xargs` or `eval` carefully.** Always read and understand the suggested command before executing — Copilot is a productivity tool, not a replacement for understanding.

---

## Summary

You now know the complete `gh copilot` command surface:

| Topic | Key Takeaway |
|-------|-------------|
| `suggest --target` | Always specify the target to skip prompts and get accurate output |
| `explain` | Works on any shell/git/gh command; pipe from history for speed |
| `config` | Manage usage data and extension settings |
| Shell aliases | `??` / `?!` for instant access; custom functions for clipboard integration |
| Scripting | Capture output, extract commands, and log explanations in CI |
| Environment variables | `GH_HOST` for GHE, `NO_COLOR` for script-safe output |
| Updates | `gh extension upgrade github/gh-copilot` keeps commands current |

**Next steps:** explore the [GitHub Copilot in the CLI](../copilot-cli) workshop for hands-on exercises, or try the [Copilot Chat](../copilot-chat) workshop to bring the same conversational AI into your editor.
