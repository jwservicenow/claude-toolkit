---
name: prompt-sweep
description: On-demand monthly backstop that finds retired prompt files (`*-prompt-*.md`) and, with per-file or approve-all consent, archives the SUPERSEDED and DONE ones into each project's own `archive/`. Never touches ACTIVE or REUSABLE prompts, never crosses out of the scope it resolved, never deletes. Strictly user-invoked — never auto-triggers.
---

# /prompt-sweep — Prompt lifecycle backstop

The periodic net under `/newsession` and `/newplan`. The user runs this ~monthly to clear
retired prompt files out of project roots. It **proposes**, the user **approves**, then it
**moves** — nothing else.

**Strictly user-invoked.** Only activate when the user types `/prompt-sweep`. Never auto-trigger.

The lifecycle states, banner formats, division of labor, and scope guardrail are defined
once in the canonical spec: **`prmpt-lifecycle.md`**, in this skill's own folder. Read it
before running. This skill does not restate those rules — it applies them.

## Step 1 — Resolve the scope (hard boundary)

Resolve it from the cwd — never assume a layout, and never hardcode directory names.
The scope is the **nearest** directory — the cwd itself or its closest ancestor — that contains a
`projects/` directory. If none exists, the scope is the cwd. **Operate on that one scope only and
never cross into a sibling scope in a single run.** If the result is ambiguous, stop and ask.

Nearest wins because it is the most specific boundary — a workspace holding several independent
trees, each with its own `projects/`, resolves to the individual tree, which is the separation that
must not be crossed. Full rationale: `prmpt-lifecycle.md` § Scope guardrail.

State the resolved scope in one line before scanning, so the user can correct it before anything
moves.

## Step 2 — Scan for prompt files

Within the resolved scope, find every `*-prompt-*.md`:
- Each `projects/*/` directory, recursively — projects may nest subfolders.
- The scope's own flat root.
- Files directly inside `projects/` itself, outside any project folder — scanned so they can be
  flagged, never moved (Step 4; `prmpt-lifecycle.md` § Scope guardrail).
- Skip anything already inside an `archive/` folder.
- Never ascend above the resolved scope, and never descend into a folder that has its own
  `projects/` directory — that is a scope of its own and gets its own run.

## Step 3 — Classify each file (per the spec)

For each prompt file, assign a state using `prmpt-lifecycle.md` precedence
(**REUSABLE > ACTIVE > DONE > SUPERSEDED**):
- **REUSABLE** — first line is the `LIFECYCLE: REUSABLE — keep-loose.` marker. Never swept.
- **DONE** — first line is a `STATUS … — DONE.` banner. Sweep candidate.
- **SUPERSEDED** — first line is a `STATUS … — SUPERSEDED by …` banner, OR it is an older
  prompt **for the same `<topic>`** as a newer prompt (even if someone forgot to stamp it).
  Sweep candidate. **Compare only within a topic** — a newer prompt for a *different* topic
  never supersedes this one, however old it is. A project may hold several live topics at once,
  and treating the project's newest as the only survivor retires real work.
- **ACTIVE** — no banner AND the live resume pointer of an open topic (defined in `prmpt-lifecycle.md`). Never swept. If its date
  is **more than 60 days old** it is **dormant** — still never swept, but surfaced in Step 4's
  "needs your call" list alongside LEGACY (see `prmpt-lifecycle.md` § Dormant topics).
- **LEGACY** — no banner and no `keep-loose` marker, and **not** confidently ACTIVE per the
  line above (predates the system, retired without stamping, or its plan is DONE/SUPERSEDED
  but the prompt was never stamped). **Do not assume ACTIVE and skip it** — surface it for a decision (Step 4).

Only **DONE** and **SUPERSEDED** are direct sweep candidates. **LEGACY is always asked about.**

## Step 4 — Propose (never move yet)

Show **two** tables.

**A. Sweep candidates** (DONE / SUPERSEDED):

| # | File (path) | State | → Destination archive/ |
|---|---|---|---|

**B. Needs your call** (unbannered and not confidently ACTIVE, or ACTIVE but dormant >60 days, or
loose in `projects/` in any state but REUSABLE — a loose file never goes in Table A):

| # | File (path) | Recommended | Why |
|---|---|---|---|

Recommended is one of: **keep ACTIVE** (leave in place) · **mark REUSABLE** (`keep-loose`) ·
**archive DONE** / **archive SUPERSEDED by <file>** · **move into `projects/<name>/`** (loose files
only — name the folder it belongs in).

**Read each Table B file in full before assigning its Recommended — always. Never infer a
disposition from the filename, the absence of a banner, or the memory index; those are what
produce wrong first-pass calls.** Base it on what the file actually says, checking:
- **Live task or finished one-shot?** The filename can lie — a `…-procedure-…` may be a single
  completed test, not a reusable procedure. Trust the body's goal + next-action over the name.
- **Is it a keep-around reference?** "Verify-don't-reapply" notes, or a file whose *current path*
  other prompts/docs/the runbook point at, should be **REUSABLE in place** — archiving relocates
  it and breaks those links.
- **Is the work truly done?** Confirm against the file's own status/next-action and any open plan
  for the topic — not just a memory summary, which can lag.

(Table A candidates are banner-driven and self-stamped — no full read needed. This mandatory
read is only for Table B, whose ambiguity is exactly what the read resolves.)

A hold/defer note discovered in a different file does not, by itself, pull a SUPERSEDED file
into Table B — quote it from that file's own text before it counts.

Below both, list what is being **left in place** with no question and why (ACTIVE within 60 days
on an open topic; REUSABLE = keep-loose). If both tables are empty, say
"Nothing to sweep — all prompts are ACTIVE or REUSABLE." and stop.

## Step 5 — Get approval, then act

Ask the user to approve — **per-file** (list the numbers) or **all**. For Table B they confirm or
override each recommendation. Then, per file:
- **archive** → stamp the DONE/SUPERSEDED banner as its first line, then move it to `archive/`,
  prefixing the filename per the spec's **Archive naming** rule (immediate parent folder, always, every file, no dedup).
- **mark REUSABLE** → stamp the `LIFECYCLE: REUSABLE — keep-loose.` marker; leave in place.
- **keep ACTIVE** → leave untouched.
- **move into `projects/<name>/`** → leave untouched; the user moves it, and a later run sweeps it
  from its folder.

For every move: ensure the destination `archive/` exists (the project's own, or the scope root's);
create if missing. **Move** (not copy, not delete). If a plan file (`<same-topic>-plan-*.md`) sits
beside a swept prompt and is itself DONE, offer to move it too — same approval.

Never move or stamp a file the user didn't approve. Report what moved/stamped and where, one line each.

## Step 6 — Done

State the resolved scope and the final tally (moved N, left M active/reusable). No handoff, no README, no next steps.

## Rules

- User-invoked only. Never auto-trigger.
- One resolved scope per run — never cross into a sibling scope, never ascend above it.
- ACTIVE and REUSABLE are never candidates.
- Move, never delete. Every move is approval-gated.
- Rules live in `prmpt-lifecycle.md` — link to it, never restate it.
