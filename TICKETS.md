---
last-updated: 2026-04-16
status: CURRENT
active-milestone: 1
---

# TICKETS.md -- Cohort Hub Execution Board

> Canonical ticket board for agent-driven execution.
> Strategy and sequencing: `ROADMAP.md`
> Milestone grouping: `MILESTONE_TASKLISTS.md`
> Current milestone deep-dive: `MILESTONE_1_CHECKLIST.md`

---

## How Agents Should Use This File

This file is the operational source of truth for execution.

### Rules
- Work from the top down.
- Always prefer the **highest-priority unblocked ticket**.
- Only mark a ticket `done` when it is built, verified, and reflected in docs if needed.
- If work uncovers new necessary tasks, add new tickets under the right milestone instead of burying them in notes.
- If a ticket is too large for one session, split it into smaller tickets before starting.
- Future milestone tickets are stubs. Before starting a new milestone, expand its tickets to include Goal, Primary Targets, and Verification details (matching the depth of the current milestone).

### Status Values
- `todo` -- ready to pick up
- `in_progress` -- currently being worked
- `blocked` -- cannot proceed yet
- `done` -- completed and verified

### Update Protocol
When an agent or human starts work:
- change one ticket to `in_progress`
- add short progress notes if helpful

When a ticket finishes:
- change to `done`
- record verification evidence in the ticket notes
- update affected docs

When a ticket blocks:
- change to `blocked`
- add the reason in `Notes`
- create follow-up tickets if needed

---

## Current Priority Order

1. Milestone 1 -- Quizzes Ship End-to-End
2. Milestone 2 -- Modularization + Mobile Audit
3. Milestone 3 -- External Knowledge Integration
4. Milestone 4 -- Cohort Events Surface

---

## Milestone 1 -- Quizzes Ship End-to-End

### M1-01 Invite Allie to Supabase project
- Status: `todo`
- Priority: `P0`
- Owner: Eddie
- Depends on: none
- Goal: Allie can create tables and apply RLS policies without being blocked on Eddie.
- Primary targets:
  - Supabase dashboard → project `rlzacttzdhmzypgjccri` → Settings → Team
- Verification:
  - Allie confirms she received the invite email
  - Allie can open the SQL editor in the dashboard
- Notes:
  - Role should be `Developer`. Also grant Vercel member access if she'll debug deploys.

### M1-02 Create quiz_* tables in Supabase
- Status: `todo`
- Priority: `P0`
- Owner: Allie
- Depends on: `M1-01`
- Goal: Three tables (`quizzes`, `quiz_questions`, `quiz_attempts`) exist with the columns and foreign keys defined in the schema proposal.
- Primary targets:
  - Supabase SQL editor
  - `docs/superpowers/plans/2026-04-16-quizzes-schema.md` (update `### Deviations` section if anything changes)
- Verification:
  - `supabase.from('quizzes').select('*')` returns an empty array, not an error
  - Foreign keys enforce — attempting to insert a `quiz_attempts` row with a random `member_id` fails
- Notes:
  - Use `gen_random_uuid()` for primary keys to match the rest of the schema

### M1-03 Apply RLS policies
- Status: `todo`
- Priority: `P0`
- Owner: Allie
- Depends on: `M1-02`
- Goal: RLS policies from the schema proposal are applied, tested, and verifiable.
- Primary targets:
  - Supabase SQL editor (policies)
  - `docs/superpowers/plans/2026-04-16-quizzes-schema.md` (update `### Deviations` if changed)
- Verification:
  - Unauthenticated client can read published quizzes, cannot read unpublished
  - Unauthenticated client cannot insert into `quiz_attempts`
  - Authenticated client can only read and insert their OWN `quiz_attempts` rows
- Notes:
  - The existing `members` table has `auth_id` linking to `auth.users`. RLS policies should mirror the pattern used by the `notes` table (see `index.html` around line 2373 for usage).

### M1-04 Build quizzes list view
- Status: `todo`
- Priority: `P0`
- Owner: Allie
- Depends on: `M1-02`
- Goal: Module fetches published quizzes and renders a card list.
- Primary targets:
  - `assets/quizzes/index.js`
  - `assets/quizzes/quizzes.css`
- Verification:
  - Module list view renders on live preview URL
  - All styles scoped to `.quiz-*`
  - Loading and empty states both render correctly

### M1-05 Build quiz-taking flow
- Status: `todo`
- Priority: `P0`
- Owner: Allie
- Depends on: `M1-04`
- Goal: Member can select a quiz and step through its questions.
- Primary targets:
  - `assets/quizzes/index.js`
- Verification:
  - All questions render from DB
  - Selected answer is tracked in module state
  - Back / next navigation works cleanly

### M1-06 Build results view + write attempt
- Status: `todo`
- Priority: `P0`
- Owner: Allie
- Depends on: `M1-05`, `M1-03`
- Goal: On submit, the module writes to `quiz_attempts`, calls `ctx.onActivity('quiz')`, and shows the member their score.
- Primary targets:
  - `assets/quizzes/index.js`
