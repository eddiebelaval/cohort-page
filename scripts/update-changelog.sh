#!/bin/bash
# Auto-update changelog in index.html from the latest commit message
# Run after a meaningful commit: ./scripts/update-changelog.sh
#
# Skips commits with messages containing: merge, typo, fix:, chore, wip

set -e
cd "$(dirname "$0")/.."

MSG=$(git log -1 --pretty=%s)
DATE=$(date +"%b %-d")

# Skip trivial commits
if echo "$MSG" | grep -qiE "^(merge|typo|chore|wip|fix:|Co-Authored)"; then
  echo "Skipping trivial commit: $MSG"
  exit 0
fi

# Clean up the message (remove Co-Authored-By line, trim)
CLEAN_MSG=$(echo "$MSG" | head -1 | sed 's/Co-Authored-By:.*//' | xargs)

# Check if this entry already exists
if grep -qF "$CLEAN_MSG" index.html; then
  echo "Entry already exists, skipping."
  exit 0
fi

# Insert new entry after the <summary> line
sed -i '' "/<summary class=\"section-label\".*Changelog/a\\
    <div class=\"changelog-entry\">\\
      <span class=\"changelog-date\">$DATE</span>\\
      <span class=\"changelog-text\">$CLEAN_MSG</span>\\
    </div>" index.html

echo "Changelog updated: $DATE - $CLEAN_MSG"
