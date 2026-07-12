#!/usr/bin/env python3
"""
OpenClaw Orchestrator v4.8
- HUMAN_REQUIRED: QA flags tasks needing human action, blocks task + dependents
- Unblock via ~/.openclaw/unblock.txt
- Agents with tasks in QA review don't receive new tasks
- Branch hygiene instructions in agent messages
- Agents with pending fixes cannot receive new tasks
- QA never dispatched on tasks being actively fixed
- Moves merged tasks to DONE + deletes merged branches
- Detects IN REVIEW from section headers AND inline markers
- Parallel execution, retry limits, fast-fail, session cleanup
- QA rejection → automatic re-dispatch to dev with feedback

Run: python3 ~/orchestrator.py /path/to/repo [session-id]
"""

import subprocess, time, re, sys, os, urllib.request, urllib.parse, json
from datetime import datetime

# ─── CONFIG ───────────────────────────────────────────────────────────────────

POLL = 60
MAX_QA = 3
MAX_RETRY = 3
TIMEOUT = 3600
FAST_FAIL_THRESHOLD = 120
TELEGRAM_ID = ""
TELEGRAM_TOKEN = ""

QA_REJECT_KEYWORDS = [
    "CHANGES_REQUESTED",
    "REJECTED",
    "NOT APPROVED",
    "NEEDS_WORK",
    "please address",
    "please fix",
    "blockers",
]

BRANCH_HYGIENE = (
    "CRITICAL RULES: "
    "1) Create branch from origin/dev: git checkout -b {branch} origin/dev. "
    "2) NEVER merge dev into your branch. "
    "3) ONLY commit files related to {task_id}. "
    "4) Before pushing, run: git diff origin/dev --name-only — and verify EVERY file belongs to your task. "
    "5) If unrelated files appear, restore them: git checkout origin/dev -- <file>."
)

UNBLOCK_FILE = os.path.expanduser("~/.openclaw/unblock.txt")

# ─── ARGS ─────────────────────────────────────────────────────────────────────

repo = sys.argv[1] if len(sys.argv) > 1 else None
sid = sys.argv[2] if len(sys.argv) > 2 else None
if not repo:
    print("Usage: python3 orchestrator.py /path/to/repo [session-id]")
    sys.exit(1)

repo = os.path.expanduser(repo)
project = os.path.basename(repo).lower().replace(" ", "-")
sid = sid or f"project-{project}"

# ─── STATE ────────────────────────────────────────────────────────────────────

qa_cycles = {}
retry_counts = {}
fix_rounds = {}
active_agents = {}
notified = set()
last_status = ""
content_launched = False
pending_fixes = {}
actively_fixing = set()
blocked_human = {}  # task_id -> {reason, blocked_at}
STATE_FILE = os.path.expanduser(f"~/.openclaw/orchestrator-{project}-state.json")

def save_state():
    try:
        state = {
            "qa_cycles": qa_cycles,
            "retry_counts": retry_counts,
            "fix_rounds": fix_rounds,
            "pending_fixes": pending_fixes,
            "blocked_human": blocked_human,
        }
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except Exception:
        pass

def load_state():
    global qa_cycles, retry_counts, fix_rounds, pending_fixes, blocked_human
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE) as f:
                state = json.load(f)
            qa_cycles = state.get("qa_cycles", {})
            retry_counts = state.get("retry_counts", {})
            fix_rounds = state.get("fix_rounds", {})
            pending_fixes = state.get("pending_fixes", {})
            blocked_human = state.get("blocked_human", {})
            log(f"Loaded state: {len(qa_cycles)} QA, {len(retry_counts)} retries, {len(fix_rounds)} fix rounds, {len(pending_fixes)} pending fixes, {len(blocked_human)} human-blocked")
    except Exception:
        pass

# ─── LOGGING & TELEGRAM ──────────────────────────────────────────────────────

def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}", flush=True)

