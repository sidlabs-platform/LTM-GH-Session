import { defineCollection, z } from 'astro:content';

const workshopSchema = z.object({
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration: z.string(),
  icon: z.string().optional(),
  tags: z.array(z.string()).default([]),
  prerequisites: z.array(z.string()).default([]),
  objectives: z.array(z.string()).default([]),
  lastUpdated: z.coerce.date().optional(),
  order: z.number().default(0),
  // Generation metadata
  generatedBy: z.string().optional(),
  sources: z.array(z.string()).default([]),
});

const pathSchema = z.object({
  title: z.string(),
  description: z.string(),
  persona: z.string(),
  icon: z.string().optional(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration: z.string(),
  courses: z.array(z.string()).default([]),
  lastUpdated: z.coerce.date().optional(),
  order: z.number().default(0),
  generatedBy: z.string().optional(),
  sources: z.array(z.string()).default([]),
});

const technologySchema = z.object({
  title: z.string(),
  description: z.string(),
  language: z.string(),
  icon: z.string().optional(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration: z.string(),
  tags: z.array(z.string()).default([]),
  lastUpdated: z.coerce.date().optional(),
  order: z.number().default(0),
  generatedBy: z.string().optional(),
  sources: z.array(z.string()).default([]),
});

const agenticSchema = z.object({
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['beginner', 'intermediate', 'advanced']),
  duration: z.string(),
  icon: z.string().optional(),
  tags: z.array(z.string()).default([]),
  prerequisites: z.array(z.string()).default([]),
  objectives: z.array(z.string()).default([]),
  lastUpdated: z.coerce.date().optional(),
  order: z.number().default(0),
  generatedBy: z.string().optional(),
  sources: z.array(z.string()).default([]),
});

export const collections = {
  workshops: defineCollection({ type: 'content', schema: workshopSchema }),
  paths: defineCollection({ type: 'content', schema: pathSchema }),
  technologies: defineCollection({ type: 'content', schema: technologySchema }),
  agentic: defineCollection({ type: 'content', schema: agenticSchema }),
};
