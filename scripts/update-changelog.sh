#!/bin/bash
# Auto-update changelog in index.html from the latest commit message.
# Each entry gets a contributor badge derived from git commit author (%an).
# Contributor display name + color come from contributors.json.
#
# Run after a meaningful commit: ./scripts/update-changelog.sh
#
# Skips commits with messages containing: merge, typo, fix:, chore, wip

set -e
cd "$(dirname "$0")/.."

MSG=$(git log -1 --pretty=%s)
AUTHOR=$(git log -1 --pretty=%an)
DATE=$(date +"%b %-d")

# Skip trivial commits
if echo "$MSG" | grep -qiE "^(merge|typo|chore|wip|fix:|Co-Authored)"; then
  echo "Skipping trivial commit: $MSG"
  exit 0
fi

# Clean up the message (remove Co-Authored-By line, trim)
CLEAN_MSG=$(echo "$MSG" | head -1 | sed 's/Co-Authored-By:.*//' | xargs)

# Resolve contributor badge from contributors.json (python3 ships with macOS)
LOOKUP=$(python3 -c "
import json, sys
try:
    with open('contributors.json') as f:
        data = json.load(f)
    author = sys.argv[1]
    c = data.get('contributors', {}).get(author)
    if c:
        print(c['display'] + '|' + c['color'])
    else:
        first = author.split(' ')[0] if author else 'Unknown'
        print(first + '|var(--muted)')
except Exception:
    print('Unknown|var(--muted)')
" "$AUTHOR")

DISPLAY=$(echo "$LOOKUP" | cut -d'|' -f1)
COLOR=$(echo "$LOOKUP" | cut -d'|' -f2)

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
      <span class=\"changelog-author\" style=\"--author-color: $COLOR;\">$DISPLAY</span>\\
    </div>" index.html

echo "Changelog updated: $DATE - $CLEAN_MSG [$DISPLAY]"
