---
title: "Conversational Coding with Copilot Chat"
description: "Go beyond inline suggestions and learn to use Copilot Chat for explaining code, refactoring, generating tests, and fixing bugs — all through natural-language conversation inside your editor."
difficulty: beginner
duration: "45 minutes"
icon: "💬"
tags: ["copilot-chat", "slash-commands", "refactoring", "debugging", "testing"]
prerequisites: ["VS Code installed", "GitHub Copilot Chat extension installed", "Completed the Code Completion workshop (recommended)"]
objectives:
  - "Use the Chat panel and inline chat to converse with Copilot"
  - "Master slash commands: /explain, /fix, /tests, /doc"
  - "Reference context precisely with @workspace, #file, and #selection"
  - "Refactor code through conversational prompts"
  - "Generate comprehensive tests with chat-driven workflows"
  - "Debug and fix errors using Copilot Chat"
lastUpdated: 2026-04-08
order: 2
---

Copilot Chat turns GitHub Copilot from an autocomplete engine into a coding partner you can talk to. Ask it to explain unfamiliar code, refactor a messy function, generate tests, or diagnose a bug — all without leaving your editor. This workshop gives you hands-on practice with every major Chat feature so you can weave it into your daily workflow.

## What You'll Learn

- Opening and using the **Chat panel** vs. **inline chat**
- Slash commands that shortcut common tasks (`/explain`, `/fix`, `/tests`, `/doc`)
- Context references (`@workspace`, `#file`, `#selection`) for precise, grounded answers
- Real workflows: explaining code, refactoring, test generation, and bug fixing

## Prerequisites

1. **Visual Studio Code** (v1.90+)
2. **GitHub Copilot Chat extension** installed and signed in
3. A project to work in — clone any small repo or use the `utils.ts` / `TaskManager.ts` files from the Code Completion workshop

---

## Understanding Chat Surfaces

Copilot Chat is available in two places:

| Surface | How to open | Best for |
|---|---|---|
| **Chat panel** | `Ctrl+Alt+I` / `Cmd+Alt+I` or click the chat icon in the sidebar | Longer conversations, multi-step tasks |
| **Inline chat** | `Ctrl+I` / `Cmd+I` with cursor in the editor | Quick, targeted edits on selected code |

Both surfaces accept the same slash commands and context references.

---

## Exercise 1 — Explaining Code with `/explain`

**Goal:** Use Copilot Chat to understand an unfamiliar piece of code.

### Step 1: Paste or open some complex code

Create a file called `parser.ts` with the following:

```typescript
function parseQueryString(qs: string): Record<string, string> {
  return qs
    .replace(/^\?/, "")
    .split("&")
    .filter(Boolean)
    .reduce<Record<string, string>>((acc, pair) => {
      const [key, ...rest] = pair.split("=");
      acc[decodeURIComponent(key)] = decodeURIComponent(rest.join("="));
      return acc;
    }, {});
}
```

### Step 2: Select the code and ask for an explanation

1. Select the entire function body.
2. Open inline chat (`Cmd+I` / `Ctrl+I`).
3. Type: `/explain`

Copilot will return a step-by-step breakdown:

> *"This function takes a query string like `?name=Alice&age=30`, strips the leading `?`, splits on `&`, then reduces each key=value pair into an object. It handles values that contain `=` by splitting only on the first occurrence and joining the rest…"*

### Step 3: Ask follow-up questions

In the same chat, ask:

```
What happens if the same key appears twice in the query string?
```

Copilot will explain that the current implementation overwrites the earlier value — and may suggest using an array-based approach if you need to preserve duplicates.

> **💡 Tip:** You don't need to select code to use `/explain`. You can also type `/explain #file:parser.ts` in the Chat panel to explain an entire file.

---

## Exercise 2 — Refactoring with Inline Chat

**Goal:** Use conversational prompts to refactor code without manually rewriting it.

### Step 1: Start with code that needs improvement

Add this function to `parser.ts`:

