#!/usr/bin/env bash
# generate-course.sh — Generate course content using GitHub Copilot CLI
# Usage: ./scripts/generate-course.sh --type <workshop|path|technology|agentic> --topic <topic> [--sources <source-ids>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CACHE_DIR="$SCRIPT_DIR/.cache"
SOURCES_FILE="$SCRIPT_DIR/sources.json"

COURSE_TYPE=""
TOPIC=""
SOURCE_IDS=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) COURSE_TYPE="$2"; shift 2 ;;
    --topic) TOPIC="$2"; shift 2 ;;
    --sources) SOURCE_IDS="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$COURSE_TYPE" || -z "$TOPIC" ]]; then
  echo "Usage: $0 --type <workshop|path|technology|agentic> --topic <topic-slug>"
  echo ""
  echo "Options:"
  echo "  --type       Course type: workshop, path, technology, or agentic"
  echo "  --topic      Topic slug (e.g., 'code-completion', 'python', 'mcp-servers')"
  echo "  --sources    Comma-separated source IDs to use for context"
  echo "  --dry-run    Print the prompt without generating"
  exit 1
fi

# Validate course type
case $COURSE_TYPE in
  workshop|workshops) OUTPUT_DIR="$PROJECT_ROOT/src/content/workshops"; COURSE_TYPE="workshop" ;;
  path|paths) OUTPUT_DIR="$PROJECT_ROOT/src/content/paths"; COURSE_TYPE="path" ;;
  technology|technologies) OUTPUT_DIR="$PROJECT_ROOT/src/content/technologies"; COURSE_TYPE="technology" ;;
  agentic) OUTPUT_DIR="$PROJECT_ROOT/src/content/agentic" ;;
  *) echo "❌ Invalid type: $COURSE_TYPE. Must be: workshop, path, technology, or agentic"; exit 1 ;;
esac

OUTPUT_FILE="$OUTPUT_DIR/$TOPIC.md"

