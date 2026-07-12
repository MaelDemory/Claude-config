---
name: frontend-design
description: Frontend-design, DESIGN.md, UI quality, design system, visual identity, contrast, hero/section layout, and component reuse. Use before and after frontend implementation.
---
# Frontend Design

Use this as the UI design-system and quality gate for frontend work. It is self-contained and requires:
- `DESIGN.md` as a project-level design source of truth.
- Distinctive, subject-grounded visual direction instead of generic UI defaults.
- Product-category reasoning: category → pattern/style/colors/type/effects/anti-patterns/checklist.

## DESIGN.md workflow

Before changing UI:
1. Look for `DESIGN.md` at the workspace/project root.
2. If it exists, treat it as the design source of truth.
3. If it is missing and the task is UI-significant, create or propose a `DESIGN.md` using the required template below.
4. If the requested UI conflicts with `DESIGN.md`, state the conflict and choose the smallest safe update.
5. After UI work, update `DESIGN.md` only when a reusable token, component rule, brand rule, or anti-pattern was discovered.

## Required DESIGN.md template

```markdown
# DESIGN.md

## Product context
- Product: <name>
- Audience: <users>
- Primary job: <what the interface must help users do>
- Brand personality: <3-5 adjectives>

## Design principles
- <principle> — <practical implication>

## Visual identity
- Signature element: <the one memorable visual idea>
- Style direction: <e.g. Swiss, editorial, bento, soft UI, brutalist, etc.>
- Anti-patterns to avoid: <generic gradients, low contrast, etc.>

## Tokens
| Token | Value | Usage |
|---|---|---|
| Color / primary | `<hex>` | <usage> |
| Color / background | `<hex>` | <usage> |
| Type / display | `<font/fallback>` | <usage> |
| Type / body | `<font/fallback>` | <usage> |
| Space / rhythm | `<scale>` | <usage> |

## Components
| Component | Rule | Reuse path |
|---|---|---|
| Button | <contrast, states, sizing> | `<path>` |
| Card | <spacing, border, shadow> | `<path>` |

## Layout rules
- Breakpoints: <mobile/tablet/desktop>
- Hero/section sizing: <viewport/full-width rules>
- Grid/alignment: <rules>

## Interaction and motion
- Hover/focus/active states: <rules>
- Motion: <duration/easing/reduced-motion rule>

## Accessibility
- Contrast target: WCAG AA minimum unless explicitly stricter.
- Keyboard/focus: <rules>
- Semantics: <rules>

## Page overrides
- `<route/page>` — <only deviations from this master design system>

## Maintenance notes
- Last updated: <date>
- Update when: <trigger>
```

## Design reasoning workflow

Before coding, produce a compact design plan:
- Product category and audience.
- Landing/app pattern: hero-centric, conversion, feature-rich, dashboard, data-dense, etc.
- Style direction and why it fits the product.
- 4-6 color tokens with hex values and semantic usage.
- Typography roles: display, body, utility/data.
- Effects/motion: purposeful only.
- Anti-patterns: what not to do for this product category.
- One justified aesthetic risk.

## Preferred inspiration qualities

Aim for the same kind of design language and execution quality:
- Linear-like product clarity: crisp hierarchy, disciplined spacing, restrained surfaces, fast-feeling interactions, precise copy, strong dark/light contrast.
- Apple-like polish: generous whitespace, confident typography, premium motion restraint, tactile detail, excellent alignment, simple flows that feel inevitable.

It is acceptable to emulate this aesthetic direction: minimal, premium, precise, calm, high-contrast, highly polished. Adapt it to the project's own identity and content. Avoid only literal trademark use, copied logos/assets, or one-to-one page duplication.

Then critique the plan:
- Does it look like a generic AI default?
- Is the signature element grounded in the subject?
- Are structure, typography, and copy doing functional work?
- Is complexity appropriate to the product?

## UI decision examples

Good:
- Product category drives form: a data-heavy admin dashboard uses dense tables, restrained color, clear filters, and persistent status affordances.
- Signature element is subject-grounded: a finance app uses subtle ledger/grid motifs and sober contrast instead of generic neon gradients.
- Tokens are semantic: `--color-danger-bg`, `--color-surface-raised`, and `--space-section` map to behavior and layout use.
- Components are reused first: existing `Button`, `Card`, `Dialog`, and form controls are extended through props/classes before creating one-off markup.

Bad:
- Picking purple/pink gradients because they look modern, without product rationale.
- Creating a new button/card style when a project component already exists.
- Making a hero visually impressive but not responsive at 375px or not keyboard accessible.
- Updating `DESIGN.md` with one-off page details that do not become reusable design rules.

## UI construction anti-slop rules