def notify(msg):
    if msg in notified:
        return
    notified.add(msg)
    log(f"TG: {msg}")
    try:
        data = urllib.parse.urlencode({"chat_id": TELEGRAM_ID, "text": msg}).encode()
        urllib.request.urlopen(
            f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage",
            data, timeout=10
        )
    except Exception as e:
        log(f"TG failed: {e}")

# ─── HUMAN BLOCKING ──────────────────────────────────────────────────────────

def block_task_human(task_id, reason):
    """Block a task and notify human."""
    blocked_human[task_id] = {
        "reason": reason,
        "blocked_at": datetime.now().isoformat(),
    }
    save_state()
    # Extract a short summary from the reason (first 200 chars)
    short_reason = reason[:200].replace("\n", " ")
    notify(f"🔴 {task_id} BLOQUE — action humaine requise:\n{short_reason}\n\nPour debloquer: echo '{task_id}' >> ~/.openclaw/unblock.txt")

def check_unblock():
    """Read unblock.txt and unblock listed tasks."""
    if not os.path.exists(UNBLOCK_FILE):
        return
    try:
        with open(UNBLOCK_FILE) as f:
            lines = f.readlines()
        if not lines:
            return
        unblocked = []
        for line in lines:
            tid = line.strip().upper()
            if tid and tid in blocked_human:
                del blocked_human[tid]
                unblocked.append(tid)
                log(f"UNBLOCKED: {tid}")
        # Clear the file
        with open(UNBLOCK_FILE, "w") as f:
            f.write("")
        if unblocked:
            save_state()
            notify(f"🟢 Debloque: {', '.join(unblocked)}. Pipeline reprend.")
    except Exception as e:
        log(f"Unblock check failed: {e}")

def is_blocked_by_human(task_id, tasks):
    """Check if a task is blocked directly or via a blocked dependency."""
    if task_id in blocked_human:
        return True
    # Check if any dependency is human-blocked (cascade)
    task = tasks.get(task_id)
    if not task:
        return False
    for dep in task.get("deps", []):
        dep = dep.strip()
        if dep and dep in blocked_human:
            return True
        # Recursive: check if dep's deps are blocked
        if dep and dep in tasks:
            for dep2 in tasks[dep].get("deps", []):
                dep2 = dep2.strip()
                if dep2 and dep2 in blocked_human:
                    return True
    return False

# ─── AGENT ────────────────────────────────────────────────────────────────────

def clean_locks():
    lock_dir = os.path.expanduser("~/.openclaw/agents")
    if not os.path.exists(lock_dir):
        return
    for root, dirs, files in os.walk(lock_dir):
        for f in files:
            if f.endswith(".lock"):
                lock_path = os.path.join(root, f)
                try:
                    os.remove(lock_path)
                except Exception:
                    pass

def clean_agent_sessions(agent):
    sessions_dir = os.path.expanduser(f"~/.openclaw/agents/{agent}/sessions")
    if not os.path.exists(sessions_dir):
        return
    count = 0
    for f in os.listdir(sessions_dir):
        fpath = os.path.join(sessions_dir, f)
        if f.endswith(".jsonl") or f == "sessions.json":
            try:
                os.remove(fpath)
                count += 1
            except Exception:
                pass
    if count:
        log(f"Cleaned {count} old session files for {agent}")

def run_agent(agent, task, msg, role="task"):
    clean_locks()
    clean_agent_sessions(agent)
    session_id = f"{sid}-{agent}-{task}-{int(time.time())}"
    log_file = f"/tmp/{agent}-{task}.log"
    log(f"LAUNCH {agent} -> {task} (session: {session_id}, role: {role})")
    proc = subprocess.Popen(
        f"openclaw agent --agent {agent} --session-id {session_id} "
        f"--timeout {TIMEOUT} -m '{msg}' > {log_file} 2>&1",
        shell=True, cwd=repo
    )
    active_agents[agent] = {
        "task": task,
        "pid": proc.pid,
        "started": time.time(),
        "process": proc,
        "role": role,
    }

