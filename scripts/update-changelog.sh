#!/bin/bash
# Auto-update changelog in index.html from the latest commit message.
# Each entry gets a contributor badge derived from git commit author (%an).
# Contributor display name + color come from contributors.json.
#
# Usage:
#   ./scripts/update-changelog.sh                 # reads latest commit (local dev)
#   ./scripts/update-changelog.sh <sha>           # reads a specific commit (CI)
#
# Skips commits whose message starts with: merge, typo, chore, wip, fix:,
# or that contain [skip-changelog].

set -e
cd "$(dirname "$0")/.."

SHA="${1:-HEAD}"
MSG=$(git log -1 --pretty=%s "$SHA")
AUTHOR=$(git log -1 --pretty=%an "$SHA")
BODY=$(git log -1 --pretty=%B "$SHA")
DATE=$(date +"%b %-d")

# Skip trivial commits + explicit opt-out
if echo "$MSG" | grep -qiE "^(merge|typo|chore|wip|fix:|Co-Authored)"; then
  echo "Skipping trivial commit: $MSG"
  exit 0
fi
if echo "$BODY" | grep -qF "[skip-changelog]"; then
  echo "Skipping: [skip-changelog] opt-out present"
  exit 0
fi

# Clean up the message (first line, strip Co-Authored-By, trim)
CLEAN_MSG=$(echo "$MSG" | head -1 | sed 's/Co-Authored-By:.*//' | xargs)

# Resolve contributor badge from contributors.json
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

# Skip if this exact message is already in the changelog
if grep -qF "$CLEAN_MSG" index.html; then
  echo "Entry already exists, skipping."
  exit 0
fi

# Inject new entry after the <summary> line. Portable sed: macOS needs `-i ''`,
# GNU sed uses `-i` with no empty-string arg.
if sed --version >/dev/null 2>&1; then
  # GNU sed (Linux / GitHub Actions runner)
  sed -i "/<summary class=\"section-label\".*Changelog/a\\
    <div class=\"changelog-entry\">\\
      <span class=\"changelog-date\">$DATE</span>\\
      <span class=\"changelog-text\">$CLEAN_MSG</span>\\
      <span class=\"changelog-author\" style=\"--author-color: $COLOR;\">$DISPLAY</span>\\
    </div>" index.html
else
  # BSD sed (macOS)
  sed -i '' "/<summary class=\"section-label\".*Changelog/a\\
    <div class=\"changelog-entry\">\\
      <span class=\"changelog-date\">$DATE</span>\\
      <span class=\"changelog-text\">$CLEAN_MSG</span>\\
      <span class=\"changelog-author\" style=\"--author-color: $COLOR;\">$DISPLAY</span>\\
    </div>" index.html
fi

echo "Changelog updated: $DATE - $CLEAN_MSG [$DISPLAY]"
