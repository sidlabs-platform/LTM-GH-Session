---
title: "Mastering Code Completion with GitHub Copilot"
description: "Learn to harness GitHub Copilot's inline suggestions to write code faster. Practice accepting, rejecting, and partially accepting completions, generate entire functions, and let Copilot help you write tests."
difficulty: beginner
duration: "30 minutes"
icon: "⚡"
tags: ["code-completion", "inline-suggestions", "productivity", "beginner"]
prerequisites: ["VS Code installed", "GitHub Copilot extension installed and activated", "Basic JavaScript/TypeScript knowledge"]
objectives:
  - "Understand how Copilot's inline suggestions work"
  - "Accept, reject, and partially accept completions"
  - "Generate multi-line completions and entire functions"
  - "Use Copilot to write unit tests from descriptions"
  - "Complete a class with Copilot-assisted methods"
lastUpdated: 2026-04-08
order: 1
---

GitHub Copilot's code completion is the feature you'll use most often. It watches what you type and suggests the next line — or the next fifty lines — based on context from your file, open tabs, and the broader pattern of your code. This workshop walks you through practical exercises so you can build muscle memory and get the most out of every suggestion.

## What You'll Learn

- How inline suggestions appear and how to navigate them
- Accepting full suggestions, dismissing them, and using **partial accepts** (word-by-word)
- Generating multi-line code blocks and entire functions from comments
- Letting Copilot scaffold unit tests from natural-language descriptions
- Building out a class with Copilot filling in method bodies

## Prerequisites

Before you begin, make sure you have:

1. **Visual Studio Code** (v1.90 or later recommended)
2. **GitHub Copilot extension** installed and signed in with an active subscription
3. A basic understanding of **JavaScript or TypeScript** (the examples use both)

Open a new workspace or an empty project folder to follow along.

---

## Exercise 1 — Your First Inline Suggestion

**Goal:** See how Copilot offers completions and learn the keyboard shortcuts to accept or dismiss them.

### Step 1: Create a new file

Create a file called `utils.ts` and type the following function signature:

```typescript
function reverseString(str: string): string {
```

Pause after the opening brace. Within a second or two, Copilot will show a ghost-text suggestion for the function body.

### Step 2: Accept the suggestion

Press **Tab** to accept the full suggestion. You should see something like:

```typescript
function reverseString(str: string): string {
  return str.split("").reverse().join("");
}
```

### Step 3: Dismiss and cycle through alternatives

Undo the acceptance (`Cmd+Z` / `Ctrl+Z`), then try these shortcuts:

| Action | macOS | Windows / Linux |
|---|---|---|
| Accept suggestion | `Tab` | `Tab` |
| Dismiss suggestion | `Esc` | `Esc` |
| Next suggestion | `Option+]` | `Alt+]` |
| Previous suggestion | `Option+[` | `Alt+[` |

Cycle through two or three alternatives to see how Copilot offers different implementations (e.g., using a `for` loop instead of `split/reverse/join`).

> **💡 Tip:** If no suggestion appears, start typing the first token of the body (e.g., `return`) and Copilot will kick in.

---

## Exercise 2 — Partial Accepts (Word-by-Word)

**Goal:** Accept only *part* of a suggestion when Copilot's full completion overshoots what you want.

### Step 1: Set up the context

Add a new function signature to your file:

```typescript
function formatCurrency(amount: number, currency: string): string {
```

### Step 2: Use partial accept

When the ghost text appears, instead of pressing **Tab**, press:

- **Cmd+→** (macOS) or **Ctrl+→** (Windows/Linux) to accept **one word** at a time.

Watch the ghost text shorten word by word. This is invaluable when Copilot gets the first half right but you want to diverge midway.

### Step 3: Complete the function your way

Accept words until the suggestion no longer matches your intent, then type the rest yourself. A reasonable result:

```typescript
function formatCurrency(amount: number, currency: string): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
  }).format(amount);
}
```

> **💡 Tip:** Partial accepts are one of the most underused Copilot features. They let you stay in flow without accepting code you'll immediately delete.

---

## Exercise 3 — Generating Functions from Comments

**Goal:** Write a plain-English comment and let Copilot generate the entire implementation.

### Step 1: Write a descriptive comment

In your `utils.ts` file, type:

```typescript
// Debounce a function so it only executes after the caller
// stops invoking it for the specified delay in milliseconds.
```

### Step 2: Trigger the completion

Press **Enter** after the comment and start typing the function keyword:

```typescript
function debounce
```

Copilot should suggest the full signature and body. Accept it with **Tab**:

```typescript
function debounce<T extends (...args: unknown[]) => void>(
  fn: T,
  delayMs: number
): (...args: Parameters<T>) => void {
  let timeoutId: ReturnType<typeof setTimeout>;
  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delayMs);
  };
}
```