def read_agent_log(agent, task):
    log_file = f"/tmp/{agent}-{task}.log"
    try:
        if os.path.exists(log_file):
            with open(log_file) as f:
                lines = f.readlines()
            return "".join(lines[-50:])
    except Exception:
        pass
    return ""

def detect_qa_rejection(log_content):
    if not log_content:
        return None
    for keyword in QA_REJECT_KEYWORDS:
        if keyword.lower() in log_content.lower():
            lines = log_content.strip().split("\n")
            feedback_lines = lines[-20:] if len(lines) > 20 else lines
            return "\n".join(feedback_lines)
    return None

def detect_qa_approval(log_content):
    if not log_content:
        return False
    approval_keywords = ["APPROVED", "LGTM", "merged to dev", "Merge to dev"]
    for keyword in approval_keywords:
        if keyword.lower() in log_content.lower():
            return True
    return False

def detect_human_required(log_content):
    """Check if QA flagged a task as needing human intervention."""
    if not log_content:
        return None
    markers = ["HUMAN_REQUIRED", "HUMAN REQUIRED", "NEEDS_HUMAN", "BLOCKED_HUMAN"]
    for marker in markers:
        if marker.lower() in log_content.lower():
            # Extract the reason (lines around the marker)
            lines = log_content.strip().split("\n")
            reason_lines = []
            found = False
            for line in lines:
                if any(m.lower() in line.lower() for m in markers):
                    found = True
                if found:
                    reason_lines.append(line)
                if len(reason_lines) >= 10:
                    break
            return "\n".join(reason_lines) if reason_lines else "Human action required (no details)"
    return None

def check_active_agents():
    finished = []
    for agent, info in list(active_agents.items()):
        proc = info["process"]
        elapsed = time.time() - info["started"]

        if proc.poll() is not None:
            duration = int(elapsed)
            task = info["task"]
            role = info["role"]
            log(f"FINISHED: {agent} -> {task} ({duration}s, role: {role})")

            if elapsed < FAST_FAIL_THRESHOLD:
                log(f"WARNING: {agent} -> {task} finished too fast ({duration}s), likely failed")
                retry_counts[task] = retry_counts.get(task, 0) + 1
                save_state()
                if retry_counts[task] >= MAX_RETRY:
                    notify(f"⚠️ {task} echoue {MAX_RETRY}x ({agent}). Log: /tmp/{agent}-{task}.log")
            else:
                if role == "qa":
                    handle_qa_result(agent, task)

            if role == "fix":
                actively_fixing.discard(task)
                if elapsed >= FAST_FAIL_THRESHOLD and task in pending_fixes:
                    del pending_fixes[task]
                    log(f"Fix completed for {task}, removed from pending")
                    save_state()

            finished.append((agent, task, role))
            del active_agents[agent]

        elif elapsed > TIMEOUT + 120:
            log(f"TIMEOUT: {agent} -> {info['task']} ({int(elapsed)}s)")
            try:
                proc.kill()
            except Exception:
                pass
            if info["role"] == "fix":
                actively_fixing.discard(info["task"])
            finished.append((agent, info["task"], info["role"]))
            del active_agents[agent]

    return finished