```typescript
function fetchUserData(userId: string) {
  return fetch(`https://api.example.com/users/${userId}`)
    .then((res) => {
      if (!res.ok) {
        throw new Error("Failed to fetch user");
      }
      return res.json();
    })
    .then((data) => {
      return {
        id: data.id,
        name: data.name,
        email: data.email,
        createdAt: new Date(data.created_at),
      };
    })
    .catch((err) => {
      console.error(err);
      throw err;
    });
}
```

### Step 2: Select the function and request a refactor

1. Select the entire `fetchUserData` function.
2. Open inline chat (`Cmd+I` / `Ctrl+I`).
3. Type: `Refactor this to use async/await with proper TypeScript types`

### Step 3: Review the suggested refactor

Copilot should propose something like:

```typescript
interface User {
  id: string;
  name: string;
  email: string;
  createdAt: Date;
}

async function fetchUserData(userId: string): Promise<User> {
  const res = await fetch(`https://api.example.com/users/${userId}`);

  if (!res.ok) {
    throw new Error(`Failed to fetch user: ${res.status} ${res.statusText}`);
  }

  const data = await res.json();

  return {
    id: data.id,
    name: data.name,
    email: data.email,
    createdAt: new Date(data.created_at),
  };
}
```

4. Click **Accept** to apply the change, or **Discard** to keep the original.

> **💡 Tip:** Be specific in your refactoring prompts. "Refactor this" is vague. "Convert to async/await, extract an interface, and improve the error message" tells Copilot exactly what you want.

---

## Exercise 3 — Generating Tests with `/tests`

**Goal:** Generate a full test suite for an existing function using the `/tests` slash command.

### Step 1: Select the function to test

Open `parser.ts` and select the `parseQueryString` function.

### Step 2: Use the `/tests` command

Open the Chat panel (`Ctrl+Alt+I` / `Cmd+Alt+I`) and type:

```
/tests #selection
```

Copilot will generate a test file. The output will look similar to:

```typescript
import { describe, it, expect } from "vitest";
import { parseQueryString } from "./parser";

describe("parseQueryString", () => {
  it("should parse a simple query string", () => {
    expect(parseQueryString("?name=Alice&age=30")).toEqual({
      name: "Alice",
      age: "30",
    });
  });

  it("should handle a query string without a leading ?", () => {
    expect(parseQueryString("name=Alice")).toEqual({ name: "Alice" });
  });

  it("should return an empty object for an empty string", () => {
    expect(parseQueryString("")).toEqual({});
  });

  it("should decode URI components", () => {
    expect(parseQueryString("?city=New%20York")).toEqual({
      city: "New York",
    });
  });

  it("should handle values containing =", () => {
    expect(parseQueryString("?formula=a%3Db%2Bc")).toEqual({
      formula: "a=b+c",
    });
  });
});
```

### Step 3: Refine the tests

Ask a follow-up in the same chat:

```
Add edge-case tests for duplicate keys and keys with no value
```

Copilot will append additional test cases:

```typescript
  it("should overwrite duplicate keys with the last value", () => {
    expect(parseQueryString("?a=1&a=2")).toEqual({ a: "2" });
  });

  it("should handle keys with no value", () => {
    expect(parseQueryString("?key=&other=value")).toEqual({
      key: "",
      other: "value",
    });
  });
```

> **💡 Tip:** After generating tests, always review them for correctness. Copilot generates structurally sound tests, but the expected values should be verified against the actual function behavior.

---

## Exercise 4 — Fixing Bugs with `/fix`

**Goal:** Use Copilot Chat to diagnose and fix a bug in your code.

### Step 1: Introduce a buggy function

Add this to a new file `validators.ts`:

```typescript
function isValidEmail(email: string): boolean {
  const pattern = /^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]{2,}$/;
  return pattern.test(email);
}

// Bug: these valid emails are rejected
// "user.name@example.com"    → false (should be true)
// "user+tag@example.co.uk"   → false (should be true)
```

### Step 2: Select the function and use `/fix`

1. Select the `isValidEmail` function **and** the comments showing the bug.
2. Open inline chat and type: `/fix`

### Step 3: Review the fix

Copilot identifies that the regex doesn't allow dots, plus signs, or hyphens in the local part, and doesn't support multi-level domains:

```typescript
function isValidEmail(email: string): boolean {
  const pattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  return pattern.test(email);
}
```

### Step 4: Verify the fix

Ask Copilot in the chat:

```
Does this fix handle the two failing cases from the comments?
```

Copilot will confirm that `user.name@example.com` and `user+tag@example.co.uk` now pass.

> **💡 Tip:** Including the failing test cases or error messages in your selection gives Copilot the signal it needs to pinpoint the problem. The more context you provide, the better the fix.

---

## Exercise 5 — Using Context References

**Goal:** Learn to direct Copilot Chat to specific files and code using `@workspace`, `#file`, and `#selection`.

