---
description: "Use when modifying styles, Tailwind classes, theme colors, or CSS in this project. Covers Tailwind v4 theme system, dark mode, prose styling, and color token usage."
applyTo: "src/styles/**"
---

# Styling Conventions

## Tailwind CSS v4 Setup

This project uses **Tailwind v4** via the Vite plugin (`@tailwindcss/vite`), NOT PostCSS. Configuration is in `astro.config.mjs`:

```js
import tailwindcss from '@tailwindcss/vite';
// ...
vite: { plugins: [tailwindcss()] }
```

There is NO `tailwind.config.js` — theme is defined in `src/styles/global.css` using the `@theme` directive.

## Theme Color Tokens

All colors are defined as CSS custom properties in the `@theme` block:

| Token Group | Range | Usage |
|-------------|-------|-------|
| `primary-*` | 50–900 | Links, buttons, active states (blue) |
| `accent-*` | 400–600 | Highlights, decorative (purple) |
| `surface-*` | 50–950 | Backgrounds, borders, text (slate) |

**Always use semantic tokens** in Tailwind classes:
```html
<!-- Correct -->
<div class="bg-primary-500 text-surface-50">
<!-- Wrong — raw Tailwind colors -->
<div class="bg-blue-500 text-slate-50">
```

Exception: difficulty badge colors (green, yellow, red) are allowed as utility overrides.

## Dark Mode

- Class-based: `<html class="dark">` toggled by inline script in BaseLayout
- Use `dark:` prefix: `bg-white dark:bg-surface-950`
- Never use `@media (prefers-color-scheme)` in components
- Always test both light and dark rendering when changing colors

## Prose Styling

Markdown content is styled by custom `.prose` rules in `global.css`. Do NOT install `@tailwindcss/typography`.

Dark mode prose uses `.dark .prose` selectors. When adding new prose elements, add both light and dark variants.

## Layout Dimensions

| Context | Max Width | Class |
|---------|-----------|-------|
| Grid/index pages | 80rem | `max-w-7xl` |
| Content/article pages | 56rem | `max-w-4xl` |
| Prose text width | 75ch | Set in `.prose` CSS |

## Responsive Breakpoints

Follow Tailwind mobile-first pattern:
```html
<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
```

## Standard Patterns

- Card hover: `transition-all duration-200 hover:shadow-lg hover:-translate-y-1`
- Sticky header: `sticky top-0 z-50 bg-white/80 backdrop-blur-md dark:bg-surface-950/80`
- Section padding: `px-4 py-12 sm:px-6 lg:px-8`