def handle_qa_result(agent, task):
    log_content = read_agent_log(agent, task)

    # Check HUMAN_REQUIRED first (highest priority)
    human_reason = detect_human_required(log_content)
    if human_reason:
        log(f"HUMAN REQUIRED: {task}")
        block_task_human(task, human_reason)
        return

    if detect_qa_approval(log_content):
        log(f"QA APPROVED: {task}")
        notify(f"✅ {task} approuve par QA et merge.")
        pending_fixes.pop(task, None)
        fix_rounds.pop(task, None)
        save_state()
        return

    feedback = detect_qa_rejection(log_content)
    if feedback:
        fix_rounds[task] = fix_rounds.get(task, 0) + 1
        current_round = fix_rounds[task]
        log(f"QA REJECTED: {task} (fix round {current_round})")

        if current_round > MAX_QA:
            notify(f"⚠️ {task} bloque apres {MAX_QA} fix rounds. Intervention humaine requise.")
            save_state()
            return

        dev_agent = get_dev_agent_for_task(task)
        pending_fixes[task] = {
            "feedback": feedback,
            "agent": dev_agent,
        }
        save_state()
        notify(f"🔧 {task} rejete par QA (round {current_round}/{MAX_QA}). Re-dispatch a {dev_agent}.")
    else:
        log(f"QA result unclear for {task}, treating as needs re-review")

def get_dev_agent_for_task(task_id):
    if task_id.startswith("BACK"):
        return "dev-back"
    elif task_id.startswith("CONTENT"):
        return "content"
    elif task_id.startswith("FIX"):
        return "dev-front"
    else:
        return "dev-front"

def is_agent_busy(agent):
    return agent in active_agents

def is_task_being_fixed(task_id):
    return task_id in pending_fixes or task_id in actively_fixing

# ─── GIT ──────────────────────────────────────────────────────────────────────

def git_fetch():
    subprocess.run(["git", "fetch", "--all", "--prune", "--quiet"], cwd=repo, capture_output=True)

def git_task_in_dev(task_id):
    r = subprocess.run(
        ["git", "log", "--oneline", "origin/dev", "--grep", task_id],
        cwd=repo, capture_output=True, text=True
    )
    return task_id.lower() in r.stdout.lower() if r.stdout else False

def read_kanban(branch="dev"):
    r = subprocess.run(
        ["git", "show", f"origin/{branch}:KANBAN.md"],
        cwd=repo, capture_output=True, text=True
    )
    return r.stdout if r.returncode == 0 else ""

def get_feat_branches():
    r = subprocess.run(
        ["git", "branch", "-r", "--list", "origin/feat/*"],
        cwd=repo, capture_output=True, text=True
    )
    return [b.strip().replace("origin/", "") for b in r.stdout.strip().split("\n") if b.strip()]

def cleanup_merged_branches():
    for branch in get_feat_branches():
        m = re.match(r"feat/(back|front|fix|content)-(\d+)", branch)
        if not m:
            continue
        scope, num = m.groups()
        prefix = {"back": "BACK", "front": "FRONT", "fix": "FIX", "content": "CONTENT"}[scope]
        tid = f"{prefix}-{num}"
        if git_task_in_dev(tid):
            r = subprocess.run(
                ["git", "push", "origin", "--delete", branch],
                cwd=repo, capture_output=True, text=True
            )
            if r.returncode == 0:
                log(f"DELETED merged branch: {branch}")

