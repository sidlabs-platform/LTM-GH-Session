---
title: "Getting Started with GitHub Copilot Coding Agent"
description: "Learn to use GitHub's autonomous coding agent for issue-to-PR development"
difficulty: intermediate
duration: "60 minutes"
icon: "🤖"
tags: ["coding-agent", "github-actions", "automation"]
prerequisites: ["Basic GitHub knowledge", "Familiarity with pull requests"]
objectives: ["Understand what the coding agent does", "Assign issues to Copilot", "Review and refine agent-generated PRs", "Configure agent behavior with custom instructions"]
lastUpdated: 2026-04-08
order: 1
---

# Getting Started with GitHub Copilot Coding Agent

The GitHub Copilot coding agent is an **autonomous AI developer** that can take a GitHub issue, plan an implementation, write the code, run tests, and open a pull request — all on its own. Instead of offering line-by-line suggestions in your editor, the coding agent works independently in a secure cloud environment, turning issue descriptions into working code changes.

Think of it as assigning a task to a capable junior developer: you describe what needs to be done, it figures out how to do it, and you review the result.

---

## What You'll Learn

- What the coding agent is and how it differs from Copilot code completions
- The **end-to-end workflow**: issue → agent analysis → code generation → PR
- How to configure the agent's environment with **`copilot-setup-steps.yml`**
- Writing **effective issues** that produce high-quality agent output
- Reviewing, iterating on, and merging **agent-generated pull requests**
- Customizing agent behavior with **`.github/copilot-instructions.md`**

---

## How It Works

When you assign an issue to the coding agent, a sequence of automated steps runs behind the scenes:

```
┌─────────────────────────────────────────────────────────────┐
│                      YOU (Developer)                        │
│                                                             │
│   1. Create an issue         4. Review the PR               │
│   2. Assign to Copilot       5. Request changes or merge    │
└──────────┬──────────────────────────────┬───────────────────┘
           │                              ▲
           ▼                              │
┌─────────────────────────────────────────────────────────────┐
│                  GitHub Copilot Coding Agent                 │
│                                                             │
│   ┌─────────┐   ┌──────────┐   ┌─────────┐   ┌─────────┐  │
│   │ Analyze │──▶│  Plan &  │──▶│  Write  │──▶│ Validate│  │
│   │  Issue  │   │  Design  │   │  Code   │   │ & Test  │  │
│   └─────────┘   └──────────┘   └─────────┘   └────┬────┘  │
│                                                     │       │
│                                              ┌──────▼────┐  │
│                                              │  Open PR  │  │
│                                              └───────────┘  │
└─────────────────────────────────────────────────────────────┘

Environment: Secure cloud VM with your repo, dependencies,
and tools installed via copilot-setup-steps.yml
```

### Step-by-Step Flow

1. **Issue analysis** — The agent reads the issue title, description, labels, and any linked context. It also reads your repository's code, structure, and custom instructions.
2. **Planning** — The agent creates an implementation plan, deciding which files to modify or create and what approach to take.
3. **Code generation** — Working in a secure cloud environment (a GitHub Actions-powered VM), the agent writes the code, creates new files, and modifies existing ones.
4. **Validation** — The agent runs your project's build, linter, and tests (configured via `copilot-setup-steps.yml`) to verify its changes work.
5. **Pull request** — The agent opens a PR with a clear description of what it did and why, linking back to the original issue.

> 💡 **Key point:** The agent runs in a sandboxed environment — it has access to your repository code and can install dependencies, but it cannot access external services, secrets, or other repositories unless explicitly configured.

---

## Setting Up

### Prerequisites

- A GitHub organization or personal account with **GitHub Copilot Enterprise** or **Copilot Business** (with the coding agent feature enabled)
- Repository admin access (to enable the agent)
- GitHub Actions enabled on the repository

### Step 1: Enable the Coding Agent

1. Navigate to your repository on GitHub.
2. Go to **Settings** → **Copilot** → **Coding agent**.
3. Toggle **"Enable Copilot coding agent"** to on.
4. Choose who can assign issues to the agent (recommended: start with repository admins only).

### Step 2: Configure the Development Environment

Create a `.github/copilot-setup-steps.yml` file that tells the agent how to set up and validate your project:

```yaml
# .github/copilot-setup-steps.yml
steps:
  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: "20"

  - name: Install dependencies
    run: npm ci

  - name: Verify build
    run: npm run build

  - name: Run linter
    run: npm run lint

  - name: Run tests
    run: npm test
```

