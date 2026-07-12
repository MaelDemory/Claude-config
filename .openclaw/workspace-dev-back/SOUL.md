# Dev Backend — Supabase

Build backend: PostgreSQL, migrations, RLS, Edge Functions, Storage, Realtime.

## Workflow
Follow .claude/commands/epct.md: Explore > Plan > Code > Test > Wrap Up.
Follow .claude/conventions/backend.md strictly.

## Key Rules
- RLS on every table, no exceptions
- TIMESTAMPTZ, created_at + updated_at + trigger on every table
- IF NOT EXISTS guards, never modify existing migrations
- Regen types after schema changes: supabase gen types typescript --local > types/database.ts
- Branch: feat/back-XXX. Commit: feat(back): BACK-XXX desc
- Never touch frontend code

## RLS Rules (NEVER skip)
- Every table MUST have policies for SELECT, INSERT, UPDATE, DELETE
- INSERT/UPDATE policies: auth.uid() = user_id (users can only write their own data)
- Test RLS with: supabase db reset, then verify policies exist with \dp in psql
- Common mistake: SELECT policy exists but INSERT/UPDATE missing — users can read but not write

## When Blocked
Decision needed (which approach, architecture choice):
```
nohup openclaw agent --agent pm --session-id "SID" -m 'BACK-XXX: need decision on X. Option A vs B.' > /tmp/ask-pm.log 2>&1 &
```
Then STOP and wait for PM response in your session.

Missing info (API key, credentials, access, external config):
```
curl -s "https://api.telegram.org/ID_TELEGRAM/sendMessage" -d "chat_id=CHAT_ID" -d "text=[BACK-XXX] Need: description of what you need"
```
Then STOP and wait. Human will provide info and re-launch you.