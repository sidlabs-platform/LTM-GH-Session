---
title: "Agentic Workflows with GitHub Actions"
description: "Learn to combine GitHub Copilot's coding agent with GitHub Actions to create powerful automated workflows — from issue triage to autonomous feature development."
difficulty: intermediate
duration: "50 minutes"
icon: "🔄"
tags: ["agentic", "github-actions", "automation", "workflows", "ci-cd"]
prerequisites: ["Basic GitHub Actions knowledge", "Familiarity with the Copilot coding agent", "Understanding of GitHub Issues and PRs"]
objectives:
  - "Understand what agentic workflows are and when to use them"
  - "Configure the Copilot coding agent with custom setup steps"
  - "Create GitHub Actions workflows that trigger agentic development"
  - "Build automated pipelines for issue-to-PR development"
  - "Implement review and feedback loops with the coding agent"
lastUpdated: 2026-04-08
order: 2
---

# Agentic Workflows with GitHub Actions

The Copilot coding agent can do more than respond to individual issues — when combined with GitHub Actions, it becomes part of an **automated development pipeline**. Agentic workflows connect issue creation, code generation, testing, review, and deployment into seamless chains where AI handles the implementation and humans provide direction and oversight.

---

## What You'll Learn

- What **agentic workflows** are and how they differ from simple automation
- How the Copilot coding agent integrates with **GitHub Actions**
- Configuring **copilot-setup-steps.yml** for the agent's environment
- Building workflows that **trigger the coding agent** from specific events
- Creating **feedback loops** where the agent iterates based on review comments

---

## Prerequisites

1. Basic knowledge of **GitHub Actions** (workflows, jobs, triggers)
2. Experience with the **Copilot coding agent** (see the Getting Started guide)
3. A GitHub repository with **Actions enabled** and **Copilot agent access**

---

## Understanding Agentic Workflows

Traditional CI/CD is reactive — it runs when code is pushed. Agentic workflows are **proactive** — AI writes the code, and automation validates it.

```
┌──────────────┐     ┌─────────────────┐     ┌───────────────┐
│  Issue Created│────▶│  Agent Assigned │────▶│  Agent Writes  │
│  (by human)  │     │  (auto or manual)│     │  Code & Tests  │
└──────────────┘     └─────────────────┘     └───────┬───────┘
                                                      │
                                                      ▼
┌──────────────┐     ┌─────────────────┐     ┌───────────────┐
│  Human Reviews│◀───│  PR Created     │◀───│  CI/CD Passes  │
│  & Merges     │     │  (by agent)     │     │  (auto)        │
└──────────────┘     └─────────────────┘     └───────────────┘
```

> **💡 Tip:** Agentic workflows work best for well-specified tasks with clear acceptance criteria. Write detailed issue descriptions with examples and edge cases.

---

## Exercise 1 — Configuring the Agent Environment

**Goal:** Set up `copilot-setup-steps.yml` so the coding agent has the right tools and dependencies.

### Step 1: Create the configuration file

Create `.github/copilot-setup-steps.yml` in your repository:

```yaml
# Environment setup for the Copilot coding agent
# These steps run before the agent starts working on an issue

steps:
  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: '20'
      cache: 'npm'

  - name: Install dependencies
    run: npm ci

  - name: Setup database for tests
    run: |
      docker compose -f docker-compose.test.yml up -d
      npm run db:migrate
      npm run db:seed

  - name: Verify test suite passes
    run: npm test
```

### Step 2: Understand what the agent needs

The coding agent runs in a cloud environment. It needs:

- **Language runtimes** — Node.js, Python, Java, etc.
- **Dependencies** — installed via your package manager
- **Services** — databases, caches, or other dependencies for testing
- **Verification** — running the existing test suite to establish a baseline

### Step 3: Test the setup

Push the config and assign a simple issue to Copilot. Check the agent's session logs to verify:
- Dependencies installed correctly
- Test suite passes before the agent starts coding
- The agent has access to all required tools

> **💡 Tip:** Keep setup steps fast. The agent waits for them to complete before starting work. Cache dependencies aggressively to save time.

---

## Exercise 2 — Auto-Assigning Issues to the Agent

**Goal:** Create a GitHub Actions workflow that automatically assigns labeled issues to the Copilot coding agent.

### Step 1: Create the workflow

Create `.github/workflows/auto-assign-copilot.yml`:

```yaml
name: Auto-Assign to Copilot

on:
  issues:
    types: [labeled]

jobs:
  assign-to-copilot:
    runs-on: ubuntu-latest
    if: github.event.label.name == 'copilot-agent'
    permissions:
      issues: write
    steps:
      - name: Assign issue to Copilot
        uses: actions/github-script@v7
        with:
          script: |
            // Assign the issue to Copilot
            await github.rest.issues.addAssignees({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              assignees: ['copilot']
            });

            // Add a comment confirming the assignment
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '🤖 This issue has been assigned to the Copilot coding agent. ' +
                    'It will analyze the requirements and open a PR with the implementation.'
            });
```

### Step 2: Test the workflow

