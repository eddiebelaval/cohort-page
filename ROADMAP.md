---
last-updated: 2026-04-16
status: CURRENT
active-milestone: 1
---

# ROADMAP.md -- Cohort Hub

> Execution roadmap derived from the triad: `VISION.md`, `SPEC.md`, `BUILDING.md`.
> Operational companion: `MILESTONE_TASKLISTS.md`
> Canonical execution board: `TICKETS.md`
> Current milestone deep-dive: `MILESTONE_1_CHECKLIST.md`

---

## Execution Layer

The triad (`VISION.md`, `SPEC.md`, `BUILDING.md`) defines what the product is.
The execution layer defines what to do about it, at four zoom levels:

| Doc | Role | Audience |
|---|---|---|
| `ROADMAP.md` | Strategy, sequencing, gates | Humans and agents |
| `MILESTONE_TASKLISTS.md` | Tactical task lists per milestone | Humans and agents |
| `TICKETS.md` | Agent-executable work units with dependencies | Agents (primary), humans |
| `MILESTONE_N_CHECKLIST.md` | Deep-dive for the current milestone with file-level targets | Agents |

**Naming convention:** The current milestone always has a dedicated checklist named `MILESTONE_N_CHECKLIST.md`. When a milestone closes, its checklist is archived and replaced with the next milestone's checklist. Only one active checklist exists at a time.

**Reconciliation:** Each milestone's final ticket updates all triad and execution docs to reflect shipped state. Frontmatter timestamps update. The `active-milestone` field increments.

---

## Current Read

Cohort Hub is in **ID8Pipeline Stage 5 (Feature Blocks), transitioning to Stage 6 (Integration Pass)**, and is best understood as *"a working single-developer product that just took on its first external contributor."*

What is true right now:
- 60+ members have signed up and are actively using the hub (real streaks, real progress)
- All core features (auth, progress, streaks, heatmap, tips, bookmarks, notes) are shipping value daily
- Contribution infrastructure (badges, CODEOWNERS, CONTRIBUTING.md, branch protection) is in place
- The first module extraction (`assets/quizzes/`) is scaffolded with a clean integration contract

What is not true yet:
- Quizzes module does not actually take quizzes (placeholder only — Allie building)
- RLS policies have not been audited across all writable tables
- Mobile layout has not been validated on small screens since the April 8 polish
- External KB (id8pedia, MemPalace) is not surfaced inside the hub
- Squash merging was disabled 2026-04-16 but no enforcement check in CI

## Planning Principles

- **Ship small, ship often.** Features that take more than a week without a user-facing slice get split. The cohort sees progress weekly or members disengage.
- **One module per contributor.** A contributor owns a directory under `assets/` end-to-end. This keeps blast radius small and makes ownership legible.
- **Inline until it hurts.** `index.html` stays monolithic until a feature genuinely needs its own surface. Extraction is a decision, not a default.
- **Honor system over security theater.** We don't build features that assume members are adversaries. RLS exists to prevent accidents and crawlers, not to stop determined insiders.
- **Boring tech, loud ideas.** No framework changes, no new auth systems, no new hosts. Creativity goes into what the hub makes possible, not the stack underneath it.

## Universal Definition of Done

Before calling any milestone done, confirm all three:
- **Built:** the feature exists in code on `main`.
- **Verified:** the workflow passes a manual end-to-end test with a real member (Eddie or Allie).
- **Adopted:** at least one cohort member (not the builder) has used it at least once in the wild.

If one of those is missing, the work is still in progress.

## Success Definition

Cohort Hub succeeds in the near term if a cohort member can:

- Sign up with an email, land in their hub, and understand what to do next without a nudge from Eddie,
- Return 5 days a week for 3 weeks without losing their streak,
- Pass the CCA exam *at least partly because* the hub kept them coming back.

The success metric is not feature count. It is: *what fraction of the cohort takes (and passes) the exam vs. a counterfactual where they studied alone.*

---

## Now

### Milestone 1 -- Quizzes Ship End-to-End
**Window:** 2026-04-16 through ~2026-05-07 (3 weeks)
**Goal:** Every cohort member can take at least one quiz, see their score, and have their completion extend the activity streak.

#### Deliverables
- Supabase tables (`quizzes`, `quiz_questions`, `quiz_attempts`) with RLS policies
- Functional quizzes module at `assets/quizzes/` — list view, take flow, results view
- At least one seeded quiz (5-10 questions) tied to a real course (Claude 101)
- Streak integration verified (quiz completion writes to `activity` table, heatmap reflects it)
- Mobile-usable on 375px-wide viewport

#### Workstreams
- **Schema + RLS** (Allie)
  Create tables, write RLS policies, apply via Supabase dashboard.
- **Module implementation** (Allie)
  Build UI inside `assets/quizzes/` per the integration contract.
- **Content seeding** (Eddie)
  Write the first quiz covering Claude 101 Intro Fundamentals.
- **E2E verification** (Joint)
  Allie takes Eddie's quiz end-to-end. Heatmap reflects the activity. Mobile check passes.

#### Exit Criteria
- A random cohort member (not Allie, not Eddie) can sign in, take a quiz, see their result, and observe the streak extension — in under 5 minutes, on a phone.
- All tickets in `TICKETS.md` Milestone 1 section are `done`.
- All three triad docs and all execution docs reflect shipped state.

---

## Next

### Milestone 2 -- Modularization + Mobile Audit
**Window:** ~2026-05-07 through ~2026-05-28 (3 weeks)
**Goal:** The second feature extraction lands cleanly (validating the module pattern) and mobile is no longer a silent degradation.

#### Deliverables
- Second feature extracted to `assets/<feature>/` (candidate: Pro Tip of the Day, or Bookmarks)
- Mobile audit pass (all dashboard sections render at 375px, tested on real iOS + Android)
- CI check that blocks merge if squash is used (supplement to repo setting)
- Automated end-to-end test for the signup → first activity flow

#### Exit Criteria
- Two features live as modules, identical integration pattern
- Mobile screenshots in `docs/` prove rendering on 375px, 390px, 414px
- Any member can sign up and do their first activity from a phone without rage

---

## Later

### Milestone 3 -- External Knowledge Integration
**Goal:** The hub surfaces id8pedia and MemPalace content relevant to the current member's position in the curriculum, so reference material is one click away instead of a tab switch.

- Pilot integration: id8pedia article embed when a curriculum item is highlighted
- MemPalace semantic search surface inside the Notes panel (fallback when search is thin)
- Federation pilot: Homer and cohort-hub members recognize each other (shared identity)

### Milestone 4 -- Cohort Events Surface
**Goal:** Office hours stop living in WhatsApp.

- Next-session card on dashboard with time, agenda, RSVP count
- Post-session notes surface
- Async Q&A thread per session

---

## Not Now

Intentionally deferred to keep the roadmap on the critical path:

- Admin UI for moderating members / editing quiz content (seed via SQL until it hurts)
- Payment processing (cohort is free by vision)
- Native mobile app (responsive web is the target)
- Multi-cohort / multi-tenant architecture (one cohort is enough to prove the pattern)
- Real-time chat / forum (WhatsApp handles this)
- Public-facing articles / SEO play (that is id8labs.app)

---

## Priority Stack

The canonical priority order and ticket dependencies live in `TICKETS.md`. At a glance:

1. Quizzes schema + RLS (M1)
2. Quizzes module UI (M1)
3. First quiz content seeded (M1)
4. E2E verification + mobile check (M1)
5. M1 reconciliation (M1)
6. Second module extraction (M2)
7. Mobile audit (M2)
