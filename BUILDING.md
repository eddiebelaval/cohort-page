---
title: "BUILDING.md"
date: 2026-04-16
author: Eddie Belaval
product: Cohort Hub
---

# BUILDING.md -- Build Journal
## Cohort Hub (cohort-page)

> How we got here.
> Last updated: 2026-04-16

---

## Origin Story

April 1, 2026. Eddie had just been accepted into the Claude Partner Network and decided to get Claude Certified Architect certified. Rather than study alone, he opened the decision up: *"If you want to get certified with me, claim a spot."* The first version was a static landing page with a 10-person cap and a WhatsApp join link. It took one evening to build.

Within 48 hours the cohort filled and the cap came off — people kept asking to join. Within a week the landing page had evolved into a full collaborative workspace. The founding insight stuck: *nobody finishes a certification alone; a cohort is the habit machine that finishes it for you.*

---

## Build Timeline

### April 2026 -- Week 1: Launch and Scale

**Decision:** Single HTML file, no framework, no build step. Supabase JS via CDN.

**Why:** The product lives or dies on ship speed. Every day without signups was a day the cohort dynamic didn't exist. A framework + build step would have added 2 days for zero user-visible gain.

- Apr 1: Landing page, signup modal, Supabase workspace with real-time sync shipped same day (feature/finish-build)
- Apr 1: Streak-survives-midnight fix (first bug report from Eddie's own testing)
- Apr 2: Copy fixes — clarified the "claim spot" flow, added 6-month cert validity note
- Apr 5: Removed 10-person cap (cohort growing past planned size)
- Apr 5: Added swimming-lane progress chart, readiness scores, shared bookmarks, milestone celebrations
- Apr 5: Refactored tab bar into Dashboard + My Hub + Browse dropdown

### April 2026 -- Week 2: Auth and Polish

**Decision:** Magic link auth via Supabase (no passwords).

**Why:** Localstorage-only identity was losing members who switched devices. Magic link keeps onboarding lightweight (email only, no password) while making identity portable. Chose magic link over OAuth (Google/GitHub) because the cohort spans technical and non-technical members.

- Apr 6: Magic link email sign-in, roadmap view, full A-to-Z journey (CPN path → certification exam)
- Apr 6: Curriculum matched 100% to Skilljar (43 items across 6 courses, all verified against enrolled course views)
- Apr 6: Collapsible changelog + feedback button added to page footer
- Apr 6: **Auto-changelog post-commit hook** — `scripts/update-changelog.sh` injects entries from git commit messages
- Apr 6: Identity recovery button for members who cleared localStorage
- Apr 6: Playbook.html for Eddie's cohort ops guide (nightly check-ins, office hours poll templates)
- Apr 7: Credibility links (ejb.ventures, id8Labs, LinkedIn) under the intro
- Apr 7: Sticky WhatsApp banner for quick group access
- Apr 7: Community heatmap + Pro Tip of the Day
- Apr 7: Full frontend polish pass — Claude design language, warm palette, tighter spacing
- Apr 8: Heatmap iteration (scrollbar fix, GitHub-style column layout, tooltip padding)
- Apr 8: Name field validation (reject emails, reject empty)
- Apr 8: Pro Tips expanded from ~30 to 90 (3 months of daily content)

### April 2026 -- Week 3: From Solo to Team Project

**Decision:** Open contribution to cohort members, starting with Allie.

**Why:** The hub had outgrown a single-developer cadence. Members kept proposing features (quizzes being the loudest ask). Bringing a cohort member in as a module owner tests a hypothesis: can the cohort build its own hub?

- Apr 16: **Contribution badges** shipped (PR #4). Every changelog entry carries a colored pill from `contributors.json`, sourced from git commit author. All 11 historical entries backfilled with `[EDDIE]`.
- Apr 16: Repo settings hardened — squash merging disabled (preserves contributor authorship), rebase merging enabled.
- Apr 16: **Quizzes module handoff scaffold** (PR #5). `assets/quizzes/` extracted as the first module. CONTRIBUTING.md, CODEOWNERS for `@allierays`, integration contract documented.
- Apr 16: Allie invited as GitHub write collaborator. Supabase + Vercel invites pending Eddie's browser.
- Apr 16: **Triad created** (this document). First external contributor landing required shared context that wasn't in anyone's head.

---

## Architecture Decisions

| Date | Decision | Why | Alternative Considered |
|------|----------|-----|----------------------|
| 2026-04-01 | Single HTML file, no framework | Ship speed. No build step = no broken deploys. | Next.js static site — rejected as too much ceremony for v0 |
| 2026-04-01 | Supabase anon key in the browser | Zero backend to maintain. RLS covers writes. | Custom API — rejected because we have no server |
| 2026-04-01 | Localstorage for identity (v0) | Zero-friction, no signup | Email/password — rejected as too heavy for a free cohort |
| 2026-04-06 | Magic link auth (v1) | Portable identity across devices without passwords | Google OAuth — rejected because cohort spans non-technical members |
| 2026-04-06 | Auto-changelog via post-commit hook | Zero-cost release notes | Manual changelog — rejected because it never gets maintained |
| 2026-04-16 | Extract features to `assets/<feature>/` ES modules | `index.html` past 2,500 lines; new features need their own surface | Keep inline — rejected because quizzes was the breaking straw |
| 2026-04-16 | Disable squash merging | Preserves contributor authorship on the changelog badge system | Keep squash — rejected because Allie's badge would never appear |
| 2026-04-16 | Contributors registry (`contributors.json`) over git-alias-based detection | Explicit, inspectable, color-controllable | Hash-based auto-coloring — rejected because explicit beats clever |
| 2026-04-21 | Optional "For Beginners" onramp track above the main tracker | Members arriving new to Claude had no curated prerequisite path. De facto onramp was WhatsApp, contradicting VISION's "understand what to do next without a nudge from Eddie" success line. The new track mirrors foundational Anthropic lessons 1:1; skippable for experienced members; progress doesn't count toward cert % | A mandatory intro module — rejected because skill levels vary widely. A separate page — rejected because hub is where members return daily |

---

## Known Gotchas

Things that look wrong but are intentional.

- **`index.html` is 2,540 lines.** Everything inline on purpose — zero build step, zero framework overhead, zero deployment complexity. Trade-off is real but accepted for v0-v2. Breaking point recognized (quizzes extracted 2026-04-16); continue extracting features to modules as they appear, but don't refactor the whole file.
- **Supabase anon key is hardcoded in `index.html` at line 987.** Not a secret — it's designed to be exposed. RLS policies are the actual security boundary. Any table that allows client writes must have an RLS policy.
- **Post-commit hook can loop on non-chore commits.** When `scripts/update-changelog.sh` adds an entry, that modification becomes an uncommitted diff. Next commit adds another entry. Loop broken by using a `chore:` prefix (the hook's existing skip filter). Not fixed because the current workflow is well-understood.
- **`window.sb` and `window.state` are deliberately leaked.** Feature modules (like `assets/quizzes/`) need the shared Supabase client and member state. Instead of restructuring the IIFE, we publish these two globals as a documented integration API. See comment at `index.html:1202`.
- **The changelog is a `<details>` element collapsed by default.** Not a bug — older entries shouldn't push the feedback button below the fold.
- **"UPDATES" link on hover triggers scroll anchoring bugs on some browsers.** Accepted v1 limitation.

---

**Companion documents:** `VISION.md` (what it is BECOMING), `SPEC.md` (what it IS now).
**The journey from here to VISION is the work.**

**Derived outputs:** `/roadmap` `/drift` `/changelog` `/pitch` `/debt` `/onboard` -- computed from the triangle, never stored.
