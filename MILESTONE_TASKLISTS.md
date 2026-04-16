---
last-updated: 2026-04-16
status: CURRENT
active-milestone: 1
---

# MILESTONE_TASKLISTS.md -- Cohort Hub

> Execution task lists for all roadmap milestones.
> Strategy and sequencing: `ROADMAP.md`
> Canonical execution board: `TICKETS.md`
> Current milestone deep-dive: `MILESTONE_1_CHECKLIST.md`

---

## How To Use This Doc

- `ROADMAP.md` explains sequence, intent, and gates.
- This doc turns each milestone into a practical task list with verification criteria.
- `TICKETS.md` is the canonical execution board. Agents work from tickets, not this file.
- The current milestone always has a dedicated checklist (`MILESTONE_1_CHECKLIST.md`) with file-level detail.

If a task is vague, it is not ready. Break it down further before starting.

---

## Milestone 1 -- Quizzes Ship End-to-End

Deep-dive: `MILESTONE_1_CHECKLIST.md`

### Todo
- [ ] Finalize schema for `quizzes`, `quiz_questions`, `quiz_attempts` (edit the proposal in `docs/superpowers/plans/2026-04-16-quizzes-schema.md` if needed)
- [ ] Create tables in Supabase dashboard SQL editor
- [ ] Apply RLS policies (read for published quizzes, insert-own for attempts)
- [ ] Build quiz list UI (fetches published quizzes, renders as card list)
- [ ] Build quiz-taking flow (one question at a time or paginated — Allie decides)
- [ ] Build results view (score, correct/incorrect breakdown, optional review)
- [ ] Wire activity hook on completion (call `ctx.onActivity('quiz')`)
- [ ] Eddie writes first quiz content (5-10 questions covering Claude 101 Intro Fundamentals)
- [ ] Seed quiz into `quizzes` + `quiz_questions` via SQL
- [ ] End-to-end test: real cohort member takes it, heatmap updates
- [ ] Mobile render check on 375px viewport (real device)
- [ ] Reconcile triad and execution docs after the work lands

### Verification
- [ ] RLS policies block insert/update/delete from an unauthenticated client (test via `supabase-js` without session)
- [ ] Completing a quiz creates a row in `quiz_attempts` AND in `activity` (`activity_type = 'quiz'`)
- [ ] Streak counter on dashboard reflects the quiz activity within 5 seconds of completion
- [ ] Scoring math is correct (spot-check 3 attempts with different scores)
- [ ] Module does not leak styles or globals outside `#quizzes-root`

### Done When
- [ ] A cohort member who is not Allie or Eddie has taken a quiz in the wild
- [ ] Their name appears on the activity feed with the quiz event
- [ ] No regression in existing features (dashboard, heatmap, tips, bookmarks still work)

---

## Milestone 2 -- Modularization + Mobile Audit

### Todo
- [ ] Choose the second feature to extract (Pro Tip of the Day is the likely candidate — already has a clear boundary)
- [ ] Extract the feature to `assets/<feature>/` following the quizzes module pattern
- [ ] Document any changes to the integration contract in CONTRIBUTING.md
- [ ] Mobile audit: render hub at 375px, 390px, 414px on real devices; screenshot each
- [ ] Fix any mobile rendering issues found
- [ ] Write an automated E2E test (Playwright) for signup → first activity flow
- [ ] Add CI check that blocks squash-merge commits (belt-and-suspenders beyond repo setting)

### Verification
- [ ] Two modules in `assets/`, both following the same integration pattern
- [ ] Mobile screenshots in `docs/mobile-audit/` as evidence
- [ ] `npm test` (or equivalent) runs the E2E test and passes

### Done When
- [ ] Any cohort member can sign up and do their first activity from a phone without complaint
- [ ] CI fails any PR that tries to squash-merge

---

## Milestone 3 -- External Knowledge Integration

### Todo
- [ ] Design the id8pedia embed pattern (iframe? JSON feed? static export of article slugs?)
- [ ] Ship pilot embed for one curriculum item
- [ ] MemPalace semantic search surface in Notes panel (fallback when Fuse-lite finds nothing)
- [ ] Federation identity pilot: shared identity with one other id8Labs product (Homer likely)

### Verification
- [ ] id8pedia article renders inside the hub without a tab switch
- [ ] MemPalace fallback surfaces 3+ relevant articles for a realistic query
- [ ] A cohort member authenticated to cohort-hub is recognized by Homer without a second signup

### Done When
- [ ] At least one cohort member has used the KB embed during study in the wild
- [ ] Federation pilot is documented and reusable for the next product

---

## Milestone 4 -- Cohort Events Surface

### Todo
- [ ] Design the next-session card (fields: time, agenda, RSVP count, host notes)
- [ ] Build the card into the dashboard
- [ ] Add post-session notes surface (append-only, host-editable, cohort-readable)
- [ ] Async Q&A thread per session

### Verification
- [ ] Office hours session runs end-to-end through the hub (no WhatsApp dependency for session metadata)
- [ ] Async thread accumulates messages across a real session

### Done When
- [ ] Eddie no longer manually posts office hours schedule in WhatsApp

---

## Execution Order

See `TICKETS.md` for the canonical priority order and dependency graph. Milestones are sequential: each milestone's gate must close before the next opens.
