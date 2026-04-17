#!/bin/bash
# Install the local post-commit hook that auto-updates the changelog
# after every meaningful commit. Run once after cloning:
#
#   ./scripts/install-hooks.sh
#
# The hook mirrors the CI workflow in .github/workflows/update-changelog.yml
# but runs on your machine so you get immediate feedback before pushing.
# You can skip both by prefixing commits with chore/typo/merge/wip/fix:
# or by including [skip-changelog] anywhere in the commit body.

set -e
cd "$(dirname "$0")/.."

HOOK_PATH=".git/hooks/post-commit"

cat > "$HOOK_PATH" <<'EOF'
#!/bin/bash
# Auto-update changelog after meaningful commits
./scripts/update-changelog.sh 2>/dev/null || true
EOF

chmod +x "$HOOK_PATH"

echo "Installed post-commit hook at $HOOK_PATH"
echo "Your next non-trivial commit will auto-append a changelog entry."
