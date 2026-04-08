---
title: "Building Custom Copilot Extensions"
description: "Learn to build full GitHub Copilot Extensions — from architecture and agent design to deployment on the GitHub Marketplace."
difficulty: advanced
duration: "60 minutes"
icon: "🧩"
tags: ["extensions", "copilot-extensions", "agents", "marketplace", "advanced"]
prerequisites: ["Strong Node.js or Python skills", "Experience with MCP servers", "Understanding of GitHub Apps and OAuth"]
objectives:
  - "Understand the Copilot Extensions architecture"
  - "Build a Copilot Extension with custom agent logic"
  - "Handle user messages and generate streaming responses"
  - "Integrate external APIs and services"
  - "Prepare an extension for the GitHub Marketplace"
lastUpdated: 2026-04-08
order: 4
---

# Building Custom Copilot Extensions

Copilot Extensions go beyond MCP servers — they're full-featured integrations with their own identity, icon, and capabilities in the Copilot ecosystem. When a user types `@your-extension` in Chat, your code handles the conversation, calls APIs, runs computations, and returns rich responses. If you've built an MCP server, you know how to give Copilot tools. Extensions let you build an entirely new AI-powered experience within the Copilot interface.

---

## What You'll Learn

- The **architecture** of Copilot Extensions (GitHub Apps + agent endpoints)
- Building an **agent endpoint** that handles Copilot messages
- Implementing **streaming responses** for real-time feedback
- Integrating with **external APIs and services**
- Packaging and publishing to the **GitHub Marketplace**

---

## Prerequisites

1. Strong **Node.js or Python** development skills
2. Experience building **MCP servers** (see the MCP Servers workshop)
3. Understanding of **GitHub Apps** and OAuth authorization flows
4. A GitHub account with permissions to **create GitHub Apps**

---

## Extension Architecture

A Copilot Extension has three components:

```
┌───────────────┐       ┌──────────────────┐       ┌─────────────┐
│  GitHub App   │       │  Agent Endpoint   │       │  External   │
│  (identity)   │──────▶│  (your server)    │──────▶│  APIs/Data  │
│               │       │                   │       │             │
│  - Name/Icon  │       │  - Handles msgs   │       │  - DBs      │
│  - Permissions│       │  - Calls APIs     │       │  - SaaS     │
│  - OAuth      │       │  - Returns text   │       │  - Internal │
└───────────────┘       └──────────────────┘       └─────────────┘
```

When a user sends `@your-extension How many open bugs do we have?`:

1. GitHub routes the message to your **agent endpoint**
2. Your server processes the message, calls relevant APIs
3. Your server **streams a response** back to the user
4. The response appears in Copilot Chat with your extension's identity

> **💡 Tip:** Extensions are essentially chatbots that live inside Copilot Chat. But they have access to the user's GitHub context and can call MCP tools, making them much more powerful than a standalone bot.

---

## Exercise 1 — Creating the GitHub App

**Goal:** Set up the GitHub App that serves as your extension's identity.

### Step 1: Create a new GitHub App

Go to **GitHub Settings → Developer Settings → GitHub Apps → New GitHub App**.

Configure:

```
App name: My Project Assistant
Description: AI-powered assistant for project management
Homepage URL: https://github.com/your-org/your-extension

Webhook: (unchecked — not needed for Copilot Extensions)

Permissions:
  - Issues: Read & Write
  - Pull Requests: Read
  - Contents: Read

Copilot Agent:
  - Agent URL: https://your-server.example.com/agent
  - Agent type: Copilot Agent
```

### Step 2: Note the credentials

After creation, save:
- **App ID** — needed for authentication
- **Client ID** and **Client Secret** — for OAuth
- **Private Key** — generate and download for API calls

### Step 3: Install the App

Install the GitHub App on your organization or personal account. Select the repositories it should have access to.

---

## Exercise 2 — Building the Agent Endpoint

**Goal:** Create a server that handles Copilot messages and returns responses.

### Step 1: Set up the project

```bash
mkdir copilot-extension && cd copilot-extension
npm init -y
npm install express @octokit/webhooks @octokit/rest
npm install -D typescript @types/node @types/express tsx
```

### Step 2: Create the agent handler

Create `src/agent.ts`:

```typescript
import express from "express";
import { Octokit } from "@octokit/rest";

const app = express();
app.use(express.json());

interface CopilotMessage {
  role: "user" | "assistant";
  content: string;
}

interface AgentRequest {
  messages: CopilotMessage[];
  copilot_references?: Array<{
    type: string;
    data: Record<string, unknown>;
  }>;
}

app.post("/agent", async (req, res) => {
  const request: AgentRequest = req.body;
  const userMessage = request.messages
    .filter((m) => m.role === "user")
    .pop()?.content;

  if (!userMessage) {
    res.status(400).json({ error: "No user message found" });
    return;
  }

  // Set up streaming response
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  // Process the message and stream a response
  const response = await processMessage(userMessage, request);

  // Send the response as a stream
  for (const chunk of response) {
    res.write(`data: ${JSON.stringify({
      choices: [{
        delta: { content: chunk },
        index: 0,
      }],
    })}\n\n`);
  }

  res.write("data: [DONE]\n\n");
  res.end();
});

async function processMessage(
  message: string,
  request: AgentRequest
): Promise<string[]> {
  const lowerMessage = message.toLowerCase();

  if (lowerMessage.includes("open issues") || lowerMessage.includes("bugs")) {
    return await handleIssueQuery(message);
  }

  if (lowerMessage.includes("pr") || lowerMessage.includes("pull request")) {
    return await handlePRQuery(message);
  }

  return [
    "I can help you with:\n",
    "- **Issue tracking** — ask about open issues, bug counts, or issue trends\n",
    "- **Pull requests** — check PR status, review queues, or merge readiness\n",
    "- **Project health** — get an overview of project activity and metrics\n",
    "\nTry asking: 'How many open bugs do we have?' or 'What PRs need review?'",
  ];
}

async function handleIssueQuery(message: string): Promise<string[]> {
  const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

  const { data: issues } = await octokit.issues.listForRepo({
    owner: process.env.REPO_OWNER!,
    repo: process.env.REPO_NAME!,
    state: "open",
    labels: "bug",
    per_page: 10,
  });

  const chunks: string[] = [];
  chunks.push(`## Open Bug Issues\n\n`);
  chunks.push(`Found **${issues.length}** open bugs:\n\n`);

  for (const issue of issues) {
    chunks.push(`- [#${issue.number}](${issue.html_url}) — ${issue.title}\n`);
  }

  chunks.push(`\n> 💡 **Tip:** Use labels consistently to help me track issues more accurately.`);

  return chunks;
}

async function handlePRQuery(message: string): Promise<string[]> {
  const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

  const { data: prs } = await octokit.pulls.list({
    owner: process.env.REPO_OWNER!,
    repo: process.env.REPO_NAME!,
    state: "open",
    per_page: 10,
  });

  const chunks: string[] = [];
  chunks.push(`## Open Pull Requests\n\n`);
  chunks.push(`There are **${prs.length}** open PRs:\n\n`);

  for (const pr of prs) {
    const reviewStatus = pr.requested_reviewers?.length
      ? "⏳ Awaiting review"
      : "✅ Reviews complete";
    chunks.push(`- [#${pr.number}](${pr.html_url}) — ${pr.title} (${reviewStatus})\n`);
  }

  return chunks;
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Agent server listening on port ${PORT}`);
});
```

### Step 3: Run and test locally

```bash
GITHUB_TOKEN=ghp_your_token REPO_OWNER=your-org REPO_NAME=your-repo npx tsx src/agent.ts
```

Test with curl:

```bash
curl -X POST http://localhost:3000/agent \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "How many open bugs do we have?"}]}'
```

> **💡 Tip:** Start with simple message parsing and static responses. Add complexity once the basic flow works.

---

## Exercise 3 — Adding Rich Functionality

**Goal:** Enhance your extension with contextual awareness and more sophisticated responses.

### Step 1: Use Copilot references for context

When Copilot sends a message to your extension, it includes **references** — information about the current file, repository, and user context:

```typescript
app.post("/agent", async (req, res) => {
  const request: AgentRequest = req.body;

  // Extract context from copilot_references
  const repoRef = request.copilot_references?.find(
    (ref) => ref.type === "github.repository"
  );

  const currentRepo = repoRef?.data as {
    owner: string;
    name: string;
  } | undefined;

  // Use the current repo context for API calls
  if (currentRepo) {
    const issues = await getIssues(currentRepo.owner, currentRepo.name);
    // ...
  }
});
```

### Step 2: Add confirmation prompts

For destructive actions, ask for confirmation:

```typescript
async function handleCloseIssue(issueNumber: number): Promise<string[]> {
  return [
    `⚠️ **Confirm action**: Close issue #${issueNumber}?\n\n`,
    `Reply with "yes, close #${issueNumber}" to confirm.\n`,
    `This action cannot be easily undone.`,
  ];
}
```

### Step 3: Handle follow-up messages

Use the conversation history for multi-turn interactions:

```typescript
function getConversationContext(messages: CopilotMessage[]): {
  lastTopic: string | null;
  pendingAction: string | null;
} {
  const history = messages.filter((m) => m.role === "assistant");
  const lastResponse = history[history.length - 1]?.content || "";

  return {
    lastTopic: lastResponse.includes("Bug Issues") ? "bugs" :
               lastResponse.includes("Pull Requests") ? "prs" : null,
    pendingAction: lastResponse.includes("Confirm action") ? "close_issue" : null,
  };
}
```

---

## Exercise 4 — Preparing for the Marketplace

**Goal:** Package your extension for public distribution.

### Step 1: Add proper error handling

```typescript
app.post("/agent", async (req, res) => {
  try {
    // ... main handler logic
  } catch (error) {
    console.error("Agent error:", error);

    res.setHeader("Content-Type", "text/event-stream");
    res.write(`data: ${JSON.stringify({
      choices: [{
        delta: {
          content: "I encountered an error processing your request. Please try again.",
        },
        index: 0,
      }],
    })}\n\n`);
    res.write("data: [DONE]\n\n");
    res.end();
  }
});
```

### Step 2: Add request verification

Verify that requests are actually coming from GitHub:

```typescript
import { verify } from "@octokit/webhooks-methods";