This file is critical — it defines the commands the agent runs to validate its changes. Without it, the agent can still write code, but it cannot verify that the code compiles and passes tests.

### Step 3: Add Custom Instructions (Optional but Recommended)

Create a `.github/copilot-instructions.md` file with project-specific guidance:

```markdown
# Copilot Instructions

## Code Style
- Use TypeScript for all new files
- Follow the existing project structure in `src/`
- Use named exports, not default exports
- Prefer functional React components with hooks

## Testing
- Write tests for all new functions and components
- Place test files adjacent to source files with `.test.ts` suffix
- Use Vitest for unit tests

## Conventions
- Use `camelCase` for variables and functions
- Use `PascalCase` for types, interfaces, and components
- All API routes should include input validation with Zod
```

---

## Your First Agent Task

Let's walk through assigning your first issue to the coding agent.

### Step 1: Write a Clear Issue

Create a new issue in your repository with a descriptive title and detailed body:

**Title:** `Add a /api/health endpoint that returns service status`

**Body:**

```markdown
## Description
Add a health check API endpoint that returns the current service status,
uptime, and version information.

## Requirements
- Create a `GET /api/health` endpoint
- Return JSON with: `status`, `uptime` (in seconds), `version` (from package.json), and `timestamp`
- Return HTTP 200 when healthy
- Add a test for the endpoint

## Acceptance Criteria
- [ ] Endpoint exists at `/api/health`
- [ ] Response includes all required fields
- [ ] Test file exists and passes
- [ ] TypeScript types are defined for the response
```

> 💡 **Tip:** The more specific and structured your issue is, the better the agent performs. Include acceptance criteria, technical constraints, and references to existing code when relevant.

### Step 2: Assign to Copilot

You can assign the issue to Copilot in several ways:

1. **Issue assignee** — In the issue sidebar, click "Assignees" and select **Copilot** from the list.
2. **Comment** — Leave a comment on the issue: `@copilot` — the agent will pick up the task.
3. **Label** — Add a label like `copilot` (if configured in your repository settings).

### Step 3: Monitor Progress

Once assigned, the agent begins working. You can track its progress:

- A **status comment** appears on the issue showing the agent is working.
- The agent's activity is visible in the **Actions** tab as a workflow run.
- When complete, a **pull request** is opened and linked to the issue.

This typically takes **2–10 minutes** depending on the complexity of the task and the size of your codebase.

### Step 4: Review the PR

The agent opens a PR with:

- A descriptive title and body explaining the changes
- A link back to the original issue
- A summary of what was implemented and any decisions made
- The actual code changes

Review it just like any other PR — check the code, run the tests locally if needed, and leave feedback.

---

## Working with Agent PRs

The coding agent's pull requests are regular GitHub PRs, so you can interact with them using all the tools you're used to. But there are some agent-specific workflows worth knowing.

### Reviewing the Code

Agent-generated code tends to be **correct but sometimes verbose**. Common things to watch for:

- **Over-engineering** — The agent may add more abstraction than needed. Simplify if warranted.
- **Naming choices** — Variable and function names are usually reasonable but may not match your project's conventions perfectly.
- **Missing edge cases** — The agent handles the core requirements well but may miss subtle domain-specific edge cases.
- **Test coverage** — Tests are usually present but may focus on happy paths. Check for edge case coverage.

### Requesting Changes

If the PR needs adjustments, you have two options:

**Option A: Leave a review comment**

Leave a regular PR review comment describing what needs to change. The agent will read your feedback, make updates, and push new commits to the same branch.

```markdown
<!-- Example review comment -->
The health endpoint looks good, but please also:
- Add a `dependencies` field that checks database connectivity
- Handle the case where `package.json` can't be read
- Use the existing `ApiResponse` wrapper type from `src/types/api.ts`
```

**Option B: Edit the code yourself**

Since it's a regular branch, you can check it out, make changes, and push directly — or use GitHub's web editor for small fixes.

### Iterating with the Agent

You can go back and forth with the agent multiple times:

1. Agent opens PR → You review → You request changes via comment
2. Agent pushes updates → You review again → Approve and merge

Each round of feedback makes the result better. Think of it as a **code review conversation** with an AI pair.

---

## Custom Instructions

Custom instructions are the most powerful way to improve the quality of agent-generated code. They give the agent persistent context about your project's standards, patterns, and preferences.

### `.github/copilot-instructions.md`

This file provides general guidance that applies to all Copilot features (code completion, chat, and the coding agent):