### Context reference cheat sheet

| Reference | What it does | Example |
|---|---|---|
| `@workspace` | Searches your entire workspace for relevant context | `@workspace how is authentication handled?` |
| `#file:path` | Includes a specific file's content | `#file:src/parser.ts explain the exports` |
| `#selection` | Uses the currently selected code | `/tests #selection` |

### Step 1: Ask a workspace-wide question

Open the Chat panel and type:

```
@workspace What utility functions are available and what do they do?
```

Copilot will scan your workspace and return a summary of functions across your files.

### Step 2: Reference a specific file

```
#file:validators.ts What edge cases are not covered by isValidEmail?
```

Copilot will analyze the specific file and list uncovered cases (e.g., internationalized domain names, very long addresses).

### Step 3: Combine references

```
Generate a function in #file:parser.ts that converts a Record<string, string> back into a query string. Make it the inverse of parseQueryString.
```

Copilot reads `parseQueryString` from the referenced file and generates a matching `toQueryString` function.

> **💡 Tip:** Context references are how you prevent Copilot from hallucinating. When you anchor a question to a specific file or selection, the answer is grounded in your actual code.

---

## Exercise 6 — Documenting Code with `/doc`

**Goal:** Automatically generate JSDoc comments for your functions.

### Step 1: Select an undocumented function

Select the `parseQueryString` function in `parser.ts`.

### Step 2: Run `/doc`

Open inline chat and type: `/doc`

Copilot will insert a JSDoc block above the function:

```typescript
/**
 * Parses a URL query string into a key-value record.
 *
 * @param qs - The query string to parse (with or without a leading "?")
 * @returns A record mapping decoded parameter names to their decoded values
 *
 * @example
 * parseQueryString("?name=Alice&age=30")
 * // => { name: "Alice", age: "30" }
 */
function parseQueryString(qs: string): Record<string, string> {
```

### Step 3: Generate docs for all functions

In the Chat panel, type:

```
#file:parser.ts Add JSDoc comments to every exported function in this file
```

Copilot will produce documentation for each function in one go.

> **💡 Tip:** `/doc` follows the documentation conventions already present in your codebase. If you use TSDoc or a custom style, Copilot will match it.

---

## Tips & Tricks

- **Start broad, then narrow.** Begin with `@workspace` questions to explore, then use `#file` and `#selection` for precision.
- **Use follow-up messages.** Chat conversations maintain context. Ask "now add error handling" or "make that function generic" as follow-ups instead of starting a new chat.
- **Combine slash commands.** You can chain requests: `/explain this, then suggest how to refactor it for better performance`.
- **Pin important chats.** If a conversation produced a useful plan or architecture decision, pin it in the chat history for easy reference.
- **Iterate, don't accept blindly.** Treat the first response as a draft. Ask Copilot to improve, simplify, or handle additional edge cases.

---

## Summary

In this workshop you learned how to:

1. **Explain code** — Use `/explain` and `#selection` to quickly understand unfamiliar code
2. **Refactor** — Describe the transformation you want in natural language and let Copilot rewrite the code
3. **Generate tests** — Use `/tests` to scaffold a full test suite, then refine with follow-up prompts
4. **Fix bugs** — Provide failing cases alongside code and use `/fix` to get targeted repairs
5. **Use context references** — Ground Copilot's answers in your actual codebase with `@workspace`, `#file`, and `#selection`
6. **Document code** — Automatically generate JSDoc with `/doc`

---

## Next Steps

- **[← Code Completion](./code-completion)** — Review inline suggestion fundamentals if you skipped the first workshop.
- **[Copilot in the CLI →](./copilot-cli)** — Take your Copilot skills to the terminal and learn to generate shell commands conversationally.