async function verifyRequest(req: express.Request): Promise<boolean> {
  const signature = req.headers["github-public-key-signature"] as string;
  const payload = JSON.stringify(req.body);

  if (!signature) return false;

  return verify(process.env.GITHUB_WEBHOOK_SECRET!, payload, signature);
}
```

### Step 3: Deploy to a hosting platform

Deploy your agent to any platform that supports HTTPS endpoints:
- **Azure App Service** or **AWS Lambda** for serverless
- **Railway**, **Render**, or **Fly.io** for container hosting
- Any platform with a stable HTTPS URL

Update your GitHub App's agent URL to point to the deployed endpoint.

### Step 4: Submit to the Marketplace

1. Go to your GitHub App settings
2. Click **"List on GitHub Marketplace"**
3. Fill in the listing details — name, description, pricing, screenshots
4. Submit for review

---

## Security Best Practices

- **Verify request signatures** — ensure requests come from GitHub
- **Scope permissions minimally** — only request the permissions your extension needs
- **Sanitize user input** — treat all user messages as untrusted
- **Rate limit your endpoints** — protect against abuse
- **Log actions, not data** — log what your extension does, not the user's content
- **Use secrets management** — never hardcode API keys or tokens

---

## Limitations & Considerations

- **Hosting requirements** — Your agent endpoint must be publicly accessible over HTTPS. GitHub routes messages to your server's URL, so local-only servers won't work without a tunnel (e.g., ngrok) during development.
- **Latency expectations** — Users expect near-instant responses in chat. If your agent calls slow external APIs, use streaming responses to provide incremental feedback rather than making the user wait for a complete response.
- **No persistent conversation state** — GitHub sends the full conversation history with each request. Your server is stateless by default. If you need to track state across turns (e.g., pending confirmations), encode it in the conversation messages or use external storage.
- **Rate limiting** — GitHub enforces rate limits on the Copilot Extensions API. If your extension becomes popular, plan for throttling and implement graceful degradation.
- **Marketplace review process** — Publishing to the GitHub Marketplace requires a review. Ensure your extension handles errors gracefully, verifies request signatures, and follows GitHub's acceptable use policies.
- **User context limitations** — Copilot references provide repository and file context, but not all context types are always available. Design your extension to work gracefully when references are missing or incomplete.
- **Token and model costs** — If your extension calls LLM APIs for processing, those costs are yours to manage. Consider caching, response size limits, and usage tiers in your architecture.

---

## Summary

In this workshop you learned how to:

1. **Create a GitHub App** as the identity for your Copilot Extension
2. **Build an agent endpoint** that handles messages and streams responses
3. **Add rich functionality** with context awareness and multi-turn conversations
4. **Prepare for the Marketplace** with error handling, verification, and deployment

Custom Extensions let you bring your team's specialized workflows directly into Copilot Chat — making AI assistance truly contextual and powerful.

---

## Next Steps

- **[AI-Native Practices →](./ai-native-practices)** — Learn the development practices that maximize the value of AI-powered tools.
- **[Agentic Workflows →](./agentic-workflows)** — Combine your extension with GitHub Actions for end-to-end automation.