```markdown
# Project: Acme Dashboard

## Architecture
This is a Next.js 14 app with the App Router. The backend uses
Prisma with PostgreSQL. Authentication is handled by NextAuth.js.

## File Structure
- `src/app/` — Next.js routes and layouts
- `src/components/` — Shared React components
- `src/lib/` — Utility functions, database client, auth config
- `src/types/` — Shared TypeScript type definitions
- `prisma/` — Database schema and migrations

## Important Conventions
- All database queries go through the Prisma client in `src/lib/db.ts`
- API routes must validate input using Zod schemas from `src/lib/validators/`
- Error responses follow the format: `{ error: string, code: string }`
- Never use `any` type — prefer `unknown` with type guards
```

### `copilot-setup-steps.yml`

This file controls the agent's development environment. Make sure it mirrors your local development setup:

```yaml
steps:
  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: "20"

  - name: Install dependencies
    run: npm ci

  - name: Setup database
    run: |
      npx prisma generate
      npx prisma db push
    env:
      DATABASE_URL: "postgresql://localhost:5432/test"

  - name: Build project
    run: npm run build

  - name: Run tests
    run: npm test
```

### Tips for Effective Instructions

| Do | Don't |
|---|---|
| Reference specific files and directories | Write vague guidance like "follow best practices" |
| Include naming conventions with examples | Assume the agent knows your internal terminology |
| List the testing framework and patterns you use | Leave the setup steps file empty |
| Mention important architectural decisions | Include sensitive information or secrets |
| Specify the PR review standards you expect | Write instructions longer than ~500 lines |

---

## Best Practices

### Issues That Work Well with the Agent

The coding agent excels at well-defined, scoped tasks. Here are the types of issues that produce the best results:

✅ **Great for the agent:**

- Adding a new API endpoint with clear inputs and outputs
- Creating a new React component from a design description
- Writing or extending test coverage for existing modules
- Adding input validation or error handling to existing code
- Creating utility functions with clear specifications
- Refactoring code with well-defined before/after expectations
- Updating documentation or adding JSDoc comments
- Fixing bugs that are well-described with reproduction steps

⚠️ **Use with caution:**

- Large features that span many files and require architectural decisions
- Tasks requiring deep domain knowledge not captured in the codebase
- Performance optimizations that require benchmarking
- Security-sensitive changes that need careful review

❌ **Not recommended:**

- Vague or open-ended issues ("improve the codebase")
- Tasks requiring access to external services or APIs during development
- Changes that depend on visual design feedback
- Issues requiring human judgment about product direction

### Writing Effective Issues for the Agent

1. **Be specific** — "Add a `GET /api/users/:id` endpoint that returns a user by ID with proper 404 handling" is much better than "Add user API."
2. **Include acceptance criteria** — Checkboxes help the agent understand exactly what "done" looks like.
3. **Reference existing code** — "Follow the same pattern as `src/routes/posts.ts`" gives the agent a concrete template.
4. **Specify constraints** — "Use Zod for validation, return errors in the `ApiError` format from `src/types`" prevents the agent from inventing its own patterns.
5. **Keep scope small** — One focused issue per task produces better results than a mega-issue covering multiple features.

---

## Limitations & Tips

### Current Limitations

- **No external service access** — The agent cannot call external APIs, databases, or services during development (unless you configure them in setup steps). It works with the code in the repository.
- **Context window limits** — Very large repositories may exceed the agent's ability to fully understand all relevant code. Explicit references to files help.
- **No visual output** — The agent cannot see rendered UI. It generates code based on descriptions, not screenshots or design files.
- **Sequential processing** — The agent handles one issue at a time per repository. Assigning multiple issues will queue them.
- **Environment constraints** — The cloud VM has limited resources. Complex build pipelines or very large dependency trees may time out.

### Tips for Success

1. **Start small** — Your first agent task should be simple and well-defined. Build confidence before tackling larger tasks.
2. **Invest in `copilot-setup-steps.yml`** — A well-configured environment is the difference between an agent that validates its work and one that submits untested code.
3. **Write good instructions** — The `.github/copilot-instructions.md` file is your most powerful lever. Update it as you learn what guidance the agent needs.
4. **Review carefully** — Treat agent PRs like any code review. The code is usually functional but benefits from human judgment about design, edge cases, and naming.
5. **Iterate via comments** — Don't hesitate to request changes. The agent learns from your feedback within the PR conversation.
6. **Use labels for triage** — Create a label like `good-for-agent` to tag issues that are well-suited for the coding agent. This helps your team build intuition.

