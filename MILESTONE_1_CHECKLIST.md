---
last-updated: 2026-04-16
status: CURRENT
active-milestone: 1
---

# MILESTONE_1_CHECKLIST.md -- Quizzes Ship End-to-End

> Deep-dive checklist for Milestone 1.
> Strategy: `ROADMAP.md` | Tickets: `TICKETS.md` | Tasklists: `MILESTONE_TASKLISTS.md`
> Goal: Every cohort member can take at least one quiz, see their score, and have their completion extend the activity streak.

---

## Milestone Goal

By the end of this milestone, a cohort member who has never touched a quiz feature before can sign into the hub on their phone, see an available quiz, take it, understand their score, and feel the streak system reward their effort — all in under five minutes. This is the first test of the "cohort builds its own hub" hypothesis and the first external contributor (Allie) owning a module end-to-end.

---

## Current Reality

Already true:
- Quizzes module scaffold exists at `assets/quizzes/` (index.js, quizzes.css, README.md)
- Mount point in `index.html` at `#quizzes-root` renders placeholder on page load
- Integration contract documented in `docs/superpowers/specs/2026-04-16-quizzes-spec.md`
- Schema proposal written in `docs/superpowers/plans/2026-04-16-quizzes-schema.md`
- CODEOWNERS routes any PR touching `assets/quizzes/` to `@allierays` for review
- Allie is registered in `contributors.json` with `var(--green)` badge
- Allie invited as GitHub write collaborator (pending acceptance)

