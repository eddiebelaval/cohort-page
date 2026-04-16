# Contributing to cohort-page

This is the workspace for cohort members building the Claude Certified Architect study hub. Read this once before your first PR.

## Repo conventions

- **Single-page site** — most UI lives inline in `index.html` (HTML + CSS + JS). For any feature large enough to have its own surface area (like quizzes), extract to a module under `assets/<feature-name>/`.
- **No build step, no framework, no bundler.** Vanilla JS, Supabase JS client via CDN, Vercel deploys on push to `main`.
- **Design system is monochromatic + accent orange.** Use existing CSS vars (`--ink`, `--paper`, `--accent`, `--muted`, `--border`, `--green`). Do not introduce new color tokens.

## Module pattern (for feature owners)

If you own a module under `assets/<feature>/`, you have full autonomy inside that directory. The only rules are the integration contract with `index.html`:

1. **Mount point** — the main app gives your module a single `<div id="<feature>-root">` slot. You render inside it, you don't modify anything outside it.
2. **Context from the app** — read `window.state.myMemberId` (and any other published state) — don't re-invent auth or member resolution.
3. **Activity hook** — if your feature counts as a streak-worthy action, write a row to the `activity` table with a distinct `activity_type` value. The streak system picks it up automatically.
4. **Design tokens** — scope your CSS, reuse root CSS vars, no new color system.
5. **RLS required** — any write-enabled Supabase table you create needs a Row-Level Security policy. The anon key is browser-exposed, so without RLS anyone can insert junk.

## Branch and PR rules

- **Never commit directly to `main`.** `main` auto-deploys to production.
- **Feature branches:** `feature/<name>` — one branch per feature, not per commit.
- **Open PRs against `feature/<name>` or `main`** (depending on the handoff for your feature).
- **Every PR gets a Vercel preview URL** automatically. Check the preview before requesting review.
- **Merge strategy:** rebase or merge commit only. **Never squash** — squash breaks contributor authorship attribution on the changelog.

## Changelog and contribution badges

- Every commit that ships a user-visible change automatically gets a changelog entry in the site footer.
- Entries include a **contributor badge** colored per `contributors.json`. Add yourself there before your first commit.
- The `scripts/update-changelog.sh` hook runs on commit — it reads your git author name (`%an`) and looks you up in the registry. Set your git config to match your entry:
  ```bash
  git config user.name "Your Name"
  ```

## Local dev

```bash
# From the repo root:
python3 -m http.server 8766
# Open http://localhost:8766
```

No npm, no node_modules, no watcher needed. Refresh the browser after edits.

## Questions

Open a draft PR early with your WIP + a comment explaining where you're stuck. Every PR gets a preview URL, so we can see your work and comment inline. Faster than async text debugging.
