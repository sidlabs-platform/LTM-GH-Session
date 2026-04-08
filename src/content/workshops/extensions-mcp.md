---
title: "Copilot Extensions & MCP Servers"
description: "Extend GitHub Copilot's capabilities with extensions and the Model Context Protocol (MCP) — connect external tools, APIs, and data sources directly into your AI workflow."
difficulty: advanced
duration: "45 minutes"
icon: "🔌"
tags: ["extensions", "mcp", "model-context-protocol", "integrations", "advanced"]
prerequisites: ["Solid Copilot Chat experience", "Familiarity with VS Code extension ecosystem", "Basic understanding of APIs and JSON"]
objectives:
  - "Understand what Copilot Extensions are and how they work"
  - "Learn the Model Context Protocol (MCP) architecture"
  - "Configure MCP servers in VS Code and Copilot CLI"
  - "Use extension-provided tools in Copilot Chat"
  - "Build awareness of the extension ecosystem"
lastUpdated: 2026-04-08
order: 7
---

# Copilot Extensions & MCP Servers

GitHub Copilot is powerful out of the box — but the real magic happens when you extend it. **Copilot Extensions** and **MCP (Model Context Protocol) servers** let you connect Copilot to external tools, databases, APIs, and specialized knowledge sources. Instead of switching between Copilot and your project management tool, your monitoring dashboard, or your documentation site, you bring them all into one conversation.

---

## What You'll Learn

- What **Copilot Extensions** are and how they differ from VS Code extensions
- The **Model Context Protocol (MCP)** — the open standard powering tool integrations
- How to **configure MCP servers** in VS Code and the Copilot CLI
- Using **extension tools** in Copilot Chat conversations
- The extension ecosystem and where to find useful integrations

---

## Prerequisites

1. Solid experience with **Copilot Chat** (inline and panel)
2. **VS Code** with the Copilot extension installed
3. Basic understanding of **APIs, JSON, and configuration files**
4. Node.js installed (for running local MCP servers)

---

## Understanding the Architecture

### Copilot Extensions

Copilot Extensions are integrations that add new capabilities to GitHub Copilot. They can provide:

- **Tools** — functions Copilot can call to fetch data or perform actions
- **Context** — additional information sources Copilot can reference
- **Slash commands** — custom commands invocable from Chat

Extensions work across surfaces: VS Code, GitHub.com, Copilot CLI, and other editors.

### Model Context Protocol (MCP)

MCP is the open protocol that makes extensions possible. It defines how Copilot communicates with external tools:

```
┌──────────────────┐     MCP Protocol     ┌──────────────────┐
│  GitHub Copilot  │ ◄──────────────────► │   MCP Server     │
│  (LLM Client)   │   JSON-RPC over       │  (Tool Provider) │
│                  │   stdio / HTTP        │                  │
│  - Sends prompts │                       │  - Exposes tools │
│  - Calls tools   │                       │  - Returns data  │
│  - Uses context  │                       │  - Runs actions  │
└──────────────────┘                       └──────────────────┘
```

An MCP server exposes **tools** (functions Copilot can call), **resources** (data Copilot can read), and **prompts** (templates for common tasks).

> **💡 Tip:** MCP is an open standard — not proprietary to GitHub. Any tool that speaks MCP can integrate with Copilot (and other AI assistants that support the protocol).

---

## Exercise 1 — Configuring Your First MCP Server

**Goal:** Set up an MCP server in VS Code so Copilot can use its tools in Chat.

### Step 1: Understand the configuration file

MCP servers are configured in your VS Code settings or in a project-level `.vscode/mcp.json` file. Here's the structure:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"],
      "env": {}
    }
  }
}
```

Each server entry defines:
- **command** — the executable to run
- **args** — command-line arguments
- **env** — environment variables (for API keys, etc.)

### Step 2: Add a filesystem MCP server

Create `.vscode/mcp.json` in your project:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${workspaceFolder}/docs"
      ]
    }
  }
}
```

This gives Copilot the ability to read and search files in your `docs/` directory.

### Step 3: Verify the server is running

Open Copilot Chat and type:

```
What MCP tools are available?
```

Copilot should list the filesystem tools: `read_file`, `list_directory`, `search_files`, etc.

### Step 4: Use the tools

Ask Copilot a question that requires the filesystem tools:

```
What documentation files do we have? Summarize the contents of each.
```

Copilot will call the MCP server's `list_directory` and `read_file` tools to answer.

> **💡 Tip:** MCP servers run locally on your machine. Your data stays private — nothing is sent to external services unless the specific MCP server you configure does so.

---

## Exercise 2 — Using the GitHub MCP Server

