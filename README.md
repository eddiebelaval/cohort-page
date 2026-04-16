# Cohort Hub

The study workspace for the Claude Certified Architect cohort. A live surface where members track progress, extend streaks, and pull each other through the exam together.

**Live site:** [cohort-page.vercel.app](https://cohort-page.vercel.app)

---

## For Cohort Members

### What this is

An open cohort of people studying for the [Claude Certified Architect](https://www.anthropic.com/learn) certification. The coursework is free. The exam is free. The hub makes the cohort real — you see who showed up today, whose streak is longer, and what the group is reading.

### How to join

1. Visit [cohort-page.vercel.app](https://cohort-page.vercel.app)
2. Click **Claim Your Spot**
3. Enter your name and email
4. Check your email for a magic link to sign in
5. Join the [WhatsApp group](https://chat.whatsapp.com/JWiZwzOwCx55MPnfxyuWCX) for cohort chat

No password, no install, works on any device. Your progress follows you.

### What you get

- **Per-member hub** — your curriculum progress (43 items across 6 courses), notes, bookmarks, streak
- **Community heatmap** — GitHub-style grid of who was active each day
- **Pro Tip of the Day** — 90 days of rotated study material
- **Shared bookmarks** — resources the cohort finds useful
- **Streak leaderboard** — gentle accountability, not surveillance
- **Quizzes** — recall practice that extends your streak *(coming soon — being built by @allierays)*

### Office hours + feedback

Office hours: **Tuesdays 7-8pm ET**. Details in the WhatsApp group.

Feedback: [send via WhatsApp](https://chat.whatsapp.com/JWiZwzOwCx55MPnfxyuWCX) or open an issue on this repo.

---

## For Contributors

This section is for cohort members who want to help build the hub itself, not just use it.

### Start here

1. **Read the triad** — these three documents are the source of truth:
   - [`VISION.md`](./VISION.md) — why this exists, what it must never become
   - [`SPEC.md`](./SPEC.md) — what the product is *right now* (present tense)
   - [`BUILDING.md`](./BUILDING.md) — how we got here, architecture decisions, known gotchas

2. **Read the execution layer** — these tell you what to build next:
   - [`ROADMAP.md`](./ROADMAP.md) — milestone sequencing with exit criteria
   - [`MILESTONE_TASKLISTS.md`](./MILESTONE_TASKLISTS.md) — per-milestone task lists
   - [`MILESTONE_1_CHECKLIST.md`](./MILESTONE_1_CHECKLIST.md) — deep dive on the current milestone
   - [`TICKETS.md`](./TICKETS.md) — canonical execution board, work top-down

3. **Read the repo conventions** — [`CONTRIBUTING.md`](./CONTRIBUTING.md) covers:
   - Repo structure (single-file site + feature modules)
   - Branch and PR rules
   - Module integration contract
   - Changelog + contribution badges

### Local development

```bash
git clone git@github.com:eddiebelaval/cohort-page.git
cd cohort-page
python3 -m http.server 8766
# open http://localhost:8766
```

No `npm install`. No `next build`. No `node_modules`. The site is a single `index.html` file backed by Supabase via CDN.

### Owning a module

If you're taking on a feature, you own a directory under `assets/`. Example: [`assets/quizzes/`](./assets/quizzes/) is owned by [@allierays](https://github.com/allierays). [`.github/CODEOWNERS`](./.github/CODEOWNERS) auto-requests the owner's review on any PR touching their directory.

The module pattern + integration contract is documented in `CONTRIBUTING.md` and in each feature's `docs/superpowers/specs/` file.

### Contribution workflow

1. Register yourself in [`contributors.json`](./contributors.json) before your first commit (pick an unused CSS color from [`index.html`](./index.html))
2. Set your git name: `git config user.name "Your Name"` (must match your registry key)
3. Branch off `main` as `feature/<name>` — never commit directly to `main`
4. Open a PR — every PR gets a Vercel preview URL automatically
5. Merge strategy: **rebase** or **merge commit** only. Squash is disabled to preserve contributor authorship on the changelog.

Every commit that ships a user-visible change automatically gets a colored pill in the changelog footer — that's your badge.

---

## Tech stack

| Layer | Stack |
|-------|-------|
| Frontend | Vanilla HTML + inline CSS/JS, ES modules for features |
| Backend | [Supabase](https://supabase.com) (Postgres + Auth) |
| Hosting | [Vercel](https://vercel.com) — auto-deploys from `main` |
| Fonts | DM Serif Display (headings), DM Sans (body) via Google Fonts |
| CI | GitGuardian (secrets scan), CodeRabbit (AI review), Vercel (preview deploys) |

See [`SPEC.md`](./SPEC.md) for the full architecture contract and data model.

---

## Contributors

Current contributors (auto-tracked via git commit author):

- [Eddie Belaval](https://github.com/eddiebelaval) — founder, runs the cohort
- [Allie Jones](https://github.com/allierays) — quizzes module

Every changelog entry shows the contributor badge derived from [`contributors.json`](./contributors.json).

---

## License

No license file yet. This repo is currently **all rights reserved** by default until a license is added. If you're contributing, you're granting your contributions back to the cohort under whatever license is chosen. If you want to use any of this code outside the cohort, open an issue.

---

## Links

- **Live site:** https://cohort-page.vercel.app
- **Live playbook (ops guide):** https://cohort-page.vercel.app/playbook.html
- **WhatsApp group:** https://chat.whatsapp.com/JWiZwzOwCx55MPnfxyuWCX
- **Anthropic Learn (course content):** https://www.anthropic.com/learn
- **id8Labs:** https://id8labs.app
