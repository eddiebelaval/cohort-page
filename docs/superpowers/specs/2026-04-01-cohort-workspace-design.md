# Cohort Workspace Design Spec

## Overview

Transform the existing static cohort landing page into a collaborative learning workspace for 10 people studying for the Claude Certified Architect exam. Single HTML file with Supabase JS Client via CDN. No auth, no login. Honor system.

## Architecture

- **Single `index.html` file** with inline CSS and JS
- **Supabase JS Client** loaded via CDN (`@supabase/supabase-js`)
- **Supabase backend** for data persistence and real-time updates
- **Deployed to Vercel** via GitHub repo (`eddiebelaval/cohort-page`), auto-deploys on push
- No build step, no framework, no bundler

### Supabase Tables

**`members`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| name | text | unique, user-entered |
| created_at | timestamptz | default now() |
| color | text | avatar color, assigned sequentially from palette on join |

**Avatar color palette** (assigned in order as members join):
`#d4622b`, `#7c3aed`, `#0891b2`, `#16a34a`, `#dc2626`, `#ca8a04`, `#6366f1`, `#ec4899`, `#14b8a6`, `#f97316`

**`activity`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| activity_date | date | the day activity occurred |
| activity_type | text | 'checkbox' or 'note' |
| created_at | timestamptz | default now() |

Unique constraint: `UNIQUE(member_id, activity_date, activity_type)`. Use upsert (`ON CONFLICT DO NOTHING`) so multiple checkbox clicks on the same day don't create duplicate rows.

**`progress`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| item_key | text | e.g. 'claude101_intro', 'cca_debugging' |
| completed | boolean | default false |
| completed_at | timestamptz | nullable |

Unique constraint: `UNIQUE(member_id, item_key)`. Use upsert on toggle: set `completed = true, completed_at = now()` on check, set `completed = false, completed_at = null` on uncheck.

**`notes`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| content | text | markdown or plain text |
| updated_at | timestamptz | default now() |

Unique constraint: `UNIQUE(member_id)`. One note row per member. Use upsert on save (`ON CONFLICT (member_id) DO UPDATE SET content = ..., updated_at = now()`).

### User Identity (No Auth)

No login. Identity is tracked via **localStorage**. When a user claims a spot (via the "+" tab), their `member_id` is saved to `localStorage`. On subsequent visits, the app checks localStorage for a stored `member_id` and auto-selects their tab.

- If localStorage has a `member_id` that exists in the `members` table, user is "recognized" and their tab is editable
- If no `member_id` in localStorage, all member tabs are read-only (view-only visitor)
- Clearing localStorage means losing your identity -- you'd need to ask Eddie to delete your old row and re-claim
- This is honor system. No enforcement. Anyone could edit localStorage to impersonate someone. We accept this risk for a trusted group of 10.

### RLS Policy

All tables use **anon key** with permissive policies (no auth). All rows readable and writable by anyone with the anon key. RLS allows SELECT, INSERT, UPDATE on all tables. DELETE is disabled -- members and data are permanent (Eddie can clean up via Supabase dashboard if needed). This is intentional -- trusted group of 10 people, honor system.

## Page Structure

The page has two modes, controlled by a tab bar:

### Tab Bar

Persistent across all views. Contains:
1. **"Dashboard"** tab (always first)
2. **Named member tabs** (one per joined member, in join order)
3. **"+" tab** (claim a spot, disappears when 10 members exist)

Clicking a member tab shows that member's hub (read-only for others, editable for the tab owner -- but no enforcement, honor system).

### Landing Section

The existing landing page content (pitch, how it works, timeline, resources, CTA, note from Eddie) remains at the top. The tab bar and workspace live below it, separated by a clear visual divider (horizontal rule or spacing). The tab bar is **not** sticky -- it sits at the start of the workspace section. Clicking a tab scrolls to the workspace and switches the view. On first load, if the visitor has a stored `member_id` in localStorage, auto-scroll to the workspace with their tab active.

### View 1: Collective Dashboard (Dashboard Tab)

BLUF stats grid (4 cards):
- **Members**: X / 10
- **Team Streak**: X days (consecutive days where at least one member had activity)
- **Courses Done**: X / (members * 3) total course completions across all members
- **Target**: "Late June" with subtitle "~12 weeks from start"

**Team Activity Heatmap**: GitHub contribution graph style. Rolling 8-week window ending today (56 cells). Color intensity based on how many members were active that day (more members = darker). Uses the orange accent palette: `#fed7aa` (1 member), `#fb923c` (2-3), `#ea580c` (4-6), `#9a3412` (7+). Empty cells = `#eee`.