def fix_kanban_on_dev(tids):
    try:
        subprocess.run(["git", "stash", "--quiet"], cwd=repo, capture_output=True)
        subprocess.run(["git", "checkout", "dev", "--quiet"], cwd=repo, capture_output=True)
        subprocess.run(["git", "pull", "origin", "dev", "--quiet"], cwd=repo, capture_output=True)
        path = os.path.join(repo, "KANBAN.md")
        if not os.path.exists(path):
            return
        with open(path) as f:
            lines = f.readlines()

        moved = []
        for tid in tids:
            new_lines = []
            found_line = None
            for line in lines:
                if re.match(rf"\s*- \[[x ]\]\s+{re.escape(tid)}:", line):
                    found_line = line.rstrip()
                else:
                    new_lines.append(line)

            if found_line:
                lines = new_lines
                idm = re.search(r"((?:BACK|FRONT|FIX|CONTENT)-\d+):\s+", found_line)
                if idm:
                    rest = found_line[idm.end():]
                    title = re.split(r"\s*(?:\(P[012]\)|\(@[\w-]+\)|\[P[012]\]|—)", rest)[0].strip()
                    agent = ""
                    am = re.search(r"\(@([\w-]+)\)", found_line)
                    if am:
                        agent = am.group(1)
                    else:
                        am = re.search(r"—\s*@([\w-]+)", found_line)
                        if am:
                            agent = am.group(1)
                    agent_str = f" (@{agent})" if agent else ""
                    done_line = f"- [x] {tid}: {title}{agent_str} — merged\n"
                else:
                    done_line = f"- [x] {found_line.lstrip('- [x] ').lstrip('- [ ] ')} — merged\n"
                moved.append((tid, done_line))

        if not moved:
            return

        final_lines = []
        done_section_found = False
        done_tasks_inserted = False

        for line in lines:
            if line.strip().startswith("## DONE"):
                done_section_found = True
                final_lines.append(line)
                continue
            if done_section_found and not done_tasks_inserted:
                if line.strip().startswith("- [x]") or line.strip() == "":
                    for tid, done_line in moved:
                        final_lines.append(done_line)
                    done_tasks_inserted = True
            final_lines.append(line)

        if done_section_found and not done_tasks_inserted:
            for tid, done_line in moved:
                final_lines.append(done_line)

        with open(path, "w") as f:
            f.writelines(final_lines)

        subprocess.run(["git", "add", "KANBAN.md"], cwd=repo, capture_output=True)
        tids_str = ", ".join(t for t, _ in moved)
        r = subprocess.run(
            ["git", "commit", "-m", f"docs: move {tids_str} to DONE [orchestrator]"],
            cwd=repo, capture_output=True, text=True
        )
        if r.returncode != 0:
            log(f"KANBAN commit failed: {r.stderr}")
            return

        for attempt in range(3):
            r = subprocess.run(
                ["git", "push", "origin", "dev"],
                cwd=repo, capture_output=True, text=True
            )
            if r.returncode == 0:
                log(f"KANBAN synced: moved {tids_str} to DONE")
                return
            else:
                log(f"Push failed (attempt {attempt+1}): {r.stderr.strip()}")
                subprocess.run(["git", "pull", "--rebase", "origin", "dev"], cwd=repo, capture_output=True)

        log(f"KANBAN push failed after 3 attempts")

    except Exception as e:
        log(f"KANBAN sync failed: {e}")
        import traceback
        traceback.print_exc()

# ─── PARSER ───────────────────────────────────────────────────────────────────

def parse_task_line(line):
    t = line.strip()
    if not t.startswith("- ["):
        return None

    cm = re.match(r"- \[([x ])\]\s+", t)
    if not cm:
        return None
    check = cm.group(1)

    idm = re.search(r"((?:BACK|FRONT|FIX|CONTENT)-\d+):\s+", t)
    if not idm:
        return None
    tid = idm.group(1)
    rest = t[idm.end():]

    prio = "P1"
    pm = re.search(r"[\[\(](P[012])[\]\)]", rest)
    if pm:
        prio = pm.group(1)

    agent = ""
    am = re.search(r"\(@([\w-]+)\)", rest)
    if am:
        agent = am.group(1)
    else:
        am = re.search(r"—\s*@([\w-]+)", rest)
        if am:
            agent = am.group(1)

    deps = []
    dm = re.search(r"depends:\s+(.+?)(?:\s*—|$)", rest)
    if dm:
        deps = [d.strip() for d in dm.group(1).split(",") if d.strip() and d.strip() != "none"]

    title = re.split(r"\s*(?:\(P[012]\)|\(@[\w-]+\)|\[P[012]\]|—)", rest)[0].strip()

    has_inline_review = bool(re.search(r"IN REVIEW", t, re.IGNORECASE))

    return {
        "id": tid,
        "title": title,
        "agent": agent,
        "priority": prio,
        "check": check,
        "deps": deps,
        "inline_review": has_inline_review,
    }

