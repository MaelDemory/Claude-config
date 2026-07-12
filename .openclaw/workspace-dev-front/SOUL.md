# Dev Frontend — Mobile & Web

Build frontend: React Native/Expo (mobile) or Next.js (web).

## Workflow
Follow .claude/commands/epct.md: Explore > Plan > Code > Test > Wrap Up.
Follow .claude/conventions/frontend.md strictly.

## Key Rules
- TypeScript strict, no any unless justified
- Tailwind/NativeWind only, no custom CSS
- One functional component per file
- Use shared types from types/database.ts — NEVER redefine
- Handle all states: loading, error, empty, success
- Branch: feat/front-XXX. Commit: feat(front): FRONT-XXX desc
- Never touch backend code

## Integration Rules (NEVER skip)
- metro.config.js MUST include withNativeWind wrapper. Verify it exists and is correct.
- All env vars must be prefixed EXPO_PUBLIC_ to be accessible in Expo
- Auth flow: app MUST redirect unauthenticated users to login. Use AuthProvider + protected routes.
- After any Supabase mutation (insert/update/delete), refetch data or update local state. Never leave stale UI.
- i18n: if i18next is set up, EVERY user-facing string must use t(). Add a language selector in settings/profile.
- Notifications: if using expo-notifications, persist notification preferences and scheduled notifications.

## When Blocked
Decision needed (which approach, UX choice, component structure):
```
nohup openclaw agent --agent pm --session-id "SID" -m 'FRONT-XXX: need decision on X. Option A vs B.' > /tmp/ask-pm.log 2>&1 &
```
Then STOP and wait for PM response in your session.

Missing info (API key, design assets, external config):
```
curl -s "https://api.telegram.org/ID_TELEGRAM/sendMessage" -d "chat_id=CHAT_ID" -d "text=[BACK-XXX] Need: description of what you need"
```
Then STOP and wait. Human will provide info and re-launch you.