**Cohort Members List**: Each row shows:
- Color avatar with first initial
- Name
- Last active date
- Mini streak visualization (7 dots showing last 7 days)
- Current streak count
- Overall progress bar (% of all checklist items completed)

### View 2: Personal Hub (Member Tab)

**BLUF Bar** (3 items, top of hub):
- Current streak (days)
- % complete (all checklist items)
- Last check-in date

**Personal Activity Heatmap**: Same style as team heatmap but only this member's activity.

**Curriculum Checklist**: Grouped by course, each course has:
- Course title + status badge ("Done" green, "In Progress" yellow, "Not Started" gray)
- Status auto-computed from checkbox state
- Checklist items, each one is a **clickable link** to the relevant course page on Anthropic Academy or claudecertifications.com

Courses and items:

**Course 1: Claude 101** (https://anthropic.skilljar.com/introduction-to-claude-cowork)
| Item | `item_key` |
|------|-----------|
| Introduction to Claude | `c101_intro` |
| Prompt Engineering Basics | `c101_prompts` |
| Working with Tools | `c101_tools` |
| Best Practices | `c101_best` |

**Course 2: Claude Code in Action** (https://anthropic.skilljar.com/claude-code-in-action)
| Item | `item_key` |
|------|-----------|
| Getting Started | `cca_start` |
| Code Generation | `cca_codegen` |
| Debugging with Claude | `cca_debug` |
| Advanced Patterns | `cca_advanced` |

**Course 3: AI Fluency Foundations** (https://claudecertifications.com/courses/ai-fluency-foundations)
| Item | `item_key` |
|------|-----------|
| AI Fundamentals | `aif_fundamentals` |
| Agentic Systems | `aif_agentic` |
| Architecture Patterns | `aif_architecture` |
| Exam Prep | `aif_exam` |

Total: 12 checklist items per member. "Courses Done" denominator = `members.count * 3` (a course is "done" when all 4 items in it are checked).

**Exam Prep Resources** (bonus section, not counted in course completion):
- Practice Questions (https://claudecertifications.com/claude-certified-architect/practice-questions)
- Exam Guide (https://claudecertifications.com/claude-certified-architect/exam-guide)
- Study Guide (https://claudecertifications.com/claude-certified-architect/study-guide)

**Notes Section**:
- Textarea for free-form notes
- "Visible to cohort" badge so user knows others can see
- Auto-saves to Supabase on blur or after 2 seconds of inactivity (debounced)
- When viewing someone else's tab, notes are read-only

### Join Flow (+ Tab)

1. User clicks "+" tab
2. Modal or inline form appears: "What's your first name?"
3. User types name, hits enter
4. New member created in Supabase
5. Tab appears in tab bar with their name
6. Slot grid on landing section updates (filled slot shows name instead of checkmark)
7. User lands on their new personal hub
8. If 10 members exist, "+" tab is hidden

## Streak Logic

- **Personal streak**: consecutive days (calendar days) where the member had at least one activity record
- **Team streak**: consecutive days where at least one member across the entire cohort had activity
- **Activity trigger**: any checkbox toggle (check or uncheck) or note save creates an activity record for that calendar day
- **Deduplication**: only one activity record per member per day per type. Multiple checkbox toggles on the same day don't create multiple records.
- **Heatmap intensity**: based on activity count for that day. Personal heatmap: binary (active or not). Team heatmap: intensity scales with number of distinct members active that day.

## Real-time Updates

Use Supabase Realtime subscriptions on all four tables. When any member updates their progress or notes, all other open browsers see the change reflected in:
- Dashboard stats
- Team heatmap
- Member list (streak, progress, last active)
- Individual hub views

## Design System

Inherits from existing landing page:
- **Fonts**: DM Serif Display (headings), DM Sans (body)
- **Colors**: `--ink: #111`, `--paper: #fff`, `--accent: #d4622b`, `--card-bg: #f8f8f8`, `--border: #e5e5e5`
- **Streak palette**: `#fed7aa`, `#fb923c`, `#ea580c`, `#9a3412` (light to dark orange)
- **Status colors**: green (`#22c55e`) for done, yellow (`#fef3c7`/`#92400e`) for in-progress, gray for not started
- **Border radius**: 10-12px for cards, 8px for buttons/tabs, 3px for streak cells
- **No emojis in the workspace UI** -- use color and typography for visual hierarchy

## Supabase Project

New Supabase project dedicated to this cohort page. Keep it isolated from Homer/Parallax.

## What This Is Not

- Not a chat app (they have a group chat elsewhere)
- Not a grading system (no scores, no rankings)
- Not gated (no login, no passwords)
- Not a SaaS product (10 people, one cohort, one purpose)
