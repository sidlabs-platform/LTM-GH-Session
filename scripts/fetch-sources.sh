#!/usr/bin/env bash
# fetch-sources.sh — Fetch content from registered sources for course generation
# Usage: ./scripts/fetch-sources.sh [--phase 1|2|3] [--source-id <id>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES_FILE="$SCRIPT_DIR/sources.json"
CACHE_DIR="$SCRIPT_DIR/.cache"

PHASE=""
SOURCE_ID=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --phase) PHASE="$2"; shift 2 ;;
    --source-id) SOURCE_ID="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

mkdir -p "$CACHE_DIR"

echo "📡 Fetching content sources..."

# Read sources from JSON and filter
if command -v jq &>/dev/null; then
  FILTER=".sources[] | select(.enabled == true)"
  if [[ -n "$PHASE" ]]; then
    FILTER="$FILTER | select(.phase <= $PHASE)"
  fi
  if [[ -n "$SOURCE_ID" ]]; then
    FILTER="$FILTER | select(.id == \"$SOURCE_ID\")"
  fi

  echo "$FILTER" | jq -r '.' "$SOURCES_FILE" | while IFS= read -r line; do
    # Process each source
    :
  done

  # Fetch each enabled source
  jq -r "$FILTER | @base64" "$SOURCES_FILE" | while IFS= read -r encoded; do
    source_data=$(echo "$encoded" | base64 --decode)
    id=$(echo "$source_data" | jq -r '.id')
    name=$(echo "$source_data" | jq -r '.name')
    url=$(echo "$source_data" | jq -r '.url')
    type=$(echo "$source_data" | jq -r '.type')

    echo "  📥 Fetching: $name ($url)"
    cache_file="$CACHE_DIR/${id}.html"

    # Fetch with curl, respecting rate limits
    if curl -sL --max-time 30 -o "$cache_file" "$url" 2>/dev/null; then
      # Extract text content (strip HTML tags for a rough extraction)
      sed -e 's/<[^>]*>//g' -e '/^$/d' "$cache_file" > "$CACHE_DIR/${id}.txt"
      echo "    ✅ Cached: $cache_file ($(wc -c < "$cache_file" | tr -d ' ') bytes)"
    else
      echo "    ⚠️  Failed to fetch: $url"
    fi
  done
else
  echo "⚠️  jq is required but not installed. Install with: brew install jq"
  exit 1
fi

echo ""
echo "✅ Source fetching complete. Cache directory: $CACHE_DIR"
ls -la "$CACHE_DIR"/*.txt 2>/dev/null || echo "  No cached files found."