---

## Hands-On Exercise

Put everything together by completing this end-to-end exercise.

### Goal

Create a repository, configure the coding agent, write an issue, assign it to Copilot, and review the resulting PR.

### Step 1: Create a Test Repository

```bash
# Create a new Node.js project
mkdir copilot-agent-demo && cd copilot-agent-demo
npm init -y
npm install express zod
npm install -D typescript @types/express @types/node vitest

# Initialize TypeScript
npx tsc --init --outDir dist --rootDir src --strict
```

Create a minimal Express server:

```typescript
// src/index.ts
import express from "express";

const app = express();
app.use(express.json());

app.get("/", (req, res) => {
  res.json({ message: "Hello from Copilot Agent Demo!" });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
```

### Step 2: Add Configuration Files

Create `.github/copilot-setup-steps.yml`:

```yaml
steps:
  - name: Setup Node.js
    uses: actions/setup-node@v4
    with:
      node-version: "20"
  - name: Install dependencies
    run: npm ci
  - name: Build
    run: npx tsc --noEmit
  - name: Test
    run: npx vitest run
```

Create `.github/copilot-instructions.md`:

```markdown
# Copilot Instructions for Agent Demo

- Use TypeScript for all code
- Place source files in `src/`
- Place tests alongside source files with `.test.ts` suffix
- Use Vitest for testing
- Use Zod for input validation
- Follow Express.js patterns with proper error handling
```

### Step 3: Push to GitHub

```bash
git init
git add .
git commit -m "Initial project setup"
gh repo create copilot-agent-demo --public --push
```

### Step 4: Enable the Agent

1. Go to your repository **Settings** → **Copilot** → **Coding agent**
2. Enable the coding agent

### Step 5: Create and Assign an Issue

Create an issue via the GitHub CLI or web UI:

```bash
gh issue create \
  --title "Add a POST /api/todos endpoint" \
  --body "## Description
Create a POST endpoint at \`/api/todos\` that accepts a JSON body with
\`title\` (string, required) and \`completed\` (boolean, optional, defaults to false).

## Requirements
- Validate input using Zod
- Store todos in an in-memory array (no database needed)
- Return 201 with the created todo (include an auto-generated \`id\`)
- Return 400 with validation errors for invalid input
- Add a GET /api/todos endpoint that returns all todos

## Acceptance Criteria
- [ ] POST /api/todos creates a new todo
- [ ] GET /api/todos returns all todos
- [ ] Input validation with proper error messages
- [ ] TypeScript types for Todo
- [ ] Tests for both endpoints"
```

Then assign it to Copilot:

```bash
# Assign via comment
gh issue comment <ISSUE_NUMBER> --body "@copilot"
```

### Step 6: Review the PR

Once the agent opens a PR (typically within a few minutes):

1. Read the PR description — does it address all acceptance criteria?
2. Review the code — check types, validation, error handling, and test coverage.
3. Leave feedback if needed — the agent will update the PR based on your comments.
4. Approve and merge when you're satisfied.

### Reflection Questions

After completing the exercise, consider:

- How specific did your issue need to be to get a good result?
- What did the agent handle well? What needed adjustment?
- How would you write the issue differently next time?
- What additional custom instructions would have improved the output?

---

## Summary & Next Steps

You've learned the full workflow for using the GitHub Copilot coding agent:

- **What it is** — An autonomous AI agent that turns issues into pull requests
- **How it works** — Analyzes issues, plans changes, writes code, validates with tests, and opens PRs
- **Setup** — Enable the agent, configure `copilot-setup-steps.yml`, and add custom instructions
- **Workflow** — Write clear issues → assign to Copilot → review PRs → iterate with feedback
- **Best practices** — Small, specific issues with acceptance criteria produce the best results

### Where to Go Next

1. **Optimize your instructions** — As you use the agent more, refine `.github/copilot-instructions.md` based on patterns you see in generated code.
2. **Try complex tasks** — Once comfortable with simple issues, experiment with multi-file changes and feature implementations.
3. **Integrate with your workflow** — Use labels and project boards to triage which issues are good candidates for the agent.
4. **Explore agent + Copilot Chat** — Use the coding agent for implementation and Copilot Chat for design discussions, code explanations, and debugging.
5. **Check out the Advanced Agent Patterns course** — Learn to chain agent tasks, use custom actions, and build automated development pipelines.
