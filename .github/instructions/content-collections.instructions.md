---
description: "Use when creating or editing Markdown content files in src/content/. Covers frontmatter schemas, required fields, and validation for workshops, paths, technologies, and agentic collections."
applyTo: "src/content/**/*.md"
---

# Content Collection Authoring

## Schema Reference

Every `.md` file in `src/content/` must have YAML frontmatter matching the Zod schema in `src/content/config.ts`. Mismatched fields break `astro check`.

### Shared Fields (all collections)

```yaml
title: "Course Title"              # Required string
description: "Short description"   # Required string
difficulty: beginner               # Required: beginner | intermediate | advanced
duration: "30 minutes"             # Required string
icon: "⚡"                         # Optional emoji
tags: ["tag1", "tag2"]             # Defaults to []
lastUpdated: 2026-04-08            # Optional date (coerced)
order: 1                           # Sort position, defaults to 0
generatedBy: "copilot-cli"         # Optional generation source
sources: ["source-id"]             # Defaults to []
```

### Collection-Specific Fields

**workshops/** and **agentic/**:
```yaml
prerequisites: ["VS Code installed", "Copilot extension"]  # Defaults to []
objectives: ["Learn X", "Practice Y"]                       # Defaults to []
```

**paths/**:
```yaml
persona: "Backend Developer"               # Required string
courses: ["workshops/code-completion"]      # Defaults to []
```

**technologies/**:
```yaml
language: "Python"   # Required string (programming language name)
```

## File Naming

- Use kebab-case: `code-completion.md`, `docker-kubernetes.md`
- The filename (minus `.md`) becomes the URL slug
- Example: `src/content/workshops/code-completion.md` → `/workshops/code-completion`

## Validation

After adding or editing content, always run:

```bash
npm run build   # Runs astro check first, catching schema errors
```

## Common Mistakes

- Missing required `title`, `description`, `difficulty`, or `duration`
- Using `difficulty: "beginner"` (quotes are fine but the value must be one of the three enum values)
- Adding fields not in the schema — Zod will reject extra keys
- Wrong date format for `lastUpdated` — use `YYYY-MM-DD`
- For `paths`, forgetting the required `persona` field
- For `technologies`, forgetting the required `language` field

## Markdown Body

After the frontmatter `---` fence, write standard Markdown. Content is rendered in the `.prose` styled container with:
- Shiki syntax highlighting (github-light / github-dark themes)
- Heading anchors auto-generated
- Pagefind indexes all content via `data-pagefind-body` in CourseLayout