**Goal:** Connect the GitHub MCP server so Copilot can interact with your repositories, issues, and PRs directly from Chat.

### Step 1: Configure the GitHub MCP server

Add to your `.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${input:github-token}"
      }
    }
  }
}
```

### Step 2: Test repository queries

Open Copilot Chat and ask:

```
List the 5 most recent open issues in this repository.
```

Copilot calls the GitHub MCP server's tools to fetch live issue data and presents it in the chat.

### Step 3: Interact with issues

Try more complex queries:

```
Find all issues labeled "bug" that were opened this week.
Summarize them and suggest which ones I should prioritize.
```

```
Create a new issue titled "Add rate limiting to API endpoints"
with a description based on our recent discussion about security.
```

> **💡 Tip:** The GitHub MCP server supports issues, PRs, commits, branches, and more. It's one of the most useful MCP servers for day-to-day development.

---

## Exercise 3 — Setting Up MCP in the Copilot CLI

**Goal:** Configure MCP servers for the Copilot CLI so you have tool access in your terminal.

### Step 1: Create the CLI configuration

Create or edit `~/.copilot/mcp-config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

### Step 2: Verify in the CLI

Launch the Copilot CLI and check that servers are loaded:

```bash
copilot
# In the CLI, ask:
# "What MCP servers are connected?"
```

### Step 3: Use tools from the terminal

Now you can ask questions that leverage MCP tools directly in your terminal:

```
What are the open PRs in this repo? Show me the one with the most comments.
```

The CLI will call the GitHub MCP server and display results inline.

> **💡 Tip:** MCP configuration in the CLI uses the same format as VS Code. If you set up servers in one place, the configuration translates directly.

---

## Exercise 4 — Exploring the Extension Ecosystem

**Goal:** Discover and install Copilot Extensions from the GitHub Marketplace.

### Step 1: Browse available extensions

Visit the [GitHub Marketplace](https://github.com/marketplace?type=apps&copilot_app=true) and filter for Copilot Extensions. Popular categories include:

| Category | Examples |
|---|---|
| **DevOps** | Docker, Sentry, Datadog |
| **Databases** | PostgreSQL, MongoDB tools |
| **Documentation** | ReadMe, API documentation |
| **Project Management** | Linear, Jira integrations |
| **Security** | Snyk, dependency scanning |

### Step 2: Install an extension

Choose an extension (e.g., a documentation tool) and click **Install**. Follow the authorization flow to grant it access to your GitHub account.

### Step 3: Use it in Chat

Once installed, extensions appear as mentionable agents in Copilot Chat:

```
@sentry What are the top unresolved errors in production this week?
```

```
@docker Generate a multi-stage Dockerfile for this Node.js project.
```

### Step 4: Evaluate the extension

Consider:
- Does it provide tools you'd use daily?
- Is the data it accesses sensitive? Check permissions carefully.
- Does it improve your workflow compared to switching to the tool's native UI?

> **💡 Tip:** Start with one or two extensions that address your biggest context-switching pain points. Too many extensions can make the tool selection noisy.

---

## MCP Server Configuration Reference

### VS Code (`.vscode/mcp.json`)

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./path/to/server.js"],
      "env": {
        "API_KEY": "${input:api-key}"
      }
    }
  }
}
```

### Copilot CLI (`~/.copilot/mcp-config.json`)

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["./path/to/server.js"],
      "env": {
        "API_KEY": "your-api-key"
      }
    }
  }
}
```

### Transport Types

| Transport | Use Case |
|---|---|
| **stdio** (default) | Local servers launched as child processes |
| **HTTP/SSE** | Remote servers accessible over the network |

---

## Security Considerations

- **Review permissions** before installing any extension or MCP server
- **API keys** should be stored in environment variables, not committed to source control
- **Local MCP servers** keep data on your machine — verify this for any server you install
- **Extension marketplace** — prefer extensions from verified publishers
- **Audit regularly** — remove extensions and servers you no longer use

---

## Summary

In this workshop you learned how to:

1. **Understand the MCP architecture** — the protocol connecting Copilot to external tools
2. **Configure MCP servers** in VS Code and the Copilot CLI
3. **Use the GitHub MCP server** for live repository interactions
4. **Explore Copilot Extensions** from the marketplace
5. **Apply security best practices** for extensions and tool integrations

Extensions and MCP servers transform Copilot from a code assistant into a development platform. They bring your entire toolchain into a single conversational interface.

---

## Next Steps

- **[Building MCP Servers →](../agentic/mcp-servers)** — Learn to build your own MCP server from scratch.
- **[Custom Copilot Extensions →](../agentic/custom-agents)** — Build a full Copilot Extension with custom tools and agents.
