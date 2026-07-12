---
name: cartography
description: Cartography, deep codebase map, repo map, onboarding map, or navigation index. Use for explicit codebase mapping/onboarding requests that need multiple cartography subagents and docs/indexes.
---
# Cartography

Use this skill when the user explicitly asks to map, onboard, document, index, or navigate a full codebase, especially when a single cartography pass would be too shallow.

## Goal

Produce durable navigation knowledge:
- Exact-path maps of the codebase.
- Concise docs for major slices.
- A compact index that routes future agents from questions to files/docs.
- Explicit gaps, uncertainty, and verification notes.

## Orchestration workflow

1. Establish scope.
   - Identify the repo/root path and whether this is onboarding, a refresh, or a focused area map.
   - If the target repo is ambiguous, ask one blocking question.
   - If there is an existing project session, use `start-session` first when durable context matters.

2. Do a quick root reconnaissance.
   - Inspect root docs, manifests, workspace files, package/service folders, CI/config, and existing `.opencode/docs` or `.opencode/architecture` files.
   - Use this only to decide how to split the work; do not attempt a full map in the coordinator context.

3. Split the repo into slices.
   - Small repo: one `cartography` subagent may be enough, plus `indexor`.
   - Medium/large repo: launch multiple `cartography` subagents concurrently.
   - Prefer slices such as:
     - Docs/product/setup/deployment.
     - Frontend/UI/routes/components/state/styling.
     - Backend/API/services/jobs/auth/integrations.
     - Data/storage/models/schemas/migrations/seeds.
     - Tests/quality/tooling/CI/scripts.
     - Monorepo packages/shared libraries/service boundaries.
     - Cross-cutting flows: auth, request lifecycle, data flow, background jobs, deployment.

4. Prompt each cartography subagent with a bounded assignment.
   - Include the repo path, slice name, files/directories to prioritize, and expected outputs.
   - Require exact paths, existing docs found, new/updated docs, missing info, and confidence.
   - Tell the subagent to use `create-doc` and/or `create-architecture` templates exactly when it writes docs.
   - Tell the subagent not to edit application/source code.

5. Synthesize the maps.
   - Merge overlapping findings without duplicating docs.
   - Resolve conflicts by preferring exact file evidence and more recently read files.
   - Create or update high-level docs such as:
     - `.opencode/docs/repo-map.md`
     - `.opencode/docs/feature-map.md`
     - `.opencode/docs/entrypoints.md`
     - `.opencode/docs/testing-map.md`
     - `.opencode/docs/dependency-map.md`
     - `.opencode/architecture/_index.md`
   - Keep docs concise and route-oriented.

6. Build navigation indexes.
   - Delegate to `indexor` after cartography docs exist.
   - Require `create-index` and exact route tables.
   - Expected indexes include `.opencode/docs/_index.md` and architecture/project indexes where useful.

7. Persist durable knowledge only when appropriate.
   - Use `memory-write` for reusable project facts with evidence.
   - Use `/Users/hugo/Documents/ObsidianMemory` as the configured vault root.
   - Ask before broad vault writes.

8. Final handoff.
   - Use `wrap-up`.
   - Include changed docs/indexes, subagent slices run, commands/checks run, gaps, and confidence.

## Sizing guide

- Small repo: one app/package, fewer than ~10 top-level source folders, clear README/scripts. Use one cartography subagent and one indexor pass.
- Medium repo: multiple apps/packages, mixed frontend/backend/data/test areas, or sparse docs. Use 3–5 cartography subagents by slice.
- Large repo/monorepo: many services/packages, multiple runtimes, generated clients, or unclear ownership. Use bounded waves of cartography subagents; synthesize after each wave before launching more.

## Evidence requirements

- Every architectural claim should cite at least one exact path.
- Every important command should cite its source file, usually a package manifest, Makefile, task runner config, CI file, README, or script.
- Every flow should name the entrypoint, the next 2–5 important files/modules, and the output/side effect.
- If a slice cannot be verified because files are missing, generated, or inaccessible, label it as an unknown instead of filling the gap.

## Good vs bad cartography

Good:
- `src/app/api/**` — Next.js API route handlers; auth middleware enters via `src/middleware.ts`; database access goes through `src/server/db/*`.
- `pnpm test` — defined in `package.json`; runs Vitest unit tests under `src/**/*.test.ts`.
- Unknown: deployment target not found in root docs, CI, or package scripts.

Bad:
- “This is a typical React app with an API backend.” without paths.
- “Probably uses PostgreSQL.” without config, dependency, or schema evidence.
- A giant prose summary that does not route future agents to files.

## Subagent prompt template

```text
You are the cartography subagent for <repo path>.

Slice: <slice name>
Priority paths: <paths or discovery targets>

Map this slice deeply enough that a future agent can navigate it without rereading the whole repo.

Required work:
1. Read relevant docs/config/manifests for this slice.
2. Identify entrypoints, modules, key flows, dependencies, tests, and verification commands that apply to this slice.
3. Create or update concise docs only when useful, using `create-doc` and/or `create-architecture` templates exactly.
4. Do not edit application/source code.
5. Return exact paths discovered, docs changed, commands/checks run, missing info, and confidence.
```

## Quality bar

- Prefer exact paths over summaries.
- Prefer route tables over long prose.
- Do not invent architecture, features, or files.
- Make uncertainty visible.
- Avoid indexing generated/vendor files unless the task explicitly needs them.
- Do not let one broad subagent do the whole job for a large repo; fan out and then synthesize.
- Stop adding docs when the index can already route future agents; avoid documentation sprawl.
