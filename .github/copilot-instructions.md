# Project Guidelines — LTM-GH-Session

## Overview

This is a GitHub Copilot learning platform built with **Astro 5 + Tailwind CSS v4 + MDX**. It deploys to GitHub Pages at `/LTM-GH-Session`. Content is authored as Markdown files validated by Zod schemas in Astro Content Collections.

## Tech Stack

- **Astro 5.7** — Static site generator (SSG mode, no SSR)
- **Tailwind CSS 4** — Via `@tailwindcss/vite` plugin (NOT PostCSS). Theme defined with `@theme` in `src/styles/global.css`
- **MDX** — `@astrojs/mdx` for content rendering
- **Pagefind** — Static search, indexed at build time
- **TypeScript** — Strict mode, path alias `@/*` → `src/*`
- **Node 20** — Required for CI/CD

## Build & Test

```bash
npm install          # Install dependencies
npm run dev          # Dev server
npm run build        # astro check && astro build && npx pagefind --site dist
npm run preview      # Preview built site
```

Always run `npm run build` to validate changes — it runs `astro check` (type checking) before building.

## Architecture

```
src/
  content/           # Markdown content collections (workshops, paths, technologies, agentic)
    config.ts        # Zod schemas for all 4 collections
  components/        # Reusable Astro components (CategoryCard, CourseCard, ProgressTracker)
  layouts/           # BaseLayout (global chrome) → CourseLayout (course pages)
  pages/             # File-based routing with dynamic [slug].astro routes
  styles/            # global.css with Tailwind v4 @theme and prose styles
scripts/             # Shell scripts for content generation pipeline
```

## Content Collections

Four collections defined in `src/content/config.ts`, each with a Zod schema:

| Collection | Directory | Unique Fields |
|------------|-----------|---------------|
| `workshops` | `src/content/workshops/` | `prerequisites`, `objectives` |
| `paths` | `src/content/paths/` | `persona`, `courses` (string array of linked course IDs) |
| `technologies` | `src/content/technologies/` | `language` (e.g. "Python") |
| `agentic` | `src/content/agentic/` | `prerequisites`, `objectives` |

**Shared fields** across all schemas: `title`, `description`, `difficulty` (beginner/intermediate/advanced), `duration`, `icon?`, `tags?`, `lastUpdated?`, `order` (sort position, default 0), `generatedBy?`, `sources?`.

When adding content, match the exact Zod schema in `config.ts`. Missing required fields or wrong types will break `astro check`.

## Routing Conventions

- **Base path**: Always use `import.meta.env.BASE_URL` for links (resolves to `/LTM-GH-Session/`)
- **Category index pages**: `src/pages/{collection}/index.astro` — fetch collection with `getCollection()`, sort by `order`, render `CourseCard` grid
- **Dynamic slug pages**: `src/pages/{collection}/[slug].astro` — use `getStaticPaths()`, derive slug from `entry.id.replace(/\.md$/, '')`
- **Slug derivation**: filename minus `.md` extension (e.g. `code-completion.md` → slug `code-completion`)
- **Href format**: `` `${basePath}{collection}/${slug}` ``

## Component Patterns

- Components are `.astro` files with TypeScript `interface Props` blocks
- Props are destructured from `Astro.props`
- Client-side interactivity uses `<script is:inline>` tags with vanilla JS and `localStorage`
- No React, Vue, or other UI frameworks — pure Astro components only
- Progress tracking stored in `localStorage` with key pattern: `copilot-learn-progress:{courseId}`

## Layout Hierarchy

```
BaseLayout.astro (sticky header, nav, footer, dark mode toggle, meta tags)
  └── CourseLayout.astro (breadcrumbs, title header, prose article, ProgressTracker, edit link)
        └── <Content /> (rendered markdown from collection entry)
```

- All pages use `BaseLayout`. Course/content pages additionally wrap with `CourseLayout`.
- Category index pages use `BaseLayout` directly (no CourseLayout).

## Styling Rules

- **Tailwind v4 theme**: Colors defined as `--color-primary-*`, `--color-accent-*`, `--color-surface-*` in `@theme` block in `global.css`
- **Dark mode**: Class-based (`dark:` prefix). Toggle managed by inline script in BaseLayout. Never use `@media (prefers-color-scheme)` directly in components.
- **Prose markdown**: Styled via `.prose` / `.dark .prose` in `global.css` — do NOT use `@tailwindcss/typography` plugin
- **Container max-widths**: `max-w-7xl` for grid pages, `max-w-4xl` for content pages
- **Responsive grid**: `grid gap-4 sm:grid-cols-2 lg:grid-cols-3` for card layouts
- **Color usage**: Use semantic tokens (`primary-*`, `surface-*`, `accent-*`) — never raw Tailwind colors like `blue-500`

## Code Conventions

- Use `@/` path alias for imports (e.g. `import BaseLayout from '@/layouts/BaseLayout.astro'`)
- Frontmatter YAML must match the Zod schema exactly — run `astro check` to validate
- All links must account for `BASE_URL` — hardcoded paths will break on GitHub Pages
- Empty collection states should show a "coming soon" placeholder, not an empty page
- Sort collections by `a.data.order - b.data.order` in index pages
- GitHub edit URLs follow: `https://github.com/sidlabs-platform/LTM-GH-Session/edit/main/src/content/{collection}/{entry.id}`

## Search

Pagefind indexes content marked with `data-pagefind-body` (set in CourseLayout). The search UI lives at `src/pages/search.astro`. The Pagefind index is built post-build via `npx pagefind --site dist`.

## Deployment

GitHub Actions workflow (`.github/workflows/deploy.yml`) deploys on push to `main`:
1. `npm ci` → `npm run build` → upload `dist/` → deploy to GitHub Pages

A second workflow (`.github/workflows/generate-courses.yml`) generates content via `scripts/generate-course.sh` using GitHub Copilot CLI.

## Do NOT

- Add client-side JS frameworks (React, Vue, Svelte) — this is a pure Astro SSG
- Use raw Tailwind color classes — use the semantic `primary-*`, `surface-*`, `accent-*` tokens
- Hardcode `/LTM-GH-Session/` — always use `import.meta.env.BASE_URL`
- Skip `astro check` — it catches schema mismatches before build
- Modify `@theme` colors without checking both light and dark mode rendering
- Use PostCSS for Tailwind — this project uses the Vite plugin (`@tailwindcss/vite`)
