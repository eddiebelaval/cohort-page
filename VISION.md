---
title: "VISION.md"
date: 2026-04-16
author: Eddie Belaval
product: Cohort Hub
confidence: High
distance-from-spec: 35% (7 of 11 pillars realized, 1 partial, 3 unrealized)
---

# VISION.md -- Living North Star
## Cohort Hub (cohort-page)

> Last evolved: 2026-04-16 | Confidence: HIGH
> Distance from SPEC: 35% (7 of 11 pillars realized, 1 partial, 3 unrealized)

---

## Soul

The cohort hub exists so a group of people studying for the Claude Certified Architect exam can pull each other through it. Certification study alone is where good intentions die; a live shared surface — where you can see who showed up today, whose streak is longer than yours, and what the group is reading — converts intention into daily traction. This is the shared workspace that makes the cohort real instead of a WhatsApp group with good vibes.

## Pillars

The core commitments this product makes. Each pillar is directional, not detailed.

1. **Public landing that converts visitors into cohort members** -- REALIZED
   A single page that explains the cohort, shows real signups, and has a low-friction "claim your spot" flow. Credibility first, CTA second.

2. **Lightweight onboarding (no passwords, no friction)** -- REALIZED
   Magic link auth via Supabase. No forgotten passwords, no mobile app install, works on any device.

3. **Per-member hub** -- REALIZED
   Each member has a dashboard showing their curriculum progress, activity streak, notes, bookmarks, and a URL that survives across devices via magic link.

4. **Progress tracking against the real curriculum** -- REALIZED
   43 curriculum items across 6 Anthropic-issued courses, matched 100% to Skilljar source. Checking off an item triggers the streak system.

5. **Activity streak + heatmap** -- REALIZED
   GitHub-style heatmap per member. Streak extends whenever any member does an activity (checkbox, note, bookmark, quiz). The pattern of green squares is the social pressure.

6. **Shared accountability surfaces** -- REALIZED
   Community heatmap shows who was active each day. Recent Activity feed. Readiness score. Streak leaderboard. Shared bookmarks. You can see the cohort from any screen.

7. **Daily learning content (Pro Tip of the Day)** -- REALIZED
   90 tips covering 3 months of daily material, rotated deterministically so everyone sees the same tip the same day.

8. **Recall practice (quizzes)** -- PARTIAL (scaffolded, Allie is building)
   Scaffold shipped 2026-04-16 with integration contract. Schema proposal in place. Full implementation in progress on `feature/quizzes` PR #5 and successors. Target: every member takes at least one quiz that extends their streak.

9. **External knowledge integration** -- UNREALIZED
   The id8Labs KB (id8pedia, MemPalace) contains 1,800+ articles relevant to Claude development. Goal: surface CCA-relevant articles inside the hub so members aren't context-switching to find reference material.

10. **Live cohort events (office hours surface)** -- UNREALIZED
    Currently office hours live in WhatsApp. Goal: a lightweight in-hub surface that shows next session time, RSVPs, and session notes, without becoming Zoom.

11. **Federation with other id8Labs products** -- UNREALIZED
    Goal: a member of the cohort hub is a member of the federation. Same identity carries to Homer, Parallax, Milo, and id8pedia without re-onboarding.

## User Truth

The user is someone who has decided they want to get CCA certified but has not yet done the courses. They have high intent and low traction. Before using this: the certification lives as a browser tab they keep meaning to come back to. After using this: they show up because other people are here and they do not want to break the streak. The conversion target is not "knowledge acquired" — it is "daily return". Knowledge follows when return becomes a habit.

A secondary user is Eddie himself, running the cohort. The hub reduces his operational load: members self-serve onboarding, see their own progress, surface their own blockers. His job shrinks from "nag" to "host".

## Edges

This product is a study workspace for one specific certification, not a general LMS. It explicitly does not:

- Deliver course content (Anthropic's learning portal does that — the hub links out)
- Handle payments (the cohort is free by design)
- Run a full forum / message board (WhatsApp handles real-time chat)
- Replace 1:1 support (office hours live elsewhere)
- Serve as a public-facing brand site (that is id8labs.app)

The hub is the shared study surface between course consumption and live human interaction. Everything outside that zone is not our problem.

## Anti-Vision

This product must never become:

- **A gated LMS with pricing tiers.** The moment a paywall goes up, the cohort dynamic dies. If we ever charge, it is for the cohort experience (cohort-as-product), not per-feature.
- **A feature-creep notion clone.** Every feature must pull someone back to the hub tomorrow. If it does not drive return, it does not ship.
- **A solo productivity tool.** The whole point is shared presence. A feature that works identically for a cohort of 1 and a cohort of 60 is in the wrong product.
- **A place members need to check three times a day.** Daily is the right cadence. Multiple-times-a-day means we are competing with WhatsApp and we will lose.
- **A surveillance tool.** We show who is active; we never show what they are struggling with unless they opt in (notes, bookmarks). The heatmap is accountability, not a panopticon.

## Evolution Log

| Date | What Shifted | Signal | Section |
|------|-------------|--------|---------|
| 2026-04-16 | Codified pillars, distance from SPEC, anti-vision | First external contributor (Allie) joining — shared context required | All sections (initial authoring) |

---

**Companion documents:** `SPEC.md` (what it IS now), `BUILDING.md` (how we got here).
**The gap between VISION and SPEC is the work.**

**Derived outputs:** `/roadmap` `/drift` `/changelog` `/pitch` `/debt` `/onboard` — computed from the triangle, never stored.