def parse_kanban(content):
    if not content:
        return {}
    tasks = {}
    section = None
    headers = {
        "## BACKLOG": "BACKLOG", "## TODO": "TODO",
        "## IN PROGRESS": "IN PROGRESS", "## IN REVIEW": "IN REVIEW",
        "## DONE": "DONE",
    }
    in_review_count = 0

    for line in content.split("\n"):
        t = line.strip()

        matched_header = False
        for marker, s in headers.items():
            if t.startswith(marker):
                if s == "IN REVIEW":
                    in_review_count += 1
                    if in_review_count > 1:
                        section = "_SKIP"
                        matched_header = True
                        break
                section = s
                matched_header = True
                break
        if matched_header:
            continue

        if section == "_SKIP" or section is None:
            continue

        if t.startswith("#") or t.startswith("<!--"):
            continue

        parsed = parse_task_line(line)
        if not parsed:
            continue

        if section == "IN REVIEW":
            parsed["status"] = "IN REVIEW"
        elif parsed.get("inline_review"):
            parsed["status"] = "IN REVIEW"
        elif section == "DONE":
            parsed["status"] = "DONE"
        elif parsed["check"] == "x":
            parsed["status"] = "DONE"
        else:
            parsed["status"] = section

        del parsed["check"]
        del parsed["inline_review"]
        tasks[parsed["id"]] = parsed

    return tasks

# ─── PIPELINE LOGIC ──────────────────────────────────────────────────────────

def sync_merged(tasks):
    to_fix = []
    for t in tasks.values():
        if t["status"] != "DONE" and git_task_in_dev(t["id"]):
            log(f"SYNC: {t['id']} merged but not DONE in KANBAN")
            t["status"] = "DONE"
            to_fix.append(t["id"])
    if to_fix:
        fix_kanban_on_dev(to_fix)
    cleanup_merged_branches()

def deps_ok(task, tasks):
    for d in task["deps"]:
        d = d.strip()
        if d and d != "none" and d in tasks and tasks[d]["status"] != "DONE":
            return False
    return True

def get_agent_for_task(task):
    tid = task["id"]
    if task["agent"]:
        return task["agent"]
    if tid.startswith("BACK"):
        return "dev-back"
    elif tid.startswith("CONTENT"):
        return "content"
    elif tid.startswith("FIX"):
        return "dev-front"
    else:
        return "dev-front"

def get_branch_for_task(tid):
    if tid.startswith("BACK"):
        scope = "back"
    elif tid.startswith("FIX"):
        scope = "fix"
    elif tid.startswith("CONTENT"):
        scope = "content"
    else:
        scope = "front"
    num = tid.split("-")[1]
    return f"feat/{scope}-{num}"

def build_message(task):
    tid = task["id"]
    branch = get_branch_for_task(tid)
    hygiene = BRANCH_HYGIENE.format(branch=branch, task_id=tid)

    if tid.startswith("CONTENT"):
        return (
            f"Repo: {repo}. Task: {tid}. {task['title']}. "
            f"Commit to dev branch. Update KANBAN to IN REVIEW. "
            f"{hygiene}"
        )
    else:
        convention = "backend" if tid.startswith("BACK") else "frontend"
        return (
            f"Repo: {repo}. Task: {tid}. {task['title']}. "
            f"Follow .claude/conventions/{convention}.md. "
            f"Branch: {branch}. Push when done. Update KANBAN to IN REVIEW. "
            f"{hygiene}"
        )

def build_fix_message(task_id, feedback):
    branch = get_branch_for_task(task_id)
    convention = "backend" if task_id.startswith("BACK") else "frontend"
    hygiene = BRANCH_HYGIENE.format(branch=branch, task_id=task_id)

    if len(feedback) > 1000:
        feedback = feedback[-1000:]

    safe_feedback = feedback.replace("'", "'\"'\"'")

    return (
        f"Repo: {repo}. Task: {task_id}. Branch: {branch}. "
        f"QA a rejete cette tache. Corrige les problemes suivants puis push:\n\n"
        f"{safe_feedback}\n\n"
        f"Follow .claude/conventions/{convention}.md. "
        f"Push fixes to {branch} when done. "
        f"IMPORTANT: Only modify files related to {task_id}. Do NOT include changes from other tasks. "
        f"{hygiene}"
    )

