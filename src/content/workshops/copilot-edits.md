---
title: "Copilot Edits: Multi-File Editing"
description: "Master Copilot Edits to make coordinated changes across multiple files in a single workflow — refactor, add features, and iterate on code with AI-driven multi-file editing."
difficulty: intermediate
duration: "40 minutes"
icon: "✏️"
tags: ["copilot-edits", "multi-file", "refactoring", "productivity"]
prerequisites: ["VS Code with GitHub Copilot extension", "Basic understanding of Copilot Chat", "A project with multiple source files"]
objectives:
  - "Open and use the Copilot Edits panel in VS Code"
  - "Make coordinated changes across multiple files in one request"
  - "Iterate on AI-generated edits with follow-up instructions"
  - "Refactor code across module boundaries"
  - "Add new features that span multiple files using Edits mode"
lastUpdated: 2026-04-08
order: 5
---

# Copilot Edits: Multi-File Editing

Single-file completions are powerful, but real-world development means changing multiple files at once — updating a service, its tests, its types, and its route handler in one coordinated sweep. **Copilot Edits** is designed for exactly this. It lets you describe a change in natural language, select the files involved, and have Copilot apply edits across all of them simultaneously.

Think of it as directing an AI pair programmer who can see and modify your entire working set at once.

---

## What You'll Learn

- How to open the **Copilot Edits** panel in VS Code
- Selecting files for multi-file editing sessions
- Describing changes in natural language and reviewing proposed edits
- Iterating on edits with follow-up instructions
- Best practices for effective multi-file prompts

---

## Prerequisites

1. **VS Code** (v1.96 or later recommended) with the **GitHub Copilot extension**
2. A project with **multiple source files** (e.g., a web app with components, services, and tests)
3. Familiarity with **Copilot Chat** basics (see the Copilot Chat workshop first if needed)

---

## How Copilot Edits Works

```
┌──────────────────────────────────────┐
│           You Describe the Change    │
│  "Add error handling to all API      │
│   routes and update their tests"     │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         Copilot Edits Analyzes       │
│  - Reads all selected files          │
│  - Plans coordinated changes         │
│  - Generates diffs for each file     │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│         You Review & Accept          │
│  - See inline diffs per file         │
│  - Accept, reject, or refine each    │
│  - Iterate with follow-up prompts    │
└──────────────────────────────────────┘
```

> **💡 Tip:** Copilot Edits works best when you scope the file set tightly. Include only the files relevant to your change — not your entire project.

---

## Exercise 1 — Your First Multi-File Edit

**Goal:** Use Copilot Edits to rename a function across a service file, its test file, and any importing modules.

### Step 1: Open the Edits panel

Open VS Code and press **Ctrl+Shift+I** (Windows/Linux) or **Cmd+Shift+I** (macOS) to open the Copilot Edits panel. Alternatively, click the Copilot Edits icon in the sidebar.

### Step 2: Add files to the working set

Click **"Add Files"** and select:
- `src/services/user-service.ts`
- `src/services/user-service.test.ts`
- `src/routes/users.ts`

These are the files that reference the function you want to rename.

### Step 3: Describe the change

In the Edits input, type:

```
Rename the function `getUser` to `findUserById` in all selected files.
Update all references, including test descriptions and route handler calls.
```

### Step 4: Review the proposed edits

Copilot shows inline diffs for each file:

**user-service.ts:**
```diff
- export async function getUser(id: string): Promise<User | null> {
+ export async function findUserById(id: string): Promise<User | null> {
    return db.users.findUnique({ where: { id } });
  }
```

**user-service.test.ts:**
```diff
- import { getUser } from "./user-service";
+ import { findUserById } from "./user-service";

- describe("getUser", () => {
+ describe("findUserById", () => {
-   it("should return a user when given a valid ID", async () => {
-     const user = await getUser("user-123");
+   it("should return a user when given a valid ID", async () => {
+     const user = await findUserById("user-123");
```

**users.ts:**
```diff
- import { getUser } from "../services/user-service";
+ import { findUserById } from "../services/user-service";

  router.get("/:id", async (req, res) => {
-   const user = await getUser(req.params.id);
+   const user = await findUserById(req.params.id);
```

### Step 5: Accept the edits

Click **"Accept All"** to apply all changes, or review each file individually with **"Accept"** / **"Discard"** buttons.

> **💡 Tip:** After accepting edits, run your tests immediately to verify nothing broke. The rename should be fully consistent if Copilot caught all references.

---

## Exercise 2 — Refactoring Across Files

**Goal:** Extract shared logic into a new utility module and update all files that use it.

### Step 1: Set up the working set

Add these files to Copilot Edits:
- `src/routes/posts.ts`
- `src/routes/comments.ts`
- `src/routes/users.ts`

### Step 2: Describe the refactoring

```
Each of these route files has a duplicated error-handling pattern with try/catch
blocks. Extract the common pattern into a new `src/middleware/async-handler.ts`
utility that wraps async route handlers. Then update all three route files to
use the new wrapper instead of manual try/catch.
```

### Step 3: Review the generated code

Copilot will create the new utility file and modify the existing routes:

**New file — `src/middleware/async-handler.ts`:**
```typescript
import { Request, Response, NextFunction, RequestHandler } from "express";

export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<void>
): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
```

**Updated routes — e.g., `src/routes/posts.ts`:**
```diff
+ import { asyncHandler } from "../middleware/async-handler";

- router.get("/", async (req, res, next) => {
-   try {
-     const posts = await db.posts.findMany();
-     res.json(posts);
-   } catch (error) {
-     next(error);
-   }
- });
+ router.get("/", asyncHandler(async (req, res) => {
+   const posts = await db.posts.findMany();
+   res.json(posts);
+ }));
```

### Step 4: Iterate if needed

If the first pass misses a file or handles one differently, type a follow-up:

```
Also update the DELETE handlers in posts.ts and comments.ts to use asyncHandler.
```

Copilot applies the additional changes without touching what you already accepted.

> **💡 Tip:** Copilot Edits remembers the conversation context within a session. Use follow-up prompts to refine rather than starting over.

---

## Exercise 3 — Adding a Feature Across Files

**Goal:** Add a new feature that requires changes to a model, service, route, and test file.

### Step 1: Select the relevant files

Add to Copilot Edits:
- `src/models/post.ts`
- `src/services/post-service.ts`
- `src/routes/posts.ts`
- `src/services/post-service.test.ts`

### Step 2: Describe the feature

```
Add a "tags" feature to posts:
1. Add a `tags: string[]` field to the Post model
2. Update the PostService to support filtering posts by tag
3. Add a `?tag=` query parameter to the GET /api/posts route
4. Add tests for tag filtering in the test file
```

### Step 3: Review the coordinated changes

Copilot generates changes across all four files:

**post.ts** — adds the field:
```typescript
export interface Post {
  id: string;
  title: string;
  content: string;
  tags: string[];     // new
  createdAt: Date;
}
```

**post-service.ts** — adds filtering:
```typescript
async findPosts(options?: { tag?: string }): Promise<Post[]> {
  const query = options?.tag
    ? { where: { tags: { has: options.tag } } }
    : {};
  return db.posts.findMany({ ...query, orderBy: { createdAt: "desc" } });
}
```

**posts.ts** — adds query parameter:
```typescript
router.get("/", asyncHandler(async (req, res) => {
  const tag = req.query.tag as string | undefined;
  const posts = await postService.findPosts({ tag });
  res.json(posts);
}));
```

**post-service.test.ts** — adds test cases:
```typescript
describe("findPosts with tag filter", () => {
  it("returns only posts matching the given tag", async () => {
    const posts = await postService.findPosts({ tag: "typescript" });
    expect(posts.every(p => p.tags.includes("typescript"))).toBe(true);
  });

  it("returns all posts when no tag is specified", async () => {
    const all = await postService.findPosts();
    expect(all.length).toBeGreaterThan(0);
  });
});
```

### Step 4: Accept and verify

Accept all edits, then run:

```bash
npm test -- --grep "tag"
```

> **💡 Tip:** When adding a feature, list the changes you expect in numbered steps. This helps Copilot produce coordinated, consistent edits across files.

---

## Exercise 4 — Iterating on Edits

**Goal:** Practice the iterative workflow — make a request, review, refine, repeat.

### Step 1: Start with a broad request

```
Convert all callback-based error handling in the selected files to use
a custom AppError class with HTTP status codes.
```

### Step 2: Review and identify gaps

Copilot may introduce the `AppError` class and update most error throws, but miss some edge cases.

### Step 3: Send a follow-up

```
You missed the validation errors in users.ts — those should throw
AppError with status 400 instead of returning res.status(400) directly.
```

### Step 4: Continue until satisfied

Each follow-up refines the changes. You can also ask:

```
Show me a summary of all changes made in this session.
```

---

## Best Practices for Copilot Edits

- **Scope tightly.** Add only the files relevant to your change. Fewer files = better understanding = better edits.
- **Be specific.** "Add pagination to the posts list" is better than "improve the posts feature."
- **Describe the *what* and *why*.** "Extract the retry logic into a utility so it can be reused across services" gives Copilot more context than "refactor the retry logic."
- **Iterate in small steps.** Make one conceptual change per prompt. Complex multi-part changes are better handled as a sequence of smaller edits.
- **Review every diff.** Always read the proposed changes before accepting. Copilot may miss context that isn't in the selected files.

---

## Summary

In this workshop you learned how to:

1. **Open and use** the Copilot Edits panel in VS Code
2. **Rename symbols** across multiple files consistently
3. **Refactor shared logic** into new modules and update consumers
4. **Add features** that span models, services, routes, and tests
5. **Iterate** on edits with follow-up prompts for refinement

Copilot Edits is your tool for any change that touches more than one file. Combined with single-file completions and Copilot Chat, you have a complete AI-assisted editing toolkit.

---

## Next Steps

- **[Custom Instructions →](./custom-instructions)** — Configure Copilot to follow your project's conventions automatically.
- **[Extensions & MCP Servers →](./extensions-mcp)** — Extend Copilot with custom tools and external data sources.
