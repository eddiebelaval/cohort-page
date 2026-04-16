# Quizzes Module

**Owner:** Allie (@allierays)

This directory is the quizzes feature for the cohort hub. It mounts into `#quizzes-root` in `index.html` and runs as an ES module.

## Files

- `index.js` — module entry, exports `mount(rootEl, ctx)`
- `quizzes.css` — scoped styles (all selectors prefixed `.quiz-`)

## Contract with the main app

See `docs/superpowers/specs/2026-04-16-quizzes-spec.md` § "Integration contract with the main app".

Short version:
- `ctx.supabase` — pre-authenticated Supabase client
- `ctx.memberId` — current member's UUID
- `ctx.onActivity('quiz')` — call on completion to extend the member's streak

## Ownership boundary

Everything in this directory is yours — design it however you want. The only thing you shouldn't change outside this directory is the mount point and script tag in `index.html`, which are the handshake between your module and the main app.

If you need the main app to expose something new (more context, a new event), open an issue or draft PR against `main` describing the API you want. Don't reach around the contract.

## Local dev

The main app runs as a static site:
```bash
python3 -m http.server 8766
# open http://localhost:8766
```

Your module loads automatically if you've wired it in `index.html`. Refresh the page after edits.

## Before your first PR

1. Read `CONTRIBUTING.md` in the repo root
2. Read `docs/superpowers/specs/2026-04-16-quizzes-spec.md` — the feature brief
3. Read `docs/superpowers/plans/2026-04-16-quizzes-schema.md` — proposed tables + RLS
4. Add yourself to `contributors.json` if not already there
5. Set your git config: `git config user.name "Allie Jones"` (matches the contributor registry)
