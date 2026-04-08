---
title: "Building & Using MCP Servers"
description: "Learn to build Model Context Protocol servers from scratch — expose custom tools, resources, and prompts that GitHub Copilot can use to interact with your systems."
difficulty: advanced
duration: "60 minutes"
icon: "🔗"
tags: ["mcp", "model-context-protocol", "tools", "integrations", "advanced"]
prerequisites: ["Node.js or Python proficiency", "Understanding of MCP basics (see Extensions & MCP workshop)", "Familiarity with JSON-RPC or similar protocols"]
objectives:
  - "Understand the MCP server architecture and protocol"
  - "Build an MCP server that exposes custom tools"
  - "Add resources and prompts to your MCP server"
  - "Test and debug MCP servers locally"
  - "Deploy and share MCP servers with your team"
lastUpdated: 2026-04-08
order: 3
---

# Building & Using MCP Servers

The Model Context Protocol (MCP) is the bridge between GitHub Copilot and the outside world. By building an MCP server, you can give Copilot access to your internal APIs, databases, documentation, and any other system your team uses. Instead of context-switching to a separate tool, your team works through Copilot with all the context they need.

---

## What You'll Learn

- The **MCP server architecture** — tools, resources, and prompts
- Building an MCP server in **TypeScript** using the official SDK
- Exposing **custom tools** that Copilot can call
- Adding **resources** for data Copilot can read
- Testing and debugging your server locally
- Deploying and sharing your server with your team

---

## Prerequisites

1. **Node.js 20+** installed (or Python 3.10+ for the Python SDK)
2. Understanding of **MCP basics** from the Extensions & MCP workshop
3. Familiarity with **TypeScript/JavaScript** (examples use TypeScript)
4. A use case in mind — an internal API, database, or tool you want to connect

---

## MCP Architecture Overview

An MCP server exposes three types of capabilities:

| Capability | Description | Example |
|---|---|---|
| **Tools** | Functions Copilot can call to perform actions or fetch data | `query_database`, `create_ticket`, `run_test` |
| **Resources** | Data sources Copilot can read | Documentation files, API schemas, config files |
| **Prompts** | Reusable prompt templates for common tasks | "Deploy checklist", "Code review template" |

The communication flow:

```
Copilot (Client)              MCP Server
      │                           │
      │── initialize ──────────▶ │  
      │◀── capabilities ────────│  (server declares tools/resources/prompts)
      │                           │
      │── tools/call ───────────▶│
      │   { name: "query_db",    │  (Copilot decides to use a tool)
      │     args: { sql: "..." } }│
      │◀── result ──────────────│  (server returns data)
      │   { rows: [...] }        │
```

> **💡 Tip:** MCP uses JSON-RPC 2.0 over stdio (for local servers) or HTTP/SSE (for remote servers). The SDK handles the protocol details — you just define your tools and handlers.

---

## Exercise 1 — Setting Up Your First MCP Server

**Goal:** Create a basic MCP server project that exposes a simple tool.

### Step 1: Initialize the project

```bash
mkdir my-mcp-server && cd my-mcp-server
npm init -y
npm install @modelcontextprotocol/sdk zod
npm install -D typescript @types/node tsx
npx tsc --init --target es2022 --module nodenext --moduleResolution nodenext
```

### Step 2: Create the server entry point

Create `src/index.ts`:

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({
  name: "my-mcp-server",
  version: "1.0.0",
});

// Define a simple tool
server.tool(
  "greet",
  "Generate a personalized greeting message",
  {
    name: z.string().describe("The name of the person to greet"),
    style: z.enum(["formal", "casual", "enthusiastic"])
      .describe("The greeting style"),
  },
  async ({ name, style }) => {
    const greetings = {
      formal: `Good day, ${name}. How may I assist you?`,
      casual: `Hey ${name}! What's up?`,
      enthusiastic: `🎉 ${name}!! So great to see you!!!`,
    };

    return {
      content: [
        { type: "text", text: greetings[style] },
      ],
    };
  }
);

// Start the server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Step 3: Configure and test

Add to `package.json`:

```json
{
  "type": "module",
  "scripts": {
    "start": "tsx src/index.ts"
  }
}
```

Test by adding to your VS Code MCP config (`.vscode/mcp.json`):

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["tsx", "src/index.ts"],
      "cwd": "/path/to/my-mcp-server"
    }
  }
}
```

Open Copilot Chat and ask: "Use the greet tool to say hello to Alice in an enthusiastic style."

> **💡 Tip:** The `z.describe()` calls on each parameter are important. Copilot uses these descriptions to understand when and how to call your tools.

---

## Exercise 2 — Building a Database Query Tool

**Goal:** Create an MCP tool that lets Copilot query your project's database.

### Step 1: Add the database tool

```typescript
import Database from "better-sqlite3";

const db = new Database("./project.db");

