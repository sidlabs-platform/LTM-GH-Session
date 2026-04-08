---
title: "Custom Instructions & Project Context"
description: "Tailor GitHub Copilot to your project's conventions with custom instructions, workspace settings, and prompt files — so every suggestion matches your team's style."
difficulty: intermediate
duration: "25 minutes"
icon: "📝"
tags: ["custom-instructions", "configuration", "conventions", "prompt-files"]
prerequisites: ["GitHub Copilot extension installed", "Basic Copilot Chat experience", "A project with established coding conventions"]
objectives:
  - "Create and configure .github/copilot-instructions.md"
  - "Understand workspace-level and user-level instruction scoping"
  - "Use prompt files (.prompt.md) for reusable task templates"
  - "See how custom instructions change Copilot's output"
  - "Establish team-wide Copilot conventions"
lastUpdated: 2026-04-08
order: 6
---

# Custom Instructions & Project Context

Out of the box, GitHub Copilot makes reasonable suggestions based on general coding patterns. But *your* project has its own conventions — maybe you use a specific error-handling pattern, prefer functional components over class components, or always write tests with a particular structure. **Custom instructions** let you teach Copilot these preferences so every suggestion aligns with your team's style from the start.

---

## What You'll Learn

- How to create `.github/copilot-instructions.md` for repository-wide instructions
- Configuring workspace-level and user-level settings in VS Code
- Using **prompt files** (`.prompt.md`) for reusable, shareable task templates
- How instructions affect completions, chat responses, and edits
- Best practices for writing effective instructions

---

## Prerequisites

1. **VS Code** with the **GitHub Copilot extension** installed
2. Basic experience with **Copilot Chat** (inline or panel)
3. A project where you have established conventions you'd like Copilot to follow

---

## How Custom Instructions Work

Custom instructions are additional context that Copilot reads before generating any suggestion. They work at three levels:

| Level | Source | Scope |
|---|---|---|
| **Repository** | `.github/copilot-instructions.md` | Everyone working in the repo |
| **Workspace** | VS Code settings (`.vscode/settings.json`) | Your local workspace |
| **User** | VS Code user settings | All your projects globally |

Instructions at all levels are combined. Repository instructions are shared with your team via Git, making them the most impactful for consistency.

> **💡 Tip:** Repository-level instructions in `.github/copilot-instructions.md` are the single best way to improve Copilot's output for your project. Invest 10 minutes writing them and every team member benefits.

---

## Exercise 1 — Creating Repository Instructions

**Goal:** Create a `.github/copilot-instructions.md` file that teaches Copilot your project's conventions.

### Step 1: Create the file

In your project root, create the instructions file:

```bash
mkdir -p .github
touch .github/copilot-instructions.md
```

### Step 2: Write your instructions

Add conventions that apply to your entire codebase:

```markdown
# Copilot Instructions for This Project

## Language & Framework
- This is a TypeScript project using Node.js, Express, and Prisma ORM
- Always use TypeScript with strict mode — never use `any` type
- Use ES module imports (`import/export`), not CommonJS (`require`)

## Code Style
- Use `const` by default, `let` only when reassignment is necessary, never `var`
- Prefer arrow functions for callbacks and short functions
- Use template literals instead of string concatenation
- Always include return types on exported functions

## Error Handling
- Wrap async route handlers with the `asyncHandler()` utility from `src/middleware`
- Use the custom `AppError` class for all application errors
- Never swallow errors silently — always log or propagate them

## Testing
- Use Vitest for all tests
- Follow the Arrange-Act-Assert pattern
- Name test files as `*.test.ts` next to the source file
- Use `describe` blocks grouped by function/method name
- Mock external dependencies using `vi.mock()`

## Naming Conventions
- Use camelCase for variables and functions
- Use PascalCase for classes, interfaces, and type aliases
- Prefix interfaces with descriptive names (not `I` prefix)
- Use kebab-case for file names
```

### Step 3: Test the effect

Open a source file and start typing a new function. Compare the suggestions before and after adding the instructions. You should see:

- Arrow functions instead of `function` declarations for callbacks
- `const` usage by default
- Proper TypeScript types without `any`
- Error handling patterns matching your conventions

> **💡 Tip:** Keep instructions concise and specific. "Use Vitest for tests" is more useful than "Write good tests." Copilot responds best to concrete rules.

---

## Exercise 2 — Workspace-Level Instructions in VS Code

**Goal:** Configure Copilot instructions that apply to your local workspace through VS Code settings.

### Step 1: Open workspace settings

