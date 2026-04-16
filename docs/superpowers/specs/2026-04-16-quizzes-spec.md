# Quizzes Module — Feature Spec

**Owner:** Allie (@allierays)
**Status:** Draft — open for your edits
**Created:** 2026-04-16

## Why this exists

The cohort is studying for the Claude Certified Architect exam. Right now the hub tracks what members have read and what they've checked off. It doesn't test whether anything stuck. Quizzes close that loop — recall practice that also feeds the daily streak system so members have a second reason to show up.

## Product intent (the rough shape — you own the details)

A quizzes surface in the member workspace where:

- Members see a list of available quizzes, each tied to a course or topic
- They take a quiz (multi-question, whatever question types you think make sense)
- They see their result and can review wrong answers
- Their completion writes to the existing `activity` table → streak extension

Everything below is suggestion. You own the final design.

## Suggestions (not locks)

**Scope for v1:**
- Flat list of quizzes (no categories/tags yet)
- Multiple choice questions only (add short-answer later)
- Best-of attempts (take as many times as you want, track highest score)
- Show per-member: taken/not-taken, best score, last attempt date

**Out of scope for v1 (park these unless you disagree):**
- Admin UI for creating quizzes (seed via SQL for now)
- Per-question explanations
- Timer / time limits
- Anti-cheat / proctoring (honor system matches the rest of the site)
- Leaderboards (we can add after v1 ships)

## Integration contract with the main app (this is locked)

This is what you plug into. Don't deviate from these without talking to Eddie first.

### 1. Mount point

`index.html` has a single `<div id="quizzes-root"></div>` where your module renders. You own everything inside it. You don't touch anything outside it.

The main app loads your module via:
```html
<script type="module" src="./assets/quizzes/index.js"></script>
```

### 2. Module entry signature

```js
// assets/quizzes/index.js
export function mount(rootEl, ctx) {
  // rootEl: the <div id="quizzes-root"> element
  // ctx: { supabase, memberId, onActivity }
  //   supabase: shared Supabase client (already authenticated for this member)
  //   memberId: current member's UUID from the members table
  //   onActivity(type): helper to write to the activity table — streak integration
}
```

The main app calls `mount()` after authenticating the member. You don't re-invent auth, session handling, or the Supabase client.

### 3. Activity hook (streak integration)

When a member completes a quiz, call:
```js
ctx.onActivity('quiz');
```

This writes a row to the existing `activity` table with `activity_type: 'quiz'` and today's date. The streak counter on the main page picks it up automatically. **No action from you beyond the one-line call.**

### 4. Design tokens

Use the existing CSS vars defined in `index.html` root styles:
- `--ink` — primary text
- `--muted` — secondary text, borders
- `--paper` — backgrounds
- `--accent` — orange primary (use sparingly — buttons, active states)
- `--green` — success states
- `--border`, `--card-bg` — surfaces

If you need a new color for correct/incorrect answer states, reuse `--green` / `--accent`. Don't add new tokens without a conversation.

### 5. RLS is mandatory

The Supabase anon key is exposed in the browser. Any table you make writable (e.g. `quiz_attempts`) **must have a Row-Level Security policy** restricting writes to the authenticated member. See `docs/superpowers/plans/2026-04-16-quizzes-schema.md` for starter policies.

## What "done" looks like

- Quizzes module mounted in `index.html` with working UI
- At least 1 seeded quiz (5-10 questions) members can take end-to-end
- Activity hook firing → streak system shows quiz activity
- RLS policies in place on all quiz tables
- Module passes mobile viewport check (site is responsive, yours should be too)
- One open PR against `feature/quizzes` from which Eddie merges to `main`

## Scope creep — save for v2

Things that will tempt you. Resist for v1.

- Quiz builder UI (seed via SQL until members actually ask for this)
- Categories, tags, difficulty levels
- Social features (share result, comments)
- Spaced repetition algorithm (fine, but after we know people use quizzes at all)

Ship the minimum loop first. See what people actually do with it.
