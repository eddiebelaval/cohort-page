---
title: "SPEC.md"
date: 2026-04-16
author: Eddie Belaval
product: Cohort Hub
stage: 5 (Feature Blocks -- transitioning to Integration Pass)
drift-status: CURRENT
last-reconciled: 2026-04-16
---

# SPEC.md -- Living Specification
## Cohort Hub (cohort-page)

> Last reconciled: 2026-04-16 | Build stage: 5 (Feature Blocks)
> Drift status: CURRENT
> VISION alignment: 65% (7 of 11 pillars realized)

---

## Identity

The cohort hub is a single-page web app hosted at `cohort-page.vercel.app` that serves as the shared study workspace for the Claude Certified Architect cohort. It combines a public landing, magic-link auth, per-member progress tracking, and community activity surfaces in one `index.html` file backed by Supabase.

## Capabilities

What the product can do today. Each is testable against the live site.

- **Public landing:** Visitor sees cohort description, real signup count, testimonial, and "Claim Your Spot" CTA without authenticating.
- **Magic link signup:** Visitor enters name + email, receives Supabase magic link, auth session establishes on return visit.
- **Member dashboard:** Signed-in member sees community heatmap, activity feed, readiness table, streak leaderboard, shared bookmarks, and Pro Tip of the Day.
- **Per-member hub tab:** Each member has a dedicated hub showing their curriculum progress (43 items across 6 courses), their private notes, their activity streak, and a persistent roadmap view.
- **Progress tracking:** Checking a curriculum item writes to the `progress` table, extends the member's streak via the `activity` table.
- **Activity streak:** Streak survives midnight across timezones; heatmap renders 9 weeks of activity per member.
- **Community heatmap:** GitHub-style grid shows which members were active on which days across the whole cohort.
- **Pro Tip of the Day:** 90 pre-written tips rotate daily (deterministic by date hash) with a log of previous tips.
- **Shared bookmarks:** Any member can add a URL + title; visible to the whole cohort.
- **Private notes:** Member-scoped text area, auto-saved, not visible to others.
- **Contributor badges:** Every changelog entry includes a colored pill derived from the git commit author name via `contributors.json`.
- **Quizzes module mount point:** `assets/quizzes/` ES module mounts into `#quizzes-root`; placeholder renders; real implementation in progress.

## Architecture Contract

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Vanilla HTML + inline CSS + inline ES5/ES6 JS | Single `index.html` file (~2,540 lines). No framework, no bundler, no build step. |
| Module system | ES modules for extracted features (`assets/<feature>/`) | Loaded via `<script type="module">` on page bootstrap. |
| Backend | Supabase | Postgres tables, Auth (magic link), anon key exposed in browser (RLS required). |
| Hosting | Vercel | Auto-deploys from GitHub `main`. Every PR gets a preview URL. |
| Database | Supabase Postgres | Project `rlzacttzdhmzypgjccri`. |
| Fonts | Google Fonts | DM Serif Display (headings), DM Sans (body). |

### Data Model (core tables/entities)

| Entity | Purpose | Key Fields |
|--------|---------|------------|
| `members` | One row per cohort member | `id`, `name`, `email`, `color`, `auth_id`, `created_at` |
| `activity` | Streak input — one row per member per day per activity type | `member_id`, `activity_date`, `activity_type`, `created_at` |
| `progress` | Curriculum completion tracking | `member_id`, `item_key`, `completed`, `completed_at` |
| `notes` | Per-member private text | `member_id`, `content`, `updated_at` |
| `bookmarks` | Shared URLs across cohort | `member_id`, `url`, `title`, `created_at` |
| `quiz_*` (proposed) | Quizzes module tables | See `docs/superpowers/plans/2026-04-16-quizzes-schema.md` |

### Integrations

| Service | Purpose | Status |
|---------|---------|--------|
| Supabase | DB + auth | Active |
| Vercel | Hosting + previews | Active |
| GitHub | Source + PR workflow + Vercel trigger | Active |
| WhatsApp | Real-time cohort chat | Active (external, deep-linked from banner + feedback button) |
| Anthropic Learn (Skilljar) | Course delivery | Active (deep-linked, not embedded) |
| MemPalace / id8pedia | KB surfacing | Planned |

## Boundaries

What the product explicitly does NOT do right now.

- Does NOT deliver course content (deep-links to Anthropic Learn)
- Does NOT have an admin UI (quiz content, member moderation, and pro tips are seeded via SQL or code edits)
- Does NOT handle payments (cohort is free)
- Does NOT send email beyond the Supabase magic link (no digests, no reminders)
- Does NOT have real-time chat (WhatsApp handles that)
- Does NOT have a mobile app (responsive web only)
- Does NOT expose any role beyond "member" (no admin role, no moderator role)

## Verification Surface

Assertions that can be checked against the live product. If any fail, this spec is stale.

- [x] `https://cohort-page.vercel.app/` returns HTTP 200 with the landing page for unauthenticated users
- [x] Magic link signup creates a row in `auth.users` and `members` (linked via `members.auth_id`)
- [x] Heatmap renders 9 weeks of data per member with correct per-day grouping
- [x] Changelog entries added via `scripts/update-changelog.sh` include a `.changelog-author` pill
- [x] `contributors.json` entries for "Eddie Belaval" and "Allie Jones" exist with distinct colors
- [x] `assets/quizzes/index.js` loads without console errors and renders placeholder into `#quizzes-root`
- [x] `window.sb` and `window.state` are exposed after bootstrap for feature modules
- [ ] Every writable Supabase table has an RLS policy (audit pending — `quiz_*` tables must satisfy before first quiz ships)
- [ ] Mobile viewport renders all dashboard sections without horizontal scroll (requires audit)
- [ ] Squash merging is disabled in repo settings (verified 2026-04-16 via `gh api`)

## Drift Log

| Date | Section | What Changed | Why | VISION Impact |
|------|---------|-------------|-----|---------------|
| 2026-04-16 | Data Model | Added proposed `quiz_*` tables | Quizzes feature handoff to Allie | Moves Pillar 8 from UNREALIZED → PARTIAL |
| 2026-04-16 | Architecture Contract | Added module system row | First feature extracted to `assets/quizzes/` instead of inline | None — supports existing pillars |
| 2026-04-16 | Capabilities | Added contributor badges + quizzes mount | Shipped PR #4, scaffolded PR #5 | None |

---

**Companion documents:** `VISION.md` (what it is BECOMING), `BUILDING.md` (how we got here).
**This document is the contract. Test against it. Audit against it.**

**Derived outputs:** `/roadmap` `/drift` `/changelog` `/pitch` `/debt` `/onboard` — computed from the triangle, never stored.