Open `.vscode/settings.json` in your project (create it if it doesn't exist):

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    {
      "text": "Always add JSDoc comments to exported functions with @param and @returns tags."
    },
    {
      "text": "Use the project's custom logger (import from '@/lib/logger') instead of console.log."
    },
    {
      "file": ".github/copilot-instructions.md"
    }
  ]
}
```

### Step 2: Understand the instruction sources

The `instructions` array accepts two formats:

- **Inline text:** `{ "text": "Your instruction here" }` — quick, local-only rules
- **File reference:** `{ "file": "path/to/file.md" }` — shared instructions from a file

### Step 3: Verify in Copilot Chat

Open Copilot Chat and ask it to generate a function:

```
Create a function that fetches user preferences from the database and caches them.
```

The response should include JSDoc comments and use your custom logger — matching the workspace instructions.

---

## Exercise 3 — Prompt Files for Reusable Tasks

**Goal:** Create `.prompt.md` files that serve as reusable templates for common development tasks.

### Step 1: Enable prompt files

In your VS Code settings, ensure prompt files are enabled:

```json
{
  "github.copilot.chat.promptFiles": true
}
```

### Step 2: Create a prompt file

Create `.github/prompts/new-api-endpoint.prompt.md`:

```markdown
# New API Endpoint

Create a new Express API endpoint following our project conventions:

## Requirements
- Use the `asyncHandler` wrapper from `src/middleware/async-handler`
- Validate input with Zod schemas
- Return consistent response format: `{ data, meta?, error? }`
- Include proper HTTP status codes (201 for creation, 204 for deletion)
- Add TypeScript types for request/response bodies

## File Structure
- Route handler in `src/routes/{resource}.ts`
- Service logic in `src/services/{resource}-service.ts`
- Zod schemas in `src/schemas/{resource}.ts`
- Tests in `src/services/{resource}-service.test.ts`

## Template

The endpoint should handle: {{description}}
For the resource: {{resource}}
```

### Step 3: Use the prompt file in Chat

In Copilot Chat, reference the prompt file:

```
@workspace /new-api-endpoint
description: CRUD operations for blog comments
resource: comments
```

Copilot uses the template to generate a complete, convention-compliant set of files.

### Step 4: Create more prompt files

Build a library of prompts for your team's common tasks:

```
.github/prompts/
├── new-api-endpoint.prompt.md
├── new-react-component.prompt.md
├── add-database-migration.prompt.md
└── write-integration-test.prompt.md
```

> **💡 Tip:** Prompt files are like reusable recipes. They encode your team's best practices into templates that any team member (and Copilot) can follow consistently.

---

## Exercise 4 — Measuring the Impact of Instructions

**Goal:** Compare Copilot's output with and without custom instructions to see the concrete difference.

### Step 1: Baseline without instructions

Temporarily rename your `.github/copilot-instructions.md` to `.github/copilot-instructions.md.bak`.

Open a new TypeScript file and ask Copilot Chat:

```
Create an Express route handler that creates a new user with email validation.
```

Note the style: Does it use `any`? Does it use your error handling pattern? Does it follow your conventions?

### Step 2: Restore instructions

Rename the file back to `.github/copilot-instructions.md`.

Ask the same question again in a new chat session.

### Step 3: Compare the results

You should see differences like:

| Without Instructions | With Instructions |
|---|---|
| Uses `function` declarations | Uses arrow functions |
| Generic error handling | Uses `AppError` class |
| No input validation library | Uses Zod schemas |
| `console.log` for logging | Uses custom logger |
| Missing return types | Explicit return types on exports |

> **💡 Tip:** This before/after comparison is a great way to demonstrate the value of custom instructions to your team. The quality improvement is usually dramatic.

---

## Writing Effective Instructions

### Do ✅

- Be **specific and concrete**: "Use Zod for validation" not "Validate input"
- Include **framework and library names**: "Use Prisma ORM for database access"
- Specify **patterns with examples**: "Wrap async handlers with asyncHandler()"
- Keep instructions **concise**: Aim for 20–40 clear rules
- Update instructions when conventions **evolve**

### Don't ❌

- Write **vague guidelines**: "Write clean code" gives Copilot nothing to act on
- Include **entire style guides**: Copilot works best with focused, actionable rules
- Add **contradictory instructions**: Resolve conflicts before committing
- Forget to **commit the file**: Repository instructions only help the team if they're in Git

---

## Summary

In this workshop you learned how to:

1. **Create `.github/copilot-instructions.md`** for shared, repository-wide conventions
2. **Configure workspace settings** for local instruction overrides
3. **Build prompt files** (`.prompt.md`) for reusable task templates
4. **Measure the impact** of instructions on Copilot's output quality

Custom instructions transform Copilot from a generic assistant into a team member who knows your codebase. The small upfront investment pays dividends on every suggestion.

---

## Next Steps

- **[Extensions & MCP Servers →](./extensions-mcp)** — Extend Copilot with external tools and data sources.
- **[Copilot Edits →](./copilot-edits)** — Use Copilot Edits for multi-file changes that follow your conventions.