server.tool(
  "query_database",
  "Execute a read-only SQL query against the project database. " +
  "Use this to look up data, check record counts, or investigate data issues.",
  {
    sql: z.string().describe(
      "The SQL SELECT query to execute. Only SELECT statements are allowed."
    ),
    params: z.array(z.union([z.string(), z.number()])).optional()
      .describe("Optional query parameters for parameterized queries"),
  },
  async ({ sql, params }) => {
    // Safety: only allow SELECT queries
    const normalized = sql.trim().toUpperCase();
    if (!normalized.startsWith("SELECT")) {
      return {
        content: [{ type: "text", text: "Error: Only SELECT queries are allowed." }],
        isError: true,
      };
    }

    try {
      const rows = db.prepare(sql).all(...(params || []));
      return {
        content: [{
          type: "text",
          text: JSON.stringify(rows, null, 2),
        }],
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: `Query error: ${error}` }],
        isError: true,
      };
    }
  }
);
```

### Step 2: Add a schema inspection tool

```typescript
server.tool(
  "describe_table",
  "Get the column names and types for a database table",
  {
    table_name: z.string().describe("The name of the table to describe"),
  },
  async ({ table_name }) => {
    // Prevent SQL injection by validating table name
    if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(table_name)) {
      return {
        content: [{ type: "text", text: "Error: Invalid table name." }],
        isError: true,
      };
    }

    const columns = db.prepare(
      `PRAGMA table_info(${table_name})`
    ).all();

    return {
      content: [{
        type: "text",
        text: JSON.stringify(columns, null, 2),
      }],
    };
  }
);
```

### Step 3: Test with Copilot

Ask Copilot questions that require database access:

```
What tables are in the database?
How many users signed up in the last 7 days?
Show me the top 5 products by revenue.
```

Copilot will call your MCP tools to answer these questions.

> **💡 Tip:** Always enforce safety boundaries in your tools. Read-only access, input validation, and parameterized queries protect against misuse.

---

## Exercise 3 — Adding Resources

**Goal:** Expose documentation and configuration files as MCP resources that Copilot can reference.

### Step 1: Add a resource for API documentation

```typescript
import { readFileSync, readdirSync } from "fs";
import { join } from "path";

server.resource(
  "api-docs",
  "docs://api/openapi.json",
  "The OpenAPI specification for this project's REST API",
  async () => {
    const spec = readFileSync("./docs/openapi.json", "utf-8");
    return {
      contents: [{
        uri: "docs://api/openapi.json",
        mimeType: "application/json",
        text: spec,
      }],
    };
  }
);
```

### Step 2: Add a dynamic resource for project conventions

```typescript
server.resource(
  "conventions",
  "docs://conventions/coding-standards",
  "The project's coding standards and conventions document",
  async () => {
    const conventions = readFileSync("./.github/copilot-instructions.md", "utf-8");
    return {
      contents: [{
        uri: "docs://conventions/coding-standards",
        mimeType: "text/markdown",
        text: conventions,
      }],
    };
  }
);
```

### Step 3: Verify in Copilot

Resources are available as context in Copilot Chat. Ask:

```
Based on our API documentation, what endpoints are available for user management?
What are our project's conventions for error handling?
```

---

## Exercise 4 — Adding Prompt Templates

**Goal:** Create reusable prompt templates that standardize common development tasks.

### Step 1: Add a code review prompt

```typescript
server.prompt(
  "code-review",
  "A structured code review template for pull requests",
  {
    file_path: z.string().describe("The file to review"),
    focus_areas: z.string().optional()
      .describe("Specific areas to focus on (e.g., 'security', 'performance')"),
  },
  async ({ file_path, focus_areas }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Review the code in ${file_path} with focus on:
1. Correctness — are there logic errors or bugs?
2. Security — any vulnerabilities or unsafe patterns?
3. Performance — any inefficiencies or scalability concerns?
4. Maintainability — is the code clear and well-structured?
${focus_areas ? `\nAdditional focus: ${focus_areas}` : ""}

Provide specific, actionable feedback with line references.`,
      },
    }],
  })
);
```

### Step 2: Add a feature specification prompt

```typescript
server.prompt(
  "feature-spec",
  "Generate a detailed feature specification from a brief description",
  {
    description: z.string().describe("Brief feature description"),
  },
  async ({ description }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Create a detailed feature specification for: ${description}

Include:
- User stories with acceptance criteria
- API endpoints needed (method, path, request/response)
- Database schema changes
- Edge cases and error scenarios
- Testing requirements`,
      },
    }],
  })
);
```

---

## Testing & Debugging

### Running Locally

Use the MCP Inspector tool to test your server without Copilot:

```bash
npx @modelcontextprotocol/inspector tsx src/index.ts
```

This opens a web UI where you can:
- See all registered tools, resources, and prompts
- Call tools with custom arguments and see results
- Debug protocol messages

### Logging

Add logging to your server for debugging:

```typescript
import { createWriteStream } from "fs";

const logStream = createWriteStream("mcp-server.log", { flags: "a" });

function log(message: string, data?: unknown) {
  const entry = `[${new Date().toISOString()}] ${message}${data ? `: ${JSON.stringify(data)}` : ""}\n`;
  logStream.write(entry);
}
```

> **💡 Tip:** Never log to stdout in an MCP server — that's the communication channel. Use stderr or a log file instead.

---

## Deployment & Sharing

### For your team

Publish your MCP server as an npm package:

```bash
npm publish --access public
```

Team members add it to their config:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "my-mcp-server"]
    }
  }
}
```

### Project-local server

Keep the server in your repository and reference it locally:

```json
{
  "mcpServers": {
    "project-tools": {
      "command": "npx",
      "args": ["tsx", "./tools/mcp-server/src/index.ts"]
    }
  }
}
```

---

## Summary

In this workshop you learned how to:

1. **Set up an MCP server project** from scratch with the official SDK
2. **Build custom tools** for database queries and system interactions
3. **Expose resources** like documentation and configuration files
4. **Create prompt templates** for standardized workflows
5. **Test, debug, and deploy** your MCP server

MCP servers are how you make Copilot truly yours. Every internal system, documentation source, and workflow tool can be just a chat message away.

---

## Next Steps

- **[Custom Copilot Extensions →](./custom-agents)** — Go beyond MCP to build full Copilot Extensions with their own identity.
- **[AI-Native Practices →](./ai-native-practices)** — Learn the development practices that maximize the value of AI tooling.