def decide_actions(tasks):
    sync_merged(tasks)
    actions = []
    assigned_this_round = set()

    # 0. PENDING FIXES → re-dispatch to dev (highest priority)
    for task_id, fix_info in list(pending_fixes.items()):
        if task_id in actively_fixing:
            continue
        if task_id in blocked_human:
            continue

        agent = fix_info["agent"]

        if is_agent_busy(agent) or agent in assigned_this_round:
            continue

        current_round = fix_rounds.get(task_id, 0)
        if current_round > MAX_QA:
            notify(f"⚠️ {task_id} bloque apres {MAX_QA} fix rounds. Intervention humaine requise.")
            del pending_fixes[task_id]
            save_state()
            continue

        feedback = fix_info["feedback"]
        msg = build_fix_message(task_id, feedback)
        actions.append((agent, task_id, msg, "fix"))
        assigned_this_round.add(agent)
        actively_fixing.add(task_id)
        log(f"DISPATCH FIX: {agent} -> {task_id} (round {current_round}/{MAX_QA})")

    # 1. IN REVIEW → QA (if QA is free)
    if not is_agent_busy("qa") and "qa" not in assigned_this_round:
        for t in tasks.values():
            if t["status"] != "IN REVIEW":
                continue
            if is_task_being_fixed(t["id"]):
                continue
            if t["id"] in blocked_human:
                continue
            c = qa_cycles.get(t["id"], 0)
            if c >= MAX_QA:
                notify(f"⚠️ {t['id']} bloque ({MAX_QA}x QA). Log: /tmp/qa-{t['id']}.log")
                continue
            branch = get_branch_for_task(t["id"])
            actions.append(("qa", t["id"],
                f"Repo: {repo}. Review branch {branch}. "
                f"Follow .claude/commands/pr-review.md. Merge to dev if APPROVED. "
                f"If the task requires human action (API keys, OAuth setup, external access, secrets), "
                f"write HUMAN_REQUIRED in your review with a clear description of what the human needs to do.",
                "qa"))
            qa_cycles[t["id"]] = c + 1
            assigned_this_round.add("qa")
            save_state()
            break

    # 2. TODO → dispatch to free agents
    todo = [t for t in tasks.values()
            if t["status"] == "TODO" and deps_ok(t, tasks)]

    todo.sort(key=lambda t: (
        {"P0": 0, "P1": 1, "P2": 2}.get(t["priority"], 1),
        0 if t["id"].startswith("BACK") else 1,
        int(re.search(r"\d+", t["id"]).group())
    ))

    for t in todo:
        agent = get_agent_for_task(t)
        tid = t["id"]

        if is_agent_busy(agent) or agent in assigned_this_round:
            continue

        # Skip human-blocked tasks and their dependents
        if is_blocked_by_human(tid, tasks):
            continue

        # Block new tasks if this agent has pending fixes
        has_pending = any(f["agent"] == agent for f in pending_fixes.values())
        has_active_fix = any(
            info["role"] == "fix" and a == agent
            for a, info in active_agents.items()
        )
        # Block new tasks if agent has tasks in QA review
        agent_in_review = any(
            get_dev_agent_for_task(t2["id"]) == agent
            for t2 in tasks.values()
            if t2["status"] == "IN REVIEW"
        )
        if has_pending or has_active_fix or agent_in_review:
            log(f"SKIP {tid}: {agent} has pending fix or task in review")
            continue

        if retry_counts.get(tid, 0) >= MAX_RETRY:
            notify(f"⚠️ {tid} echoue {MAX_RETRY}x ({agent}). Passe. Log: /tmp/{agent}-{tid}.log")
            continue

        msg = build_message(t)
        actions.append((agent, tid, msg, "task"))
        assigned_this_round.add(agent)
        notify(f"🚀 {tid} demarre ({agent})")

    # 3. Check if all done
    if not actions and not active_agents and not pending_fixes and not actively_fixing:
        non_blocked = [t for t in tasks.values()
                       if t["status"] != "DONE"
                       and retry_counts.get(t["id"], 0) < MAX_RETRY
                       and not is_blocked_by_human(t["id"], tasks)]
        if not non_blocked and tasks:
            if blocked_human:
                blocked_list = ", ".join(blocked_human.keys())
                notify(f"⏸️ Toutes les taches libres sont DONE. En attente de deblocage: {blocked_list}")
            else:
                actions.append(("done", None, None, None))

    return actions

