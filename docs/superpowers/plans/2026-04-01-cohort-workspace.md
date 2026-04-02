# Cohort Workspace Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the static cohort landing page into a collaborative learning workspace with per-member hubs, streak tracking, curriculum checklists, and shared notes -- all in a single HTML file backed by Supabase.

**Architecture:** Single `index.html` with inline CSS and JS. Supabase JS Client loaded via CDN provides database persistence and real-time subscriptions. No auth -- identity via localStorage. Deployed to Vercel via GitHub.

**Tech Stack:** HTML/CSS/vanilla JS, Supabase JS Client v2 (CDN), Supabase (Postgres + Realtime)

**Spec:** `docs/superpowers/specs/2026-04-01-cohort-workspace-design.md`

**XSS Note:** This app has no user-generated HTML. All dynamic content (member names, notes) is inserted via `textContent` or template literals where the only dynamic values are data we control (names, dates, numbers, booleans). The Supabase anon key is public by design. The app is used by 10 trusted people with no public write surface beyond what RLS allows.

---

## File Map

All changes happen in a single file:

- **Modify:** `index.html` -- the entire app lives here (landing page + workspace)

The existing `index.html` is ~463 lines of static HTML/CSS. We'll preserve the landing section and add:
1. New CSS variables and workspace styles (~300 lines CSS)
2. Workspace HTML below the landing section (~200 lines HTML)
3. JavaScript for Supabase, state management, rendering, and real-time (~400 lines JS)

Estimated final file size: ~1400 lines.

---

## Task 0: Supabase Project Setup

**Pre-requisite:** Create a new Supabase project for the cohort page before any code tasks.

- [ ] **Step 1: Create Supabase project**

Create a new project called `cohort-page` in the Supabase dashboard. Keep it isolated from Homer/Parallax.

- [ ] **Step 2: Run migration SQL**

Execute this in the Supabase SQL Editor:

```sql
-- Members table
CREATE TABLE members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  color text NOT NULL
);

-- Activity table (streak tracking)
CREATE TABLE activity (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id uuid REFERENCES members(id) NOT NULL,
  activity_date date NOT NULL,
  activity_type text NOT NULL CHECK (activity_type IN ('checkbox', 'note')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(member_id, activity_date, activity_type)
);

-- Progress table (curriculum checkboxes)
CREATE TABLE progress (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id uuid REFERENCES members(id) NOT NULL,
  item_key text NOT NULL,
  completed boolean DEFAULT false,
  completed_at timestamptz,
  UNIQUE(member_id, item_key)
);

-- Notes table (one per member)
CREATE TABLE notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id uuid REFERENCES members(id) NOT NULL,
  content text DEFAULT '',
  updated_at timestamptz DEFAULT now(),
  UNIQUE(member_id)
);

-- RLS: enable on all tables, allow SELECT/INSERT/UPDATE via anon key, no DELETE
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "members_select" ON members FOR SELECT USING (true);
CREATE POLICY "members_insert" ON members FOR INSERT WITH CHECK (true);
CREATE POLICY "members_update" ON members FOR UPDATE USING (true);

CREATE POLICY "activity_select" ON activity FOR SELECT USING (true);
CREATE POLICY "activity_insert" ON activity FOR INSERT WITH CHECK (true);
CREATE POLICY "activity_update" ON activity FOR UPDATE USING (true);

CREATE POLICY "progress_select" ON progress FOR SELECT USING (true);
CREATE POLICY "progress_insert" ON progress FOR INSERT WITH CHECK (true);
CREATE POLICY "progress_update" ON progress FOR UPDATE USING (true);

CREATE POLICY "notes_select" ON notes FOR SELECT USING (true);
CREATE POLICY "notes_insert" ON notes FOR INSERT WITH CHECK (true);
CREATE POLICY "notes_update" ON notes FOR UPDATE USING (true);
```

- [ ] **Step 3: Enable Realtime**

In Supabase Dashboard > Database > Replication, enable Realtime for all four tables: `members`, `activity`, `progress`, `notes`.

- [ ] **Step 4: Record credentials**

Save the project URL and anon key. These will be embedded in `index.html` (acceptable -- anon key is public, RLS protects writes, no DELETE allowed).

---

## Task 1: Add Supabase Client and App Shell CSS

**Files:** Modify `index.html`

Add the Supabase CDN script tag, new CSS variables, and all workspace styles. No functional JS yet -- just the visual foundation.

- [ ] **Step 1: Add Supabase script tag and new CSS variables**

In `<head>`, after the Google Fonts link, add:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

Add new CSS variables inside `:root`:

