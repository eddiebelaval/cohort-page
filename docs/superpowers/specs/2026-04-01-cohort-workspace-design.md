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
| color | text | avatar color, assigned on join |

**`activity`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| activity_date | date | the day activity occurred |
| activity_type | text | 'checkbox' or 'note' |
| created_at | timestamptz | default now() |

**`progress`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| item_key | text | e.g. 'claude101_intro', 'cca_debugging' |
| completed | boolean | default false |
| completed_at | timestamptz | nullable |

**`notes`**
| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto-generated |
| member_id | uuid (FK) | references members.id |
| content | text | markdown or plain text |
| updated_at | timestamptz | default now() |

### RLS Policy

All tables use **anon key** with permissive policies (no auth). All rows readable and writable by anyone with the anon key. This is intentional -- trusted group of 10 people, honor system.

## Page Structure

The page has two modes, controlled by a tab bar:

### Tab Bar

Persistent across all views. Contains:
1. **"Dashboard"** tab (always first)
2. **Named member tabs** (one per joined member, in join order)
3. **"+" tab** (claim a spot, disappears when 10 members exist)

Clicking a member tab shows that member's hub (read-only for others, editable for the tab owner -- but no enforcement, honor system).

### Landing Section

The existing landing page content (pitch, how it works, timeline, resources, CTA, note from Eddie) remains at the top. The workspace lives below it, separated by a clear visual break. Visitors see the pitch first, cohort members scroll down or click a tab to enter the workspace.

### View 1: Collective Dashboard (Dashboard Tab)

BLUF stats grid (4 cards):
- **Members**: X / 10
- **Team Streak**: X days (consecutive days where at least one member had activity)
- **Courses Done**: X / (members * 3) total course completions across all members
- **Target**: "Late June" with subtitle "~12 weeks from start"

**Team Activity Heatmap**: GitHub contribution graph style. 8 weeks of cells (56 days). Color intensity based on how many members were active that day (more members = darker). Uses the orange accent palette: `#fed7aa` (light) to `#9a3412` (dark).

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
- Introduction to Claude
- Prompt Engineering Basics
- Working with Tools
- Best Practices

**Course 2: Claude Code in Action** (https://anthropic.skilljar.com/claude-code-in-action)
- Getting Started
- Code Generation
- Debugging with Claude
- Advanced Patterns

**Course 3: AI Fluency Foundations** (https://claudecertifications.com/courses/ai-fluency-foundations)
- AI Fundamentals
- Agentic Systems
- Architecture Patterns
- Exam Prep

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