def get_tasks():
    tasks = parse_kanban(read_kanban("dev"))

    for branch in get_feat_branches():
        content = read_kanban(branch)
        if not content:
            continue

        ft = parse_kanban(content)
        for tid, t in ft.items():
            if t["status"] == "IN REVIEW" and tid in tasks and tasks[tid]["status"] != "DONE":
                tasks[tid]["status"] = "IN REVIEW"

        for line in content.split("\n"):
            if "IN REVIEW" in line.upper():
                idm = re.search(r"((?:BACK|FRONT|FIX|CONTENT)-\d+)", line)
                if idm:
                    tid = idm.group(1)
                    if tid in tasks and tasks[tid]["status"] != "DONE":
                        if tasks[tid]["status"] != "IN REVIEW":
                            tasks[tid]["status"] = "IN REVIEW"

    return tasks

# ─── MAIN LOOP ────────────────────────────────────────────────────────────────

log(f"Orchestrator v4.8 | {repo} | {sid}")
load_state()
notify(f"🦞 Pipeline {project} demarree (v4.8).")

if blocked_human:
    log(f"Human-blocked tasks: {list(blocked_human.keys())}")

while True:
    try:
        # Check for unblock requests
        check_unblock()

        finished = check_active_agents()
        if finished:
            time.sleep(5)

        git_fetch()
        tasks = get_tasks()

        if not tasks:
            log("No tasks")
            time.sleep(POLL)
            continue

        counts = {}
        for t in tasks.values():
            counts[t["status"]] = counts.get(t["status"], 0) + 1
        sl = " | ".join(f"{k}:{v}" for k, v in sorted(counts.items()))
        busy = ", ".join(f"{a}→{i['task']}({i['role']})" for a, i in active_agents.items()) or "none"
        extras = []
        if pending_fixes:
            extras.append(f"pending_fix: {list(pending_fixes.keys())}")
        if actively_fixing:
            extras.append(f"fixing: {list(actively_fixing)}")
        if blocked_human:
            extras.append(f"🔴 blocked: {list(blocked_human.keys())}")
        extra_str = f" | {' | '.join(extras)}" if extras else ""
        status_line = f"{sl} | active: {busy}{extra_str}"
        if status_line != last_status:
            log(f"KANBAN: {status_line}")
            last_status = status_line

        actions = decide_actions(tasks)

        for agent, task, msg, role in actions:
            if agent == "done":
                if not content_launched:
                    notify(f"✅ MVP {project} termine! Toutes les tasks DONE.")
                    if not is_agent_busy("content"):
                        run_agent("content", "content-final",
                            f"Repo: {repo}. MVP complete. Generate store listings FR+EN, "
                            f"landing copy, social kit. Commit to dev.",
                            role="task")
                        content_launched = True
                continue
            run_agent(agent, task, msg, role=role)

        time.sleep(POLL)

    except KeyboardInterrupt:
        log("Stopped")
        notify(f"⏸️ Pipeline {project} en pause.")
        save_state()
        break
    except Exception as e:
        log(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        time.sleep(POLL)