```css
--green: #22c55e;
--green-muted: #dcfce7;
--yellow-bg: #fef3c7;
--yellow-text: #92400e;
--streak-0: #eee;
--streak-1: #fed7aa;
--streak-2: #fb923c;
--streak-3: #ea580c;
--streak-4: #9a3412;
```

- [ ] **Step 2: Add workspace CSS**

Add all styles for: workspace container, tab bar, stat cards, streak grid, member rows, BLUF bar, course blocks, checkboxes, notes area, join modal. These are the styles from the mockup adapted to production. Key classes:

- `.workspace` -- container below landing section
- `.tab-bar`, `.tab`, `.tab.active`, `.tab.add-tab`
- `.stat-grid`, `.stat-card`, `.stat-value`, `.stat-label`
- `.streak-grid`, `.streak-cell`, `.streak-cell.l1` through `.l4`
- `.member-row`, `.member-avatar`, `.member-progress`
- `.bluf-bar`, `.bluf-item`, `.bluf-value`
- `.course-block`, `.course-item`, `.check`, `.check.done`
- `.notes-area`, `.notes-box`
- `.share-badge`, `.course-badge`, `.course-header`

- [ ] **Step 3: Add workspace HTML skeleton**

Below the closing `</div>` of the landing `.container`, add a visual divider and the workspace shell:

```html
<div style="max-width:680px;margin:48px auto 0;padding:0 24px;">
  <hr style="border:none;border-top:1px solid var(--border);">
</div>

<div class="workspace" id="workspace">
  <div class="container">
    <div class="tab-bar" id="tab-bar">
      <div class="tab active" data-tab="dashboard">Dashboard</div>
      <div class="tab add-tab" id="add-tab">+</div>
    </div>
    <div id="workspace-content"></div>
  </div>
</div>
```

- [ ] **Step 4: Verify page loads**

Open `index.html` locally in browser. Landing page should render unchanged. Empty workspace section with tab bar visible below it. No JS errors in console.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add Supabase client, workspace CSS, and HTML shell"
```

---

## Task 2: Supabase Init, Data Layer, and State Management

**Files:** Modify `index.html` (add `<script>` block before `</body>`)

Build the data layer: Supabase client init, app state object, data fetching functions, and localStorage identity check. No rendering yet.

- [ ] **Step 1: Add Supabase init and app state**

Add a `<script>` block before `</body>` with:
- Supabase client initialization (URL + anon key)
- `AVATAR_COLORS` array (10 colors from spec)
- `CURRICULUM` array (3 courses, each with `course`, `url`, and `items` array of `{key, label}`)
- `EXAM_RESOURCES` array (3 links)
- `ALL_ITEM_KEYS` derived from CURRICULUM
- `state` object: `{ members, activity, progress, notes, currentTab: 'dashboard', myMemberId: localStorage.getItem('cohort_member_id') }`

All data values from the spec (item keys, URLs, colors) should be defined as constants here.

- [ ] **Step 2: Add data fetch functions**

- `fetchAll()` -- parallel fetch from all 4 tables, populates state
- `verifyIdentity()` -- checks if stored `myMemberId` still exists in members table, clears localStorage if not

- [ ] **Step 3: Add helper/computation functions**

- `getMemberProgress(memberId)` -- returns `{ done, total }` counting completed items vs ALL_ITEM_KEYS.length
- `getMemberStreak(memberId)` -- counts consecutive days backwards from today where member has activity
- `getTeamStreak()` -- counts consecutive days backwards from today where any member has activity
- `getLastActive(memberId)` -- returns most recent activity_date or null
- `getHeatmapData(memberId)` -- returns 56 cells (8 weeks ending today), each `{ date, count }`. If memberId is null, count = distinct members active that day (team view). If memberId provided, count = 0 or 1 (personal view).
- `streakLevel(count, isTeam)` -- returns CSS class string: '' for 0, 'l3' for personal active, 'l1'-'l4' for team based on member count thresholds
- `getCoursesDone()` -- counts courses where all 4 items are completed, across all members
- `formatDate(dateStr)` -- returns 'today', 'yesterday', or 'Mon DD' format

- [ ] **Step 4: Verify no errors**

Open in browser. Console should show no errors. No visual changes yet.

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add Supabase init, app state, and data computation helpers"
```

---

## Task 3: Rendering -- Tab Bar, Dashboard View, and Slot Grid

**Files:** Modify `index.html` (add to the `<script>` block)

Build the render functions for the tab bar, the collective dashboard, and update the landing page slot grid to show real member names.

- [ ] **Step 1: Add tab bar renderer**

`renderTabs()`:
- Clears tab bar, rebuilds from state.members
- Dashboard tab always first, active class based on state.currentTab
- One tab per member in join order
- "+" tab at end if < 10 members, calls showJoinModal on click

