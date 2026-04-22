# For Beginners — onramp track

Optional prerequisite-level onramp for cohort members who are new to Claude. Mirrors curated foundational Anthropic lessons from Anthropic Academy and `docs.claude.com`. Progress here does NOT count toward the main CCA cert curriculum — it's a side-path for members who want to come up to speed before the main track.

## Rules for this track

1. **Every lesson is a 1:1 mirror of Anthropic-hosted content.** We don't write lessons — we curate and link.
2. **Every lesson should be genuinely prerequisite-shaped** for the Claude Certified Architect cert. If a lesson is "nice to know" but not actually foundational, leave it out.
3. **Keep it small — 5 to 10 items max.** This is an onramp, not a second curriculum.
4. **URLs should be stable.** Anthropic Academy URLs (`anthropic.skilljar.com/{slug}`) and `docs.claude.com` URLs are both stable enough. Blog posts are not.

## The canonical list

The list lives in `index.html` as the `BEGINNERS_COURSE` constant (search for it near the top of the main script block, right before `CURRICULUM`). This doc describes *why each lesson is on the list* — edit both when adding/removing.

| Item Key | Title | Why it matters for the cert |
|---|---|---|
| `beginners-meet-claude` | Meet Claude | Foundational: what Claude is, what it isn't, the mental model. Everything else assumes you have this. |
| `beginners-ai-fluency-intro` | AI Fluency: Framework and Foundations (intro) | The AI Fluency framework is one of the cert-prep courses (`CERT_COURSES[1]`); its intro lesson alone is a cheap way to acclimate. |
| `beginners-prompt-eng-basics` | Prompt Engineering Overview | Every cert course assumes prompt-engineering literacy. This is the gentlest entry point. |
| `beginners-api-getting-started` | API — Your First Call | The Building with Claude API course (`CPN_COURSES[1]`) moves fast; making a first call beforehand flattens the ramp. |
| `beginners-claude-code-overview` | Claude Code — Overview | Two of the six tracked courses are Claude Code-heavy (`CPN_COURSES[3]`, implicit in cert content). 10-minute overview before those helps. |
| `beginners-tool-use-basics` | Tool Use Basics | Tool use / function calling is a recurring theme across the API course, MCP course, and Cowork course. Understanding the primitive first makes those sections land. |

## How to edit

1. Update the `BEGINNERS_COURSE.items` array in `index.html`.
2. Update the table above with the same lesson keys, titles, and a one-line "why it matters" for each.
3. Test locally: load the hub, confirm the For Beginners section renders the new items, click a checkbox, reload, confirm state persists.
4. Commit with a message like `content: update Beginners track (added X, removed Y)`.

## What NOT to put here

- **Courses already in the main curriculum.** If it's in `CPN_COURSES` or `CERT_COURSES`, don't also list it here.
- **Long courses.** This is a quick warm-up — 6 × 15-min lessons, not 6 × multi-hour courses.
- **Content behind logins members don't have.** Anthropic Academy requires a free account (that's fine). Anything behind a paywall or an Anthropic-employee-only gate is out.
- **Opinion pieces or community blog posts.** Stick to Anthropic-hosted canonical material.

## Why optional (not mandatory)

Members arrive at different skill levels. A senior engineer who's shipped with the Anthropic SDK for six months doesn't need Meet Claude. A product manager touching the API for the first time does. Making this module optional and clearly labeled lets both paths feel right — neither "I'm wasting my time on kid stuff" nor "I'm lost already."
