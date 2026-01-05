#!/bin/bash
# Blocks PRs that exceed change budget (unless labeled refactor:approved)

set -e

MAX_FILES=20
MAX_LINES=500

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "⚠️  Not a git repository - skipping change budget check"
  exit 0
fi

# Check if origin/main exists
if ! git rev-parse --verify origin/main > /dev/null 2>&1; then
  echo "⚠️  No origin/main branch found - skipping change budget check"
  exit 0
fi

FILES_CHANGED=$(git diff --name-only origin/main...HEAD 2>/dev/null | wc -l | tr -d ' ')
LINES_CHANGED=$(git diff --numstat origin/main...HEAD 2>/dev/null | awk '{add+=$1; del+=$2} END {print add+del}')

# Handle case where diff returns empty
if [ -z "$FILES_CHANGED" ]; then
  FILES_CHANGED=0
fi

if [ -z "$LINES_CHANGED" ]; then
  LINES_CHANGED=0
fi

echo "📊 Change Budget Check"
echo "  Files changed: $FILES_CHANGED (max: $MAX_FILES)"
echo "  Lines changed: $LINES_CHANGED (max: $MAX_LINES)"

if [ "$FILES_CHANGED" -gt "$MAX_FILES" ] || [ "$LINES_CHANGED" -gt "$MAX_LINES" ]; then
  echo ""
  echo "❌ CHANGE BUDGET EXCEEDED"
  echo ""
  echo "Options:"
  echo "  1. Split into multiple PRs"
  echo "  2. Add label 'refactor:approved' if this is sanctioned refactor"
  echo ""
  echo "See .ai/CLAUDE.md for escape hatch protocol"
  exit 1
fi

echo "✅ Change budget OK"
