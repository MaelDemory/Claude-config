# Project Rules

## Overview
This project is built and maintained by an AI agent team managed via OpenClaw. Every agent MUST read and follow these rules before starting any work.

## Tech Stack

### Mobile
- React Native + Expo (latest SDK)
- Navigation: expo-router
- Styling: NativeWind (Tailwind CSS for RN) — MANDATORY
- State: zustand
- Forms: react-hook-form + zod
- Backend: Supabase (Auth, DB, Edge Functions, Storage)
- Deployment: EAS

### Web
- Next.js + TypeScript (App Router)
- Styling: Tailwind CSS — MANDATORY
- UI Components: shadcn/ui
- State: zustand
- Forms: react-hook-form + zod
- Backend: Supabase
- Deployment: Vercel

## Code Conventions
- TypeScript strict mode everywhere — no `any` unless justified with a comment
- Absolute imports configured in tsconfig
- No custom CSS — Tailwind/NativeWind only
- All components are functional (no class components)
- One component per file
- File names: kebab-case for files, PascalCase for components

## Git Conventions

### Branches
```
main                    ← production, protected
dev                     ← integration branch
feat/front-XXX          ← frontend feature branches
feat/back-XXX           ← backend feature branches
fix/front-XXX           ← frontend bugfixes
fix/back-XXX            ← backend bugfixes
```

### Commits
Format: `<type>(<scope>): <TASK-ID> <description>`

Types: feat, fix, docs, style, refactor, test, chore
Scopes: front, back, qa, content, project

Examples:
```
feat(front): FRONT-001 add login screen with Supabase auth
feat(back): BACK-003 create profiles table with RLS policies
fix(front): FRONT-001 fix keyboard overlap on login form
docs(qa): update KANBAN and CHANGELOG for BACK-003
content: add App Store listing in FR and EN
```

### Branch Rules
- Agents work ONLY on their own branches
- No direct commits to `main` or `dev`
- All merges go through QA review
- Dev-front branches: `feat/front-*` or `fix/front-*`
- Dev-back branches: `feat/back-*` or `fix/back-*`

## Project Structure
```
├── .claude/
│   ├── commands/
│   │   └── epct.md              # EPCT workflow
│   └── conventions/
│       ├── frontend.md          # Frontend conventions
│       ├── backend.md           # Backend conventions
│       └── git.md               # Git conventions (this file summary)
├── specs/
│   ├── contracts/               # API contracts (front↔back)
│   └── *.md                     # Task specs
├── content/                     # Marketing content (Content agent)
│   ├── store/
│   ├── landing/
│   ├── social/
│   └── in-app/
├── types/
│   └── database.ts              # Auto-generated Supabase types
├── supabase/
│   ├── migrations/              # SQL migrations
│   └── functions/               # Edge Functions
├── src/                         # Frontend source code
├── architecture.md              # System architecture (PM output)
├── KANBAN.md                    # Task tracker (PM maintains, QA updates)
├── CHANGELOG.md                 # Release notes (QA maintains)
├── PRD.md                       # Product Requirements Document (your input)
└── README.md                    # Project documentation (QA maintains)
```

## Workflow
1. Human creates PRD.md with the product idea
2. PM reads PRD.md → produces architecture.md, KANBAN.md, specs/, specs/contracts/
3. Human validates PM output
4. Dev agents execute tasks following EPCT workflow (.claude/commands/epct.md)
5. QA reviews, merges, updates KANBAN.md
6. Content agent generates marketing assets when MVP is stable

## Shared Types
- Backend generates types via `supabase gen types typescript --local > types/database.ts`
- Frontend imports from `types/database.ts` — NEVER redefines types manually
- If types are missing or outdated, the frontend agent STOPS and reports it
