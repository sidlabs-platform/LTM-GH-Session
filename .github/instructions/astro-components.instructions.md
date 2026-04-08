---
description: "Use when creating or modifying Astro components (.astro files) in src/components/. Covers component patterns, props, styling, and interactivity conventions."
applyTo: "src/components/**/*.astro"
---

# Astro Component Conventions

## Props Pattern

Every component defines a TypeScript `interface Props` in its frontmatter and destructures from `Astro.props`:

```astro
---
interface Props {
  title: string;
  description: string;
  href: string;
  icon?: string;
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
}

const { title, description, href, icon, difficulty } = Astro.props;
---
```

- Required props have no `?` suffix; optional props do
- Use `'beginner' | 'intermediate' | 'advanced'` union for difficulty, not `string`
- Default values via destructuring: `const { tags = [] } = Astro.props;`

## No UI Frameworks

Components are pure `.astro` files. Do NOT import React, Vue, Svelte, or any client-side framework. For interactivity, use `<script is:inline>` with vanilla JS.

## Client-Side Interactivity

```astro
<script is:inline>
  // Use querySelector and classList for DOM manipulation
  // Use localStorage for persistence (no backend)
  // Key pattern: 'copilot-learn-progress:{courseId}'
</script>
```

- Always use `is:inline` for scripts that need DOM access at runtime
- Scope selectors to component-specific data attributes or class names
- Never use `document.write()` or `eval()`

## Styling

- Use Tailwind utility classes directly in markup
- Use semantic color tokens: `primary-*`, `surface-*`, `accent-*` — never raw colors like `blue-500`
- Dark mode with `dark:` prefix classes
- Difficulty badge colors:
  - Beginner: `bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200`
  - Intermediate: `bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200`
  - Advanced: `bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200`
- Hover transitions: `transition-all duration-200 hover:shadow-lg hover:-translate-y-1`

## Link Handling

Always compute base path for href values:

```astro
const basePath = import.meta.env.BASE_URL;
// Correct: `${basePath}workshops/${slug}`
// Wrong: `/workshops/${slug}` or `/LTM-GH-Session/workshops/${slug}`
```

## Imports

Use the `@/` path alias:

```astro
import BaseLayout from '@/layouts/BaseLayout.astro';
import CourseCard from '@/components/CourseCard.astro';
```