- Translate references into component anatomy and behavior before styling. If the user says “Notion-like,” “Linear-like,” or points to a screenshot, identify the actual structure: title order, property rows, body/content mode, metadata policy, edit/read states, density, and interactions.
- Avoid container nesting by default. Do not build `card > panel > card > full-card button` unless each wrapper has a distinct semantic, layout, or accessibility job. Prefer one clickable card surface with clear internal content regions.
- Cards must have explicit sizing and overflow behavior. Clamp long text, prevent content from escaping, and verify the rendered card does not grow or leak beyond its intended box.
- Lists and kanban columns should stack items naturally with fixed gaps. Do not use CSS grid/stretching patterns that distribute cards vertically unless that exact behavior is intended.
- Do not duplicate metadata already implied by layout. For example, a card inside a status column usually does not need its own status chip. Do not invent avatars, initials, badges, timestamps, or property fields unless the user/product model requires them.
- For modal/dialog work, verify opened-state layering. Sticky headers, rails, and floating bars must not appear above or visually compete with the dialog/backdrop unless explicitly designed.
- For property panels and forms, decide whether borders belong to rows or controls, not both. If the user asks for borderless fields, keep controls visually quiet while preserving an accessible focus treatment.
- Render rich text/Markdown in read mode when users are reading. Show raw Markdown only in explicit edit mode unless the product is a source editor.
- Make visual verification incremental. After changing card anatomy, list spacing, modal layering, or form focus styles, run a browser snapshot/interaction check before piling on more CSS.

## When DESIGN.md changes are justified

Update or create `DESIGN.md` when:
- A reusable token, component rule, layout convention, brand rule, or accessibility policy is introduced.
- The project lacks a design source of truth and the task is UI-significant.
- A repeated anti-pattern is discovered and future agents need a guardrail.

Do not update `DESIGN.md` for:
- Pure copy edits, bug fixes, or one-off page-specific styling that will not recur.
- Mechanical refactors with no visual/design-system change.
- User-requested experiments that should remain local until accepted.

## Common failures to prevent
- Button text has the same or too-similar color as the button background.
- Primary/secondary button states are visually unclear.
- Hero or section does not fill the intended viewport/width.
- Text blocks are poorly aligned or lack hierarchy.
- No recognizable identity: generic gradients, cards, stats, or stock SaaS layouts.
- One component/file grows toward 1000 lines instead of splitting into smaller components.
- CSS specificity conflicts cancel spacing, color, or state styles.
- Emoji-as-icon defaults where SVG icons/components should be used.
- Nested rounded containers create “card inside card inside card” slop and make overflow/focus bugs harder to see.
- Metadata bloat makes cards noisy: status repeated from a column, meaningless avatars/initials, timestamps without a product need, and properties not backed by real data.
- Modal overlays are visually broken when sticky headers or sidebars sit above the backdrop.
- Source-only Markdown is wrong for read-mode task details unless explicitly requested.

## cmux visual verification

When the app can run locally and `cmux` is available, treat cmux as the frontend visual/runtime verification layer. It does not replace tests; it catches real-browser issues that static checks miss.

Recommended flow:
1. Start or identify the dev server URL from project commands.
2. Open the route: `cmux browser open <url>` or `cmux browser goto <url>`.
3. Wait for readiness: `cmux browser wait --selector <selector>` or `cmux browser wait --text <text>`.
4. Inspect the page: `cmux browser snapshot --compact`, `cmux browser screenshot --out <path>`, or `cmux browser get <text|title|url>`.
5. Check runtime health: `cmux browser errors list` and `cmux browser console list`.
6. Interact with the critical path when relevant: `cmux browser click`, `fill`, `type`, `press`, `is visible`, or `find`.

Use cmux especially for:
- layout/spacing/overflow checks,
- responsive visual checks,
- contrast or invisible text/button regressions,
- route-level runtime errors,
- forms, dialogs, menus, and keyboard/focus behavior.

If cmux cannot be used, state why and fall back to screenshots, Playwright, manual browser instructions, or static checks.

## Pre-delivery checklist
- DESIGN.md checked or created/proposed.
- Existing components reused before one-off markup.
- Contrast passes for text, buttons, links, and disabled states.
- Responsive checks cover at least 375px, 768px, 1024px, and 1440px when practical.
- cmux/browser visual check run when the app is runnable, or skipped with a reason.
- Keyboard focus is visible.
- `prefers-reduced-motion` is respected for non-trivial motion.
- Cursor/hover/focus states exist for clickable elements.
- Empty/error/loading states use clear user-facing copy.
- No generic AI purple/pink gradient unless explicitly justified.
- Cards/lists: item height, overflow, clamp, and inter-item gaps checked in browser.
- Dialogs/modals: opened-state layering checked against sticky headers/sidebars.
- Forms/property panels: focus, hover, row borders, input borders, and read/edit modes checked in browser.

## Required output template

```markdown
## DESIGN.md status
- Found/created/updated/skipped: <status and path>

## Design intent
- Product/audience/job: <summary>
- Pattern/style: <chosen pattern and why>
- Visual identity: <palette, typography, layout signature, aesthetic risk>

## Component/token choices
- Components reused: `<path>` / none
- Tokens/classes used: <summary>
- DESIGN.md updates: <summary or `None`>

## Quality checks
- Contrast: pass/fail + notes
- Alignment/hierarchy: pass/fail + notes
- Hero/section sizing: pass/fail + notes
- Responsiveness: pass/fail + notes
- cmux/browser runtime: pass/fail/skipped + URL, commands, console/errors summary
- Accessibility/focus: pass/fail + notes
- Motion/reduced-motion: pass/fail + notes

## Fixes applied or required
- `<path>` — <fix>
```