### Step 3: Verify the output

Read through the generated code. Check that:

- [x] It returns a wrapper function with the same parameter signature
- [x] It clears any existing timeout before setting a new one
- [x] It uses `setTimeout` with the provided delay

> **💡 Tip:** The more descriptive your comment, the better the suggestion. Mention edge cases or return types explicitly to guide Copilot.

---

## Exercise 4 — Writing Tests from Descriptions

**Goal:** Let Copilot generate unit tests from a simple description of expected behavior.

### Step 1: Create a test file

Create `utils.test.ts` next to your `utils.ts` file and start with:

```typescript
import { describe, it, expect } from "vitest";
import { reverseString, formatCurrency, debounce } from "./utils";
```

### Step 2: Describe the first test suite

Type the opening of a test block:

```typescript
describe("reverseString", () => {
  it("should reverse a simple string", () => {
```

Copilot will suggest the assertion:

```typescript
    expect(reverseString("hello")).toBe("olleh");
```

Accept it and close the blocks.

### Step 3: Let Copilot generate additional tests

After the first `it` block, press **Enter** and start a new `it(` — Copilot will suggest the next logical test case:

```typescript
  it("should return an empty string when given an empty string", () => {
    expect(reverseString("")).toBe("");
  });

  it("should handle a single character", () => {
    expect(reverseString("a")).toBe("a");
  });
```

Continue accepting suggestions until you have 4-5 test cases.

### Step 4: Add tests for `formatCurrency`

Start a new `describe` block:

```typescript
describe("formatCurrency", () => {
  it("should format USD correctly", () => {
    expect(formatCurrency(1234.5, "USD")).toBe("$1,234.50");
  });
```

Let Copilot suggest additional currency tests (EUR, GBP, edge cases like `0`).

> **💡 Tip:** Copilot is excellent at generating test variations once it sees the pattern. Write the first test manually to set the style, then let Copilot fill in the rest.

---

## Exercise 5 — Completing a Class

**Goal:** Scaffold a class and let Copilot generate method implementations from signatures and comments.

### Step 1: Define the class shell

Create a new file `TaskManager.ts`:

```typescript
interface Task {
  id: string;
  title: string;
  completed: boolean;
  createdAt: Date;
}

class TaskManager {
  private tasks: Map<string, Task> = new Map();

  // Add a new task and return it
  addTask(title: string): Task {
```

### Step 2: Accept the generated body

Copilot should fill in the method:

```typescript
  addTask(title: string): Task {
    const task: Task = {
      id: crypto.randomUUID(),
      title,
      completed: false,
      createdAt: new Date(),
    };
    this.tasks.set(task.id, task);
    return task;
  }
```

### Step 3: Continue with more methods

After the closing brace, type a comment and signature for the next method:

```typescript
  // Mark a task as completed by ID. Throws if not found.
  completeTask(id: string): Task {
```

Accept Copilot's suggestion and repeat for:

```typescript
  // Remove a task by ID. Returns true if deleted, false if not found.
  removeTask(id: string): boolean {

  // Return all incomplete tasks sorted by creation date (oldest first).
  getPendingTasks(): Task[] {
```

By the third or fourth method, Copilot will be deeply attuned to your class's patterns and the suggestions will require almost no editing.

> **💡 Tip:** Open related files (like interfaces or existing implementations) in other tabs. Copilot uses open-tab context to improve its suggestions.

---

## Tips & Tricks

- **Name things well.** Descriptive function names and parameter names are the single biggest lever for suggestion quality.
- **Use TypeScript types.** Type annotations give Copilot a stronger signal about what you expect, leading to more accurate completions.
- **Open related files.** Copilot considers content from neighboring tabs, so keep interfaces, utilities, and tests open together.
- **Write the comment first.** A one-line comment above a function signature dramatically improves multi-line suggestions.
- **Don't fight Copilot.** If a suggestion is wrong, dismiss it and add more context (a comment, a type annotation, or the first line of the body) instead of repeatedly cycling through alternatives.

---

## Summary

In this workshop you learned how to:

1. **Accept and dismiss** inline suggestions with keyboard shortcuts
2. **Partially accept** suggestions word-by-word for fine-grained control
3. **Generate functions** from descriptive comments
4. **Scaffold unit tests** by writing the first test and letting Copilot continue
5. **Build out a class** method-by-method with Copilot completing each body

These fundamentals apply everywhere — whether you're writing backend APIs, frontend components, or infrastructure scripts.

---

## Next Steps

- **[Copilot Chat →](./copilot-chat)** — Learn to have conversations with Copilot to explain, refactor, and debug code interactively.
- **[Copilot in the CLI →](./copilot-cli)** — Take Copilot to the terminal and let it suggest shell commands.