1. Create a new issue with a clear description
2. Add the `copilot-agent` label
3. Watch the workflow run and assign the issue to Copilot
4. The coding agent picks up the issue and starts working

### Step 3: Add quality gates

Extend the workflow to validate the issue before assignment:

```yaml
      - name: Validate issue quality
        uses: actions/github-script@v7
        with:
          script: |
            const issue = context.payload.issue;
            const body = issue.body || '';

            // Check issue has sufficient detail
            if (body.length < 100) {
              await github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: issue.number,
                body: '⚠️ This issue needs more detail for the Copilot agent. ' +
                      'Please add acceptance criteria, examples, and edge cases.'
              });
              return;
            }

            // Proceed with assignment if quality check passes
            await github.rest.issues.addAssignees({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: issue.number,
              assignees: ['copilot']
            });
```

> **💡 Tip:** Quality gates prevent the agent from working on vague issues. A well-written issue with acceptance criteria produces much better agent output.

---

## Exercise 3 — Building a Feedback Loop

**Goal:** Create a workflow where the agent iterates on its PR based on review comments.

### Step 1: Understand the feedback cycle

When you leave review comments on the agent's PR, the agent can process them and push updates. This creates an iterative development loop:

1. Agent opens PR
2. You review and leave comments ("Add error handling here", "This needs input validation")
3. Agent reads comments and pushes new commits
4. You review again — repeat until satisfied

### Step 2: Write effective review feedback

The coding agent responds best to specific, actionable feedback:

```markdown
# ✅ Good feedback — specific and actionable
"Add input validation to the `createUser` function. The `email` field 
should be validated with a regex, and `username` should be 3-30 characters 
alphanumeric only. Return a 400 error with details on which fields failed."

# ❌ Vague feedback — agent may not know what to do
"This needs more validation."
```

### Step 3: Create a notification workflow

Set up notifications when the agent creates a PR:

```yaml
name: Notify on Agent PR

on:
  pull_request:
    types: [opened]

jobs:
  notify:
    runs-on: ubuntu-latest
    if: github.event.pull_request.user.login == 'copilot[bot]'
    steps:
      - name: Add review reminder
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.payload.pull_request.number,
              body: '🔍 **Copilot coding agent has opened this PR.** ' +
                    'Please review the changes. Leave specific comments ' +
                    'and the agent will iterate on the feedback.'
            });
```

> **💡 Tip:** Treat the agent like a capable junior developer. Give it clear direction, review its work carefully, and provide specific feedback when changes are needed.

---

## Exercise 4 — End-to-End Agentic Pipeline

**Goal:** Build a complete pipeline that goes from issue creation to deployed code with minimal human intervention.

### Step 1: Design the pipeline

```
Issue Created → Agent Assigned → Agent Writes Code → CI Passes →
PR Created → Human Reviews → Agent Iterates → Approved → Auto-Merge →
Deploy to Staging → Smoke Tests → Deploy to Production
```

### Step 2: Configure auto-merge

Add an auto-merge workflow for agent PRs that pass all checks and get approval:

```yaml
name: Auto-Merge Agent PRs

on:
  pull_request_review:
    types: [submitted]

jobs:
  auto-merge:
    runs-on: ubuntu-latest
    if: |
      github.event.review.state == 'approved' &&
      github.event.pull_request.user.login == 'copilot[bot]'
    steps:
      - name: Enable auto-merge
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.pulls.merge({
              owner: context.repo.owner,
              repo: context.repo.repo,
              pull_number: context.payload.pull_request.number,
              merge_method: 'squash'
            });
```

### Step 3: Add deployment triggers

Connect the merge to your deployment pipeline:

```yaml
name: Deploy on Merge

on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build && npm test
      - run: npm run deploy:staging

  smoke-test:
    needs: deploy-staging
    runs-on: ubuntu-latest
    steps:
      - run: |
          curl -f https://staging.example.com/health || exit 1
          npm run test:smoke
```

---

## Best Practices for Agentic Workflows

- **Write detailed issues.** Include acceptance criteria, examples, API shapes, and edge cases.
- **Start small.** Begin with bug fixes and small features before graduating to complex multi-file changes.
- **Review thoroughly.** The agent is capable but not infallible. Always review its PRs.
- **Use labels for routing.** Label issues by complexity to decide which get assigned to the agent.
- **Monitor agent sessions.** Check the agent's logs to understand how it approaches problems.
- **Keep the feedback loop tight.** Quick, specific reviews lead to faster convergence.

---

## Summary

In this workshop you learned how to:

1. **Configure the agent environment** with `copilot-setup-steps.yml`
2. **Auto-assign issues** to the coding agent via GitHub Actions
3. **Build feedback loops** for iterative PR refinement
4. **Create end-to-end pipelines** from issue to deployment

Agentic workflows are the future of software development — AI handles the implementation, humans provide direction and review. Start small, build trust, and expand the agent's responsibilities over time.

---

## Next Steps

- **[Building MCP Servers →](./mcp-servers)** — Create custom tools the agent can use during development.
- **[Custom Copilot Extensions →](./custom-agents)** — Build your own Copilot Extensions for specialized workflows.
