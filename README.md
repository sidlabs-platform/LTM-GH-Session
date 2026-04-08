# 🌐 Copilot Learning Platform

> **Free, open-source learning platform for GitHub Copilot and agentic development.**  
> Hands-on workshops, persona-based learning paths, and auto-generated courses — hosted on GitHub Pages.

[![Deploy to GitHub Pages](https://github.com/sidlabs-platform/LTM-GH-Session/actions/workflows/deploy.yml/badge.svg)](https://github.com/sidlabs-platform/LTM-GH-Session/actions/workflows/deploy.yml)

🔗 **Live Site:** [sidlabs-platform.github.io/LTM-GH-Session](https://sidlabs-platform.github.io/LTM-GH-Session)

## 📚 What's Inside

| Category | Description |
|----------|-------------|
| 🛠️ **Workshops** | Hands-on tutorials for every Copilot feature — code completion, chat, CLI, PR reviews |
| 🗺️ **Learning Paths** | Curated journeys by persona — frontend dev, backend dev, DevOps, data scientist, beginner |
| 💻 **Technologies** | How Copilot helps with JS/TS, Python, Java, C#, Go, Terraform, Docker/K8s |
| 🤖 **Agentic Dev** | Coding agents, MCP servers, custom extensions, multi-agent workflows |

## 🚀 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) 20+
- [npm](https://www.npmjs.com/) 10+

### Local Development

```bash
# Clone the repository
git clone https://github.com/sidlabs-platform/LTM-GH-Session.git
cd LTM-GH-Session

# Install dependencies
npm install

# Start the dev server
npm run dev
```

Open [http://localhost:4321/LTM-GH-Session/](http://localhost:4321/LTM-GH-Session/) in your browser.

### Build for Production

```bash
npm run build
npm run preview  # Preview the production build
```

## 🤖 Auto-Generated Content

Courses can be auto-generated using the **Course Generation Pipeline**:

1. **Manual Trigger**: Go to Actions → "Generate Course Content" → Run workflow
2. **Inputs**: Choose course type, topic, and content sources
3. **Output**: A PR is created with the generated content for human review

```bash
# Generate locally (requires GitHub Copilot CLI)
./scripts/generate-course.sh --type workshop --topic <topic-slug>

# Dry run to see the prompt
./scripts/generate-course.sh --type workshop --topic <topic-slug> --dry-run
```

## 🏗️ Tech Stack

- **[Astro](https://astro.build/)** — Static site generator
- **[Tailwind CSS v4](https://tailwindcss.com/)** — Utility-first styling
- **[MDX](https://mdxjs.com/)** — Enhanced Markdown with components
- **GitHub Actions** — CI/CD and course generation
- **GitHub Pages** — Hosting

## 📁 Project Structure

```
src/
├── components/      # Reusable UI components
├── layouts/         # Page layouts (Base, Course)
├── pages/           # Route pages
│   ├── workshops/   # Workshop listing + dynamic routes
│   ├── paths/       # Learning path listing + dynamic routes
│   ├── technologies/# Technology guide listing + dynamic routes
│   ├── agentic/     # Agentic dev listing + dynamic routes
│   └── catalog.astro# Full course catalog with filters
├── content/         # Markdown content (Content Collections)
│   ├── workshops/   # Workshop tutorials
│   ├── paths/       # Persona learning paths
│   ├── technologies/# Technology-specific guides
│   └── agentic/     # Agentic development courses
└── styles/          # Global CSS

scripts/
├── sources.json         # Content source registry
├── fetch-sources.sh     # Fetch content from sources
└── generate-course.sh   # Generate courses via Copilot CLI
```

## 🤝 Contributing

Contributions are welcome! You can:

1. **Add or improve content** — Edit markdown files in `src/content/`
2. **Fix bugs or improve UI** — Submit a PR with your changes
3. **Suggest new courses** — Open an issue with your idea

Every content page has an "Edit on GitHub" link for quick edits.

## 📜 License

This project is open source and available to everyone.