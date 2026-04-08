---
name: add-course
description: 'Add a new course to the LTM-GH-Session learning platform. Use when: creating a new workshop, learning path, technology guide, or agentic workflow content file. Covers collection selection, frontmatter schema, order numbering, body structure, path linking, and build validation. Triggers: "add course", "create course", "new workshop", "new learning path", "add technology", "new content", "add agentic", "create module".'
argument-hint: 'Describe the course: collection (workshops/paths/technologies/agentic), title, difficulty, and topic.'
---

# Add Course to LTM-GH-Session

## When to Use

- Adding a new workshop, learning path, technology guide, or agentic workflow article
- Creating new educational content for the GitHub Copilot learning platform
- Linking a new course into an existing learning path

## Collections Reference

| Collection | Directory | Theme | Required Extra Field |
|------------|-----------|-------|----------------------|
| `workshops` | `src/content/workshops/` | Hands-on exercises with GitHub Copilot features | none |
| `paths` | `src/content/paths/` | Curated sequences of courses for a persona | `persona` (string) |
| `technologies` | `src/content/technologies/` | Copilot usage for a specific language/stack | `language` (string) |
| `agentic` | `src/content/agentic/` | Agentic workflows, MCP, coding agents | none |

## Procedure

### 1. Choose the Collection

Ask (or infer from context):
- Hands-on exercises with Copilot features → **workshops**
- A curated journey for a developer persona → **paths**
- Copilot usage within a specific language/framework → **technologies**
- Agentic workflows, agents, MCP servers → **agentic**

### 2. Determine the `order` Value

Read the existing files in the target collection directory and find the highest `order` value. Use `highest + 1` for the new file. If the collection is empty or all files use `order: 0`, start at `1`.

```bash
grep -h "^order:" src/content/<collection>/*.md | sort -n | tail -1
```

### 3. Create the Markdown File

File path: `src/content/<collection>/<kebab-case-slug>.md`

Rules:
- kebab-case filename: `my-new-course.md`
- Filename minus `.md` = URL slug
- Never use spaces or uppercase

#### Frontmatter Templates

**workshops/** and **agentic/**:
```yaml
---
title: "Course Title Here"
description: "One or two sentence description for the card and metadata."
difficulty: beginner          # beginner | intermediate | advanced
duration: "45 minutes"
icon: "🔧"                    # Optional emoji shown on cards
tags: ["tag1", "tag2"]        # Optional; helpful for search
prerequisites:
  - "VS Code installed"
  - "GitHub Copilot extension active"
objectives:
  - "Learn how to do X"
  - "Practice Y in real scenarios"
lastUpdated: YYYY-MM-DD       # Today's date
order: <next order number>
---
```

**paths/**:
```yaml
---
title: "Persona Path Title"
description: "Description of the learning journey for this persona."
persona: "Job Role Here"      # Required: e.g. "Frontend Developer"
icon: "💻"
difficulty: intermediate
duration: "4 hours"
courses:
  - "workshops/code-completion"
  - "workshops/copilot-chat"
lastUpdated: YYYY-MM-DD
order: <next order number>
---
```

**technologies/**:
```yaml
---
title: "GitHub Copilot for <Language>"
description: "Description of how to use Copilot effectively with <language>."
language: "Rust"             # Required: the programming language name
icon: "🦀"
difficulty: intermediate
duration: "1 hour"
tags: ["rust", "systems-programming"]
lastUpdated: YYYY-MM-DD
order: <next order number>
---
```

### 4. Write the Markdown Body

After the closing `---` fence, write standard Markdown. Structure:

```markdown
Introductory paragraph explaining the course and why it matters (2–4 sentences).

## What You'll Learn
- Bullet point outcomes

## Prerequisites
Brief list or paragraph. Can reference the frontmatter prerequisites.

---

## Exercise 1 — <Descriptive Name>

**Goal:** One sentence.

### Step 1: <Action>
...

### Step 2: <Action>
...

---

## Summary

Recap of what was covered and suggested next steps or related courses.
```

Tips:
- Use fenced code blocks with language identifiers (` ```typescript `)
- Add `---` horizontal rules between major sections for visual separation
- Keep exercises concrete — show actual commands and code snippets
- For `paths/`, use `##` sections for each included course with a brief description of what learners gain from it

### 5. Link into a Learning Path (Optional)

If this course belongs in one or more paths, add it to the `courses` array in the relevant `src/content/paths/*.md` file(s):

```yaml
courses:
  - "workshops/new-slug"        # Add in logical position
```

The slug format is `<collection>/<filename-without-extension>`.

### 6. Validate

Run the build to catch schema errors and TypeScript issues:

```bash
npm run build
```

This runs `astro check` then the full Astro build. Fix any reported frontmatter schema mismatches before committing.

## Common Mistakes

- Missing a required field (`title`, `description`, `difficulty`, `duration`, plus collection-specific fields `persona` / `language`)
- Extra fields not in the Zod schema — `astro check` will reject them
- Wrong `difficulty` value — must be exactly `beginner`, `intermediate`, or `advanced` (no quotes required in YAML)
- Wrong `lastUpdated` date format — use `YYYY-MM-DD`
- Skipping the `order` check and duplicating an existing value (causes arbitrary sort order)
- Using hardcoded paths instead of `import.meta.env.BASE_URL` in any page components

## File Checklist

- [ ] File is in the correct `src/content/<collection>/` directory  
- [ ] Filename is kebab-case with `.md` extension  
- [ ] All required frontmatter fields are present and correctly typed  
- [ ] `order` is unique within the collection  
- [ ] `lastUpdated` is today's date in `YYYY-MM-DD` format  
- [ ] Markdown body has a clear intro, objectives, and structured sections  
- [ ] Added to a `paths/` `courses` array if applicable  
- [ ] `npm run build` passes with no errors  
