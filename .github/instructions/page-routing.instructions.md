---
description: "Use when creating or modifying Astro page files in src/pages/. Covers routing patterns, dynamic slug pages, index pages, data fetching, and layout composition."
applyTo: "src/pages/**/*.astro"
---

# Page Routing Conventions

## Base Path

Always use `import.meta.env.BASE_URL` for links. Hardcoded paths break on GitHub Pages.

```astro
const basePath = import.meta.env.BASE_URL;
// Correct: `${basePath}workshops/${slug}`
// Wrong:   `/workshops/${slug}`
// Wrong:   `/LTM-GH-Session/workshops/${slug}`
```

## Category Index Pages

Pattern for `src/pages/{collection}/index.astro`:

```astro
---
import BaseLayout from '@/layouts/BaseLayout.astro';
import CourseCard from '@/components/CourseCard.astro';
import { getCollection } from 'astro:content';

const items = (await getCollection('workshops')).sort((a, b) => a.data.order - b.data.order);
const basePath = import.meta.env.BASE_URL;
---

<BaseLayout title="Page Title" description="Page description">
  <div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
    <!-- Header -->
    <!-- Empty state: show "coming soon" if items.length === 0 -->
    <!-- Grid: class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3" -->
  </div>
</BaseLayout>
```

Key rules:
- Sort by `a.data.order - b.data.order`
- Wrap in `BaseLayout` (NOT CourseLayout)
- Always handle empty state with a placeholder
- Derive href: `` `${basePath}{collection}/${entry.id.replace(/\.md$/, '')}` ``

## Dynamic Slug Pages

Pattern for `src/pages/{collection}/[slug].astro`:

```astro
---
import CourseLayout from '@/layouts/CourseLayout.astro';
import { getCollection, render } from 'astro:content';

export async function getStaticPaths() {
  const entries = await getCollection('workshops');
  return entries.map((entry) => ({
    params: { slug: entry.id.replace(/\.md$/, '') },
    props: { entry },
  }));
}

const { entry } = Astro.props;
const { Content } = await render(entry);
const editUrl = `https://github.com/sidlabs-platform/LTM-GH-Session/edit/main/src/content/workshops/${entry.id}`;
---

<CourseLayout
  title={entry.data.title}
  description={entry.data.description}
  category="workshops"
  difficulty={entry.data.difficulty}
  duration={entry.data.duration}
  lastUpdated={entry.data.lastUpdated}
  editUrl={editUrl}
>
  <Content />
</CourseLayout>
```

Key rules:
- Slug = filename minus `.md`: `entry.id.replace(/\.md$/, '')`
- Use `render()` from `astro:content` to get `<Content />`
- Wrap in `CourseLayout` with all available metadata props
- Set `category` to the collection name string
- Build `editUrl` pointing to the GitHub edit page

## Adding a New Collection Page

When creating pages for a new collection:
1. Create `src/pages/{name}/index.astro` (index page, BaseLayout)
2. Create `src/pages/{name}/[slug].astro` (dynamic page, CourseLayout)
3. Add nav link in `BaseLayout.astro` header
4. Follow the exact patterns above — all four collections use identical structures