`switchTab(tabId)`:
- Sets state.currentTab, calls renderTabs + renderWorkspace, smooth-scrolls to workspace

- [ ] **Step 2: Add dashboard renderer**

`renderDashboard()` returns HTML string for the collective dashboard:
- 4-card stat grid (members count, team streak, courses done, target date)
- Team heatmap (56 cells from getHeatmapData(null))
- Member list: each row shows avatar (colored, first initial), name, last active, mini streak (7 dots), streak count, progress bar. Rows are clickable (switchTab to that member).

Use DOM creation methods (createElement, textContent, appendChild) for user-generated content (member names). Template literals are acceptable for structural HTML where dynamic values are numbers/dates/booleans.

- [ ] **Step 3: Add slot grid updater**

`updateSlotGrid()`:
- Replaces existing .slots-grid children with real member data
- Filled slots show first initial with member's color background
- Open slots show position number with dashed border
- Updates .slots-count text and .badge text with remaining count

- [ ] **Step 4: Add workspace router**

`renderWorkspace()`:
- If currentTab is 'dashboard', render dashboard
- Otherwise render hub for that member ID

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add tab bar, dashboard view, and dynamic slot grid renderers"
```

---

## Task 4: Rendering -- Personal Hub View

**Files:** Modify `index.html` (add to the `<script>` block)

Build the personal hub renderer: BLUF bar, personal heatmap, curriculum checklist with clickable links, and notes.

- [ ] **Step 1: Add hub renderer**

`renderHub(memberId)` returns HTML for the personal hub:

1. **BLUF bar** (3 cards): streak count, % complete, last check-in date
2. **Personal heatmap** (56 cells from getHeatmapData(memberId))
3. **Curriculum section**: For each course in CURRICULUM:
   - Course title + auto-computed status badge (Done/In Progress/Not Started)
   - Checklist items, each with:
     - Clickable checkbox (only if isOwner = memberId === state.myMemberId), calls `toggleItem(key)`
     - Item label as a link to the course URL (opens in new tab)
4. **Exam Prep Resources** (bonus section, dashed border, not checkboxes, just links)
5. **Notes section**:
   - If isOwner: editable textarea with id="notes-input", oninput calls debounceSaveNote()
   - If not owner: read-only div showing note content
   - "Visible to cohort" badge

Use textContent for member names and note content to prevent XSS. Checkbox state and item keys are from controlled constants.

- [ ] **Step 2: Verify renders**

Visual check: both dashboard and hub views render correctly with empty/mock data.

- [ ] **Step 3: Commit**

```bash
git add index.html
git commit -m "feat: add personal hub renderer with BLUF, curriculum, and notes"
```

---

## Task 5: Actions -- Join, Toggle Checkbox, Save Notes

**Files:** Modify `index.html` (add to the `<script>` block)

Wire up user interactions: joining the cohort, toggling checkboxes, and saving notes.

- [ ] **Step 1: Add join flow**

`showJoinModal()`:
- If myMemberId already set, alert and return
- Use `prompt()` for name input (simple, no modal needed for 10 people)
- Call joinCohort(name)

`joinCohort(name)`:
- Assign color from AVATAR_COLORS based on current member count
- Insert into members table, select back the row
- Handle duplicate name error (Postgres unique violation code 23505)
- Save member_id to localStorage
- Insert empty notes row
- fetchAll, updateSlotGrid, switchTab to new member

- [ ] **Step 2: Add checkbox toggle**

`toggleItem(itemKey)`:
- Guard: return if no myMemberId
- Find existing progress row, compute new completed state (toggle)
- Upsert into progress table with onConflict: 'member_id,item_key'
- Upsert activity record for today with onConflict: 'member_id,activity_date,activity_type'
- fetchAll + renderWorkspace + updateSlotGrid

- [ ] **Step 3: Add notes auto-save**

`debounceSaveNote()`: clears and resets a 2-second timer to call saveNote()

`saveNote()`:
- Guard: return if no myMemberId or no notes-input element
- Upsert into notes table with onConflict: 'member_id'
- Upsert activity record for today (type: 'note')
- Partial state refresh (activity + notes only) -- do NOT re-render workspace (would lose cursor/selection)

Also add focusout listener on document: if target is notes-input, immediately save.

- [ ] **Step 4: Verify all actions work**

Test locally with Supabase connected:
1. Click "+" tab, enter a name -- should create member and switch to hub
2. Check a curriculum item -- checkbox should fill, streak should update
3. Type in notes -- should auto-save after 2 seconds
4. Refresh page -- all state should persist

- [ ] **Step 5: Commit**

```bash
git add index.html
git commit -m "feat: add join flow, checkbox toggle, and notes auto-save"
```

---

## Task 6: Real-time Subscriptions and App Init

**Files:** Modify `index.html` (add to the `<script>` block)

Wire up Supabase Realtime so all browsers update when anyone makes a change. Add the app initialization sequence.

- [ ] **Step 1: Add real-time subscriptions**

`subscribeRealtime()`:
- Create single Supabase channel 'cohort-changes'
- Subscribe to postgres_changes on all 4 tables (event: '*', schema: 'public')
- Handler: `handleRealtimeChange()`

`handleRealtimeChange()`:
- Save current focus state (is user typing in notes-input? save cursor position and value)
- fetchAll + updateSlotGrid + renderTabs + renderWorkspace
- Restore notes textarea value and cursor position if user was typing (prevents losing their work mid-keystroke)

- [ ] **Step 2: Add app init**

`init()` (async, called immediately):
- await fetchAll()
- await verifyIdentity()
- updateSlotGrid()
- If myMemberId exists, set currentTab to myMemberId
- renderTabs + renderWorkspace
- subscribeRealtime()
- If myMemberId exists, setTimeout 300ms then smooth-scroll to workspace

Call `init()` at end of script block.

- [ ] **Step 3: End-to-end test**

Open two browser windows side by side:
1. In window 1: join as "Eddie", check some boxes, write a note
2. In window 2: join as "TestUser"
3. Verify window 1 sees TestUser appear in real-time (dashboard, slot grid, member list)
4. In window 2: check a box -- verify window 1 dashboard stats update
5. Verify streaks, heatmaps, and progress bars all reflect live data

- [ ] **Step 4: Commit**

```bash
git add index.html
git commit -m "feat: add real-time subscriptions and app initialization"
```

---

## Task 7: Polish and Deploy

**Files:** Modify `index.html`

Final pass: mobile responsiveness for workspace, credential replacement, and deploy.

- [ ] **Step 1: Add mobile responsive styles**

Add to the existing `@media (max-width: 520px)` block:

```css
.stat-grid { grid-template-columns: 1fr; }
.bluf-bar { grid-template-columns: 1fr; }
.tab-bar { padding: 10px 12px; }
.tab { padding: 6px 12px; font-size: 12px; }
.member-row { flex-wrap: wrap; }
.member-streak { order: 3; width: 100%; margin-top: 4px; }
```

- [ ] **Step 2: Replace Supabase credentials**

Replace `YOUR_PROJECT_URL` and `YOUR_ANON_KEY` with the actual values from Task 0.

- [ ] **Step 3: Full QA pass**

Test checklist:
- [ ] Landing page renders correctly (unchanged look)
- [ ] Slot grid updates with real member names and colors
- [ ] Badge count updates dynamically
- [ ] "+" tab creates a member and switches to hub
- [ ] Duplicate name shows error message
- [ ] Dashboard stats are accurate (members, streak, courses done)
- [ ] Team heatmap shows correct 8-week rolling window
- [ ] Member rows are clickable, switch to hub view
- [ ] BLUF bar shows correct streak/progress/last-active
- [ ] Curriculum checkboxes toggle and persist across refresh
- [ ] Curriculum items link to correct course URLs (open in new tab)
- [ ] Course status badges update (Not Started > In Progress > Done)
- [ ] Exam prep resources section shows with working links
- [ ] Notes save on blur and after 2s idle
- [ ] Other member tabs show read-only notes
- [ ] Real-time: changes in one window appear in another
- [ ] Mobile: all views readable on 375px width
- [ ] Returning member: auto-scrolls to workspace on reload
- [ ] localStorage cleared: visitor sees read-only view, "+" tab works

- [ ] **Step 4: Commit and push**

```bash
git add index.html
git commit -m "feat: complete cohort workspace with real-time collaboration"
git push origin main
```

Vercel auto-deploys. Verify at https://cohort-page.vercel.app.

---

## Summary

| Task | What | Depends On |
|------|------|-----------|
| 0 | Supabase project + migration | Nothing |
| 1 | CSS + HTML shell | Task 0 (need URL/key) |
| 2 | Data layer + state | Task 1 |
| 3 | Tab bar + dashboard + slot grid | Task 2 |
| 4 | Personal hub renderer | Task 2 |
| 5 | Join, checkbox, notes actions | Tasks 3 + 4 |
| 6 | Real-time + init | Task 5 |
| 7 | Polish + deploy | Task 6 |

Tasks 3 and 4 can run in parallel (both depend on Task 2, neither depends on each other).