# Gather source context from cache
CONTEXT=""
if [[ -d "$CACHE_DIR" ]]; then
  if [[ -n "$SOURCE_IDS" ]]; then
    IFS=',' read -ra IDS <<< "$SOURCE_IDS"
    for id in "${IDS[@]}"; do
      cache_file="$CACHE_DIR/${id}.txt"
      if [[ -f "$cache_file" ]]; then
        # Take first 2000 chars of each source to keep context manageable
        CONTEXT+="--- Source: $id ---"$'\n'
        CONTEXT+="$(head -c 2000 "$cache_file")"$'\n\n'
      fi
    done
  else
    # Use all available cached sources
    for cache_file in "$CACHE_DIR"/*.txt; do
      if [[ -f "$cache_file" ]]; then
        id=$(basename "$cache_file" .txt)
        CONTEXT+="--- Source: $id ---"$'\n'
        CONTEXT+="$(head -c 2000 "$cache_file")"$'\n\n'
      fi
    done
  fi
fi

# Build the generation prompt based on course type
TODAY=$(date +%Y-%m-%d)

case $COURSE_TYPE in
  workshop)
    PROMPT="Generate a hands-on workshop tutorial in Markdown for: '$TOPIC'.

This is for the Copilot Learning Platform. The workshop should be a step-by-step, practical tutorial.

Required YAML frontmatter:
---
title: \"<descriptive title>\"
description: \"<1-2 sentence description>\"
difficulty: beginner|intermediate|advanced
duration: \"<X minutes>\"
icon: \"<relevant emoji>\"
tags: [<relevant tags>]
prerequisites: [<what's needed>]
objectives: [<what learner will achieve>]
lastUpdated: $TODAY
order: 99
generatedBy: \"copilot-cli\"
sources: [<source IDs used>]
---

Content structure:
1. Overview (2-3 sentences)
2. What You'll Learn (objectives list)
3. Prerequisites
4. Step-by-step exercises (3-5 exercises with code examples)
5. Tips & Tricks
6. Summary
7. Next Steps

Use practical code examples (prefer JavaScript/TypeScript). Include > **💡 Tip:** callouts."
    ;;
  path)
    PROMPT="Generate a persona-based learning path in Markdown for: '$TOPIC'.

Required YAML frontmatter:
---
title: \"<path title>\"
description: \"<description>\"
persona: \"<target persona>\"
icon: \"<emoji>\"
difficulty: beginner|intermediate|advanced
duration: \"<X hours>\"
courses: [<referenced course slugs>]
lastUpdated: $TODAY
order: 99
generatedBy: \"copilot-cli\"
sources: [<source IDs used>]
---

Content: Who is this for, learning journey (numbered steps), practical project, next steps."
    ;;
  technology)
    PROMPT="Generate a technology-specific Copilot guide in Markdown for: '$TOPIC'.

Required YAML frontmatter:
---
title: \"GitHub Copilot for <Technology>\"
description: \"<description>\"
language: \"<language/technology name>\"
icon: \"<emoji>\"
difficulty: intermediate
duration: \"<X minutes>\"
tags: [<relevant tags>]
lastUpdated: $TODAY
order: 99
generatedBy: \"copilot-cli\"
sources: [<source IDs used>]
---

Content: Why Copilot excels, key use cases with code examples, pro tips, common patterns table."
    ;;
  agentic)
    PROMPT="Generate an agentic development course in Markdown for: '$TOPIC'.

Required YAML frontmatter:
---
title: \"<course title>\"
description: \"<description>\"
difficulty: intermediate|advanced
duration: \"<X minutes>\"
icon: \"<emoji>\"
tags: [<relevant tags>]
prerequisites: [<what's needed>]
objectives: [<learning objectives>]
lastUpdated: $TODAY
order: 99
generatedBy: \"copilot-cli\"
sources: [<source IDs used>]
---

Content: Overview, how it works, setup, hands-on exercise, best practices, limitations, summary."
    ;;
esac

# Add source context to prompt
if [[ -n "$CONTEXT" ]]; then
  PROMPT+=$'\n\nUse the following source material for accuracy and up-to-date information:\n\n'
  PROMPT+="$CONTEXT"
fi

if $DRY_RUN; then
  echo "🔍 DRY RUN — would generate:"
  echo "  Type: $COURSE_TYPE"
  echo "  Topic: $TOPIC"
  echo "  Output: $OUTPUT_FILE"
  echo ""
  echo "--- PROMPT ---"
  echo "$PROMPT"
  exit 0
fi

echo "🤖 Generating $COURSE_TYPE course: $TOPIC"
echo "  Output: $OUTPUT_FILE"

# Check if gh copilot is available
if ! gh copilot --version &>/dev/null 2>&1; then
  echo "⚠️  GitHub Copilot CLI extension not found."
  echo "   Install with: gh extension install github/gh-copilot"
  echo ""
  echo "   Falling back to saving the prompt for manual generation..."
  mkdir -p "$(dirname "$OUTPUT_FILE")"
  echo "<!-- GENERATION PROMPT: Run this through Copilot to generate content -->" > "$OUTPUT_FILE"
  echo "<!-- $PROMPT -->" >> "$OUTPUT_FILE"
  echo "  📝 Prompt saved to: $OUTPUT_FILE"
  exit 0
fi

# Generate content using Copilot CLI
mkdir -p "$(dirname "$OUTPUT_FILE")"
echo "$PROMPT" | gh copilot suggest -t general 2>/dev/null | tee "$OUTPUT_FILE"

if [[ -s "$OUTPUT_FILE" ]]; then
  echo ""
  echo "✅ Generated: $OUTPUT_FILE ($(wc -c < "$OUTPUT_FILE" | tr -d ' ') bytes)"
else
  echo "❌ Generation produced empty output. Check Copilot CLI setup."
  exit 1
fi
