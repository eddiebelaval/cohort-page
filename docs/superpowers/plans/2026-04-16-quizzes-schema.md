# Quizzes Module — Schema Proposal

**Owner:** Allie (@allierays)
**Status:** Starting point — edit freely, you own the final design
**Related:** `docs/superpowers/specs/2026-04-16-quizzes-spec.md`

## Proposed tables

Three tables. Prefix `quiz_` so they're clearly yours.

### `quizzes`
The quiz itself — title, description, metadata.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | `gen_random_uuid()` |
| slug | text (unique) | url-friendly identifier, e.g. `cca-intro` |
| title | text | "CCA Intro Fundamentals" |
| description | text | short blurb, optional |
| course_key | text | matches existing `progress.item_key` prefix if tied to a course, nullable |
| question_count | int | denormalized, updated on question insert |
| created_at | timestamptz | `default now()` |
| published | boolean | `default false` — hide drafts from members |

### `quiz_questions`
Questions belonging to a quiz. Multiple choice for v1.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | `gen_random_uuid()` |
| quiz_id | uuid (FK) | `references quizzes(id) on delete cascade` |
| position | int | order within the quiz (1, 2, 3...) |
| prompt | text | the question itself |
| options | jsonb | array of strings: `["A answer", "B answer", ...]` |
| correct_index | int | 0-based index into `options` |
| explanation | text | optional — shown after answer |

### `quiz_attempts`
A member's attempt at a quiz.

| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | `gen_random_uuid()` |
| member_id | uuid (FK) | `references members(id)` |
| quiz_id | uuid (FK) | `references quizzes(id)` |
| score | int | number correct |
| total | int | number of questions at attempt time (denormalized — questions may change) |
| answers | jsonb | array of `{question_id, selected_index}` for review |
| completed_at | timestamptz | `default now()` |

## RLS policies (mandatory)

The anon key is exposed in the browser. Without RLS, anyone can insert/update/delete rows. These are starter policies — tighten if you see a risk.

```sql
-- quizzes: everyone can read published quizzes, no one can write via the client
alter table quizzes enable row level security;

create policy "anyone reads published quizzes"
  on quizzes for select
  using (published = true);

-- Inserts/updates/deletes happen via SQL in the Supabase dashboard (admin-only).
-- No client-side write policies needed for v1.


-- quiz_questions: readable only if the parent quiz is published
alter table quiz_questions enable row level security;

create policy "read questions for published quizzes"
  on quiz_questions for select
  using (
    exists (
      select 1 from quizzes
      where quizzes.id = quiz_questions.quiz_id
        and quizzes.published = true
    )
  );


-- quiz_attempts: members can read and insert their OWN attempts only
alter table quiz_attempts enable row level security;

create policy "members read own attempts"
  on quiz_attempts for select
  using (member_id = (
    select id from members where auth_id = auth.uid()
  ));

create policy "members insert own attempts"
  on quiz_attempts for insert
  with check (member_id = (
    select id from members where auth_id = auth.uid()
  ));
```

Note: the existing `members` table has an `auth_id` column that links to Supabase auth (see `index.html` around line 1202). The RLS pattern above mirrors what the rest of the site uses.

## Migration plan

1. Create tables via Supabase dashboard SQL editor (or `supabase migration new` if you like the CLI)
2. Apply RLS policies
3. Seed one quiz via SQL — 5-10 questions for the Claude 101 course so there's content to test against
4. Wire up the module to read/write these tables
5. Verify the streak hook is firing by completing a quiz and checking the `activity` table

## Things to ask yourself before you finalize

- **Drafts** — do you want a `drafts` state on `quizzes` beyond `published: false`, or is `published` enough?
- **Attempts history** — best-of is suggested, but do you want to show the full history? If yes, `quiz_attempts` already supports it — just a UI decision.
- **Question pooling** — if a quiz has 20 questions but you want to serve 10 random, do you want that at the DB or JS layer?
- **Seed data** — writing quiz content is its own task. Pair with Eddie on which course to seed first.

## Index suggestions (after v1 is working)

```sql
create index quiz_attempts_member_id_idx on quiz_attempts(member_id);
create index quiz_attempts_quiz_id_idx on quiz_attempts(quiz_id);
create index quiz_questions_quiz_id_idx on quiz_questions(quiz_id);
```

Not urgent at 15-100 members. Useful if the cohort grows.