Not done yet:
- Supabase tables not created (`quizzes`, `quiz_questions`, `quiz_attempts`)
- RLS policies not applied
- Allie is not in the Supabase project yet (Eddie's pending browser action)
- Module is placeholder only — no quiz-taking UI
- No quiz content written or seeded
- No E2E test run with a real cohort member

---

## Workstream 1 -- Schema and RLS

### Outcome
Three tables exist in Supabase with RLS policies that permit reads of published quizzes and writes of one's own attempts, and block everything else.

### Tasks
- [ ] Eddie: invite Allie to the Supabase project (https://supabase.com/dashboard/project/rlzacttzdhmzypgjccri/settings/team, Developer role)
- [ ] Allie: review `docs/superpowers/plans/2026-04-16-quizzes-schema.md`, amend if needed
- [ ] Allie: create tables via Supabase SQL editor (or `supabase migration` CLI)
- [ ] Allie: apply RLS policies from the schema doc
- [ ] Allie: verify policies by running the following from an incognito browser (no session):
  - SELECT from quizzes should return only `published = true` rows
  - INSERT into quiz_attempts should fail with RLS violation
- [ ] Allie: record any schema deviations from the proposal in `docs/superpowers/plans/2026-04-16-quizzes-schema.md` with a `### Deviations` section

### Dependencies
- Eddie completes Supabase team invite (blocker until done)

### Verification
- [ ] `supabase.from('quizzes').select('*')` from browser console returns only published quizzes
- [ ] `supabase.from('quiz_attempts').insert({...})` without auth fails with RLS error
- [ ] `supabase.from('quiz_attempts').select('*')` only returns the current member's rows

---

## Workstream 2 -- Module Implementation

### Outcome
`assets/quizzes/index.js` contains a working module that lists quizzes, runs a quiz, shows results, and writes to the `activity` table on completion.

### Tasks
- [ ] Allie: list view — fetch `quizzes where published = true`, render card list into `rootEl`
- [ ] Allie: quiz-taking flow — one-question-at-a-time or paginated (your call), track selected answers in module state
- [ ] Allie: results view — score, correct/incorrect breakdown, option to review each question
- [ ] Allie: completion handler — insert into `quiz_attempts` AND call `ctx.onActivity('quiz')`
- [ ] Allie: loading / empty / error states (no quizzes available, fetch failure)
- [ ] Allie: styling uses existing CSS vars only (`--ink`, `--muted`, `--accent`, `--green`, `--border`, `--card-bg`); all class names prefixed `.quiz-`

### Dependencies
- Workstream 1 complete (need tables to query)

### Verification
- [ ] Module renders a visible quiz list on the live preview URL
- [ ] Taking a quiz writes a row to `quiz_attempts` with the correct `score` and `answers`
- [ ] Taking a quiz writes a row to `activity` with `activity_type = 'quiz'` and today's date
- [ ] Heatmap on the dashboard reflects the quiz activity within 5 seconds (real-time subscription)
- [ ] No console errors on a full quiz cycle
- [ ] All styles scoped to `.quiz-*` classes (no leaking into main app styles)

---

## Workstream 3 -- Content Seeding

### Outcome
At least one real quiz exists with 5-10 questions covering Claude 101 Intro Fundamentals, ready for members to take.

### Tasks
- [ ] Eddie: write 8-10 multiple-choice questions from the Claude 101 course material
- [ ] Eddie: for each question, include 4 options, one correct, and a short explanation
- [ ] Eddie: insert via Supabase SQL editor (no admin UI exists yet — this is intentional)
- [ ] Eddie: mark quiz `published = true` once content is confirmed correct

### Dependencies
- Workstream 1 complete (need tables)
- Can run in parallel with Workstream 2

### Verification
- [ ] Quiz appears in the module's list view on the live site
- [ ] Answers are not visible in the client payload before the quiz is submitted (check Network tab — if `correct_index` leaks into the list query, harden the schema or query)

---

## Workstream 4 -- E2E and Mobile

### Outcome
A third cohort member (not Eddie, not Allie) has taken the seeded quiz on their phone and confirmed the experience. No regressions in existing features.

### Tasks
- [ ] Allie: test the full flow on her phone (take the seeded quiz start to finish on 375px width)
- [ ] Eddie: test on his phone
- [ ] Eddie: identify one cohort member willing to test and ask them to run the flow
- [ ] Joint: screenshot the mobile render; save to `docs/mobile-audit/quizzes-375.png` (create directory)
- [ ] Joint: regression check — dashboard, heatmap, notes, bookmarks, pro tips, curriculum checkboxes still all work after the quiz feature is live

### Dependencies
- Workstream 2 and 3 complete

### Verification
- [ ] Mobile screenshot exists in repo
- [ ] Third-member test confirmation (even a WhatsApp screenshot of them saying "done, worked")
- [ ] All pre-existing Verification Surface assertions in `SPEC.md` still pass

---

## Recommended Sequence

Use this order unless a dependency forces a change:

1. **Workstream 1 (Schema + RLS)** — nothing else can start without tables
2. **Workstream 3 (Content)** — can start the moment tables exist, Eddie does this async
3. **Workstream 2 (Module)** — needs tables; content is nice-to-have but not blocking (Allie can develop against empty tables + seed test data)
4. **Workstream 4 (E2E + Mobile)** — only after 1, 2, 3 are done

Reasoning:
- Schema is a hard blocker for everything downstream
- Content and module development can happen in parallel to compress the timeline
- E2E validation comes last by definition — it is testing the whole chain

---

## Milestone Exit Checklist

Milestone 1 is done only when all of these are true:
- [ ] A cohort member who is not Allie or Eddie has taken a quiz in the wild
- [ ] Their quiz activity appears in the activity feed and heatmap
- [ ] Mobile render verified on at least one real iOS and one real Android device
- [ ] RLS policies pass an unauthenticated-client attack test
- [ ] No regression on existing features (manual smoke test of dashboard, hub, bookmarks, tips, curriculum)
- [ ] Triad docs (`VISION.md`, `SPEC.md`, `BUILDING.md`) still tell the truth after the work ships
- [ ] Execution docs (`ROADMAP.md`, `TICKETS.md`, `MILESTONE_TASKLISTS.md`) reflect shipped state
- [ ] All completed tickets in `TICKETS.md` are marked `done` with verification evidence
- [ ] `active-milestone` frontmatter field incremented to 2

If any box above is still open, the milestone is still in progress.