- Verification:
  - Submit creates a row in `quiz_attempts` with correct `score`, `total`, `answers`
  - Submit creates / upserts a row in `activity` with `activity_type = 'quiz'`
  - Heatmap on dashboard reflects the activity within 5 seconds

### M1-07 Seed first quiz content
- Status: `todo`
- Priority: `P1`
- Owner: Eddie
- Depends on: `M1-02`
- Goal: A published quiz exists with 8-10 questions covering Claude 101 Intro Fundamentals.
- Primary targets:
  - Supabase SQL editor (INSERT statements)
  - Draft of quiz content in `docs/superpowers/drafts/quiz-1-content.md` (create file)
- Verification:
  - Quiz appears in the module's list view
  - Reviewing the live Network tab: `correct_index` is NOT leaked to the list query (only the take-quiz query)

### M1-08 End-to-end test with third cohort member
- Status: `todo`
- Priority: `P0`
- Owner: Joint (Eddie + Allie)
- Depends on: `M1-06`, `M1-07`
- Goal: A cohort member who is not a builder takes the quiz and reports success.
- Primary targets:
  - WhatsApp / direct outreach to identify a tester
  - `docs/mobile-audit/quizzes-375.png` (new file, mobile screenshot)
- Verification:
  - Tester's activity appears in the recent activity feed
  - Tester completed the flow without needing a walkthrough
  - Mobile screenshot saved at 375px width

### M1-09 Mobile audit screenshots
- Status: `todo`
- Priority: `P1`
- Owner: Allie
- Depends on: `M1-06`
- Goal: Prove the quizzes module works on phones.
- Primary targets:
  - `docs/mobile-audit/` directory (create)
  - Screenshots: 375px (iPhone SE), 390px (iPhone 14), 414px (iPhone 14 Pro Max)
- Verification:
  - No horizontal scroll at any width
  - All text is readable (minimum 14px body)
  - Tap targets are at least 44x44px

### M1-10 Regression check
- Status: `todo`
- Priority: `P0`
- Owner: Eddie
- Depends on: `M1-08`
- Goal: Existing features did not break during quiz work.
- Primary targets:
  - Live site manual smoke test
- Verification:
  - Dashboard renders: heatmap, activity feed, streak leaderboard, pro tip, shared resources
  - My Hub tab renders: progress checkboxes, roadmap, notes, readiness score
  - Signup flow works for a fresh email (use a throwaway address)
  - All pre-existing assertions in `SPEC.md` Verification Surface still pass

### M1-11 Reconcile docs after milestone ships
- Status: `todo`
- Priority: `P1`
- Owner: Eddie
- Depends on: `M1-08`, `M1-10`
- Goal: Triad and execution docs reflect shipped state.
- Primary targets:
  - `VISION.md` (move Pillar 8 from PARTIAL to REALIZED)
  - `SPEC.md` (update Capabilities + Data Model + Verification Surface)
  - `BUILDING.md` (append a new dated section for the milestone)
  - `ROADMAP.md` (update `active-milestone` frontmatter to 2)
  - `MILESTONE_TASKLISTS.md` (update frontmatter)
  - `TICKETS.md` (mark all M1 tickets `done` with evidence, bump `active-milestone`)
  - Archive `MILESTONE_1_CHECKLIST.md` → `docs/milestones/MILESTONE_1_CHECKLIST.archive.md`
  - Create `MILESTONE_2_CHECKLIST.md` with expanded detail for M2 workstreams
- Verification:
  - All triad files' `last-reconciled` / `last-updated` frontmatter is current date
  - No assertions in `SPEC.md` are false
  - `active-milestone` is 2 everywhere

---

## Milestone 2 -- Modularization + Mobile Audit

Stub tickets — expand before starting.

### M2-01 Choose and extract second feature to module
- Status: `todo`
- Priority: `P0`
- Depends on: `M1-11` (milestone reconciliation)
- Goal: A second feature lives at `assets/<feature>/` using the same pattern as quizzes.

### M2-02 Full mobile audit
- Status: `todo`
- Priority: `P0`
- Depends on: `M1-11`
- Goal: The entire hub renders cleanly on 375px, 390px, and 414px phones.

### M2-03 E2E Playwright test for signup flow
- Status: `todo`
- Priority: `P1`
- Depends on: `M1-11`
- Goal: CI runs an automated test that exercises the signup → first activity path.

### M2-04 CI check to block squash merges
- Status: `todo`
- Priority: `P1`
- Depends on: `M1-11`
- Goal: Belt-and-suspenders beyond the repo setting. A GitHub Action blocks any PR that would squash-merge.

---

## Milestone 3 -- External Knowledge Integration

Stub tickets.

### M3-01 id8pedia embed pattern design
### M3-02 Pilot embed for one curriculum item
### M3-03 MemPalace search surface in Notes panel
### M3-04 Federation identity pilot with Homer

---

## Milestone 4 -- Cohort Events Surface

Stub tickets.

### M4-01 Next-session card on dashboard
### M4-02 Post-session notes surface
### M4-03 Async Q&A thread per session
