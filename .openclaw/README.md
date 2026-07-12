# OpenClaw Project Template

A ready-to-use template for running autonomous AI agent teams with [OpenClaw](https://openclaw.dev). Agents collaborate to build full-stack apps from a simple product description (PRD).

## How It Works

1. You write a product idea in `PRD.md`
2. The **PM agent** turns it into architecture, tasks, and specs
3. The **orchestrator** dispatches tasks to dev agents based on the KANBAN board
4. **Dev agents** build features on isolated branches
5. The **QA agent** reviews, requests fixes or merges to `dev`
6. The **Content agent** generates marketing assets once the MVP is done

The orchestrator runs in a loop: it reads `KANBAN.md`, assigns work to free agents, handles QA rejections (auto re-dispatch with feedback), and notifies you via Telegram.

## Agent Team

| Agent | Role | Workspace |
|-------|------|-----------|
| **PM** | Plans architecture, writes specs, makes decisions | `workspace-pm/` |
| **Dev Frontend** | Builds mobile (Expo) or web (Next.js) UI | `workspace-dev-front/` |
| **Dev Backend** | Builds Supabase backend (DB, RLS, Edge Functions) | `workspace-dev-back/` |
| **QA** | Reviews branches, enforces quality, merges to dev | `workspace-qa/` |
| **Content** | Generates store listings, landing copy, social kit | `workspace-content/` |

Each agent has a `SOUL.md` file defining its personality, rules, and workflow.

## Project Structure

```
.
├── CLAUDE.md                        # Global rules for all agents
├── PRD.md                           # Your product idea (fill this in)
├── KANBAN.md                        # Task board (PM creates, QA updates)
├── CHANGELOG.md                     # Release notes (QA maintains)
│
├── .claude/
│   ├── commands/                    # Slash commands (EPCT workflow, PR review, etc.)
│   └── conventions/                 # Code conventions (frontend, backend, git)
│
├── openclaw-settings/
│   ├── openclaw.json                # OpenClaw config (agents, models, channels, gateway)
│   ├── vps-root/
│   │   └── orchestrator.py          # Task orchestrator (runs on your VPS)
│   └── workspace-*/
│       └── SOUL.md                  # Agent personality and rules
│
├── specs/                           # Task specs (PM generates)
│   └── contracts/                   # API contracts between front and back
├── types/
│   └── database.ts                  # Auto-generated Supabase types
├── supabase/
│   ├── migrations/                  # SQL migrations
│   └── functions/                   # Edge Functions
└── src/                             # Frontend source code
```

## Setup

### 1. Configure OpenClaw

Copy `openclaw-settings/` to your OpenClaw installation and update `openclaw.json`:

- Replace all `"TOKEN"` placeholders with your actual keys:
  - API provider keys (Anthropic, OpenRouter, NVIDIA NIM, etc.)
  - Telegram bot tokens and allowed user IDs
  - Gateway auth token
- Adjust model choices in `agents.defaults.model` to your preference
- Update workspace paths if needed

### 2. Configure the Orchestrator

Edit `openclaw-settings/vps-root/orchestrator.py`:

- Set `TELEGRAM_ID` and `TELEGRAM_TOKEN` for notifications
- Adjust `POLL`, `MAX_QA`, `MAX_RETRY`, `TIMEOUT` as needed

### 3. Write Your PRD

Fill in `PRD.md` with your product idea, then launch the PM agent to generate the architecture and task breakdown.

### 4. Run the Pipeline

```bash
python3 orchestrator.py /path/to/your/repo
```

The orchestrator will:
- Parse `KANBAN.md` for tasks
- Dispatch TODO tasks to the right agents
- Send IN REVIEW tasks to QA
- Re-dispatch rejected tasks with QA feedback
- Notify you on Telegram at each milestone
- Block and notify when human action is needed (use `~/.openclaw/unblock.txt` to resume)

## Tech Stack (Default)

| Layer | Stack |
|-------|-------|
| Mobile | React Native + Expo, expo-router, NativeWind |
| Web | Next.js (App Router), Tailwind, shadcn/ui |
| State | Zustand |
| Forms | react-hook-form + zod |
| Backend | Supabase (Auth, DB, Edge Functions, Storage) |
| Deployment | EAS (mobile), Vercel (web) |

## Git Workflow

- `main` — production (protected)
- `dev` — integration branch
- `feat/front-XXX` / `feat/back-XXX` — feature branches
- `fix/front-XXX` / `fix/back-XXX` — bugfix branches

Agents work on their own branches. QA merges to `dev` after review. No direct commits to `main` or `dev` by dev agents.

## License

MIT
