---
name: newplan
description: Use when the user types /newplan to create a structured plan for a feature, project, or task. Explores context, asks up to 4 clarifying questions, proposes 3-4 approaches, self-reviews, then writes a complete plan doc to the working directory. Strictly user-invoked — never auto-triggers.
---

# /newplan — Planning Skill

Turn an idea into an approved, written plan through structured dialogue. The deliverable is a markdown plan file saved flat in the working directory.

**Strictly user-invoked.** Only activate when the user types `/newplan`. Never auto-trigger.

## Process (follow in order)

### Step 1 — Explore Project Context

Before asking anything, read what's available in the working directory:
- README, CLAUDE.md, or any existing docs
- Existing plan files (`*-plan-*.md`) — note any **live** one (first line carries no `DONE` or `SUPERSEDED` banner)
- Any other files that seem relevant to the topic the user described

Do not look for git history or commits.

State what you found in one sentence before moving on. If nothing is relevant, say so and continue.

### Step 2 — Ask Clarifying Questions

Ask up to **4 questions**. Stop as soon as you have enough to propose approaches — don't use all 4 for the sake of it.

- **Ask the goal question first, on its own** — the goal shapes every other question. Pin down a single, clearly stated goal and get the user to explicitly agree to it before proposing approaches. This goal is the spine of the plan — everything else hangs off it, and it gets verified at the end.
- Then ask the remaining questions (up to 3) **together in one batch**, and wait for all the answers.
- Prefer multiple-choice questions over open-ended ones
- Focus on: constraints, success criteria, scope
- **If Step 1 found a live plan**, one of the questions asks whether this new plan replaces it (name the file). That answer decides whether this is a **replan** — never infer it from matching topic labels.

### Step 3 — Propose 3–4 Approaches

Present 3–4 distinct approaches. For each:
- A short name
- What it involves (2–3 sentences)
- Key trade-offs
- Fit for this specific context

End with your recommendation and the reason. Ask the user to pick one before continuing.

### Step 4 — Write the Plan

Once the user picks an approach, write the complete plan at once using this structure:

---

# [Topic] Plan

## Goal
The single agreed goal from Step 2 — what we're trying to achieve and why. Stated once here, tracked through the steps, verified at the end.

## Approach
The chosen approach and the reasoning behind it.

## Steps
Ordered list of concrete steps to execute the plan. The **final step is always closure**, which runs only when the user asks for it — point it at the `## Closure` section below.

## Record
Findings, defects, traps, decisions and tools — one line each. It replaces **running logs** — any file that keeps growing, such as a findings log, defect list or runbook. **Finished reports** (written once, read as a whole) stay as their own files, and a Record row cites each by path. Every row carries a **type** and a **state**:

```
F  SETTLED     one-line finding, cites its source                                      (YYYY-MM-DD)
D  OPEN        one-line defect, cites its source                                       (YYYY-MM-DD)
T  SETTLED     one-line operational trap                                               (YYYY-MM-DD)
K              one-line decision — no state unless overturned                          (YYYY-MM-DD)
T  SUPERSEDED  → K "opening words of the replacing row"                                (YYYY-MM-DD)
Tools:  name.sh (one-line purpose)
```

Types: `F` finding, `D` defect, `T` trap, `K` decision. States: `OPEN`, `SETTLED`, `SUPERSEDED`.
A `K` row carries no state unless overturned — then it becomes `K  SUPERSEDED → …` like any other.
The block above shows one of each type, plus a superseded row, as a format example, not a quota —
include only rows the work actually earned, and leave a type out entirely when there's nothing to
record for it. A new plan usually starts with just the decisions that produced it. **On a replan**
(Step 2), carry every row of the replaced plan's `## Record` forward unchanged — except any row the
replan itself overturns, which gets the `SUPERSEDED →` mark below — then add the decisions that
produced the replan.

A row's date is the day its content last changed — set it on a new row, update it on every edit.

**The rule, in full:** when something changes, **edit the row in place.** If a conclusion is
overturned, mark the old row `SUPERSEDED → <type> "<opening words of the replacing row>"` and keep it. **Never add a
second row on the same subject.** This is the whole anti-amnesia mechanism — one editable row per
subject removes the append order a fresh, confident, wrong answer would otherwise win on.

**Record before you report.** A row is written when it lands, before it's described in chat —
never batched to session end.

## Risks & assumptions
What could go wrong (likelihood, severity, handling) and what's believed true but unverified.

## Verification
How to verify it worked, plus the single check that confirms the agreed goal (top of this plan)
was actually achieved — not just that the steps ran. State the concrete, observable condition
that proves it's done, and who confirms it.

## Backout
How to undo or recover if something goes wrong.

## Closure
The last task of every plan, always present. **A plan never closes itself** — closure runs only when the user asks for it in words. A finished step list does not authorise it, and neither does a session ending. A plan may close with criteria unmet; a banner that hides it may not.

When the user asks:
Closing is one confirmation: show the unmet list, then do the steps below. Unmet items go on the unmet line as they stand — never resolve, fix or research them first unless the user picks one.
1. Prepend **`STATUS YYYY-MM-DD — DONE.`** (today's date) to the plan as a new first line — the existing title moves down one line — with one line under it naming anything unmet. Prepend the same `STATUS` line to the newest `<topic>-prompt-*.md` — banner only; the unmet line goes in the plan only. Older prompts in the chain keep their `SUPERSEDED` banners. The DONE/SUPERSEDED vocabulary is defined in `prompt-sweep/prmpt-lifecycle.md` in the skills folder.
2. Move this plan and **every** `<topic>-prompt-*.md` for this topic into the project's `archive/` folder — the `archive/` directly under the project dir where they live; create it if it doesn't exist. Name them per that spec's archive-naming rule. The user's request to close is the approval for these moves.
3. Deal with `run/` (see *Working artifacts* in the skill): promote anything durable to the project root, and commit it if the project uses version control; keeping or deleting the rest is the user's call — ask, don't assume.

Until the user asks and these are done, this section stands as the open marker that the plan isn't closed yet.

The prompt lifecycle (states, banners, when prompts get archived) is specified once in `prompt-sweep/prmpt-lifecycle.md` in the skills folder — follow it; do not restate its rules here.

---

### Step 5 — Self-Review (do this before showing the user anything)

Review the draft silently:

1. **TBD scan** — Any incomplete sections, vague steps, or placeholders? Fill or flag them.
2. **Contradiction check** — Do any sections conflict with each other?
3. **Assumption verification** — Which assumptions can you confirm from the context you read in Step 1? Mark those confirmed in the plan. Move anything unverified to `## Risks & assumptions`.
4. **Remaining assumptions** — Anything you assumed while writing that the user never confirmed? Add to `## Risks & assumptions`.
5. **Scope check** — Is this focused enough to execute, or does it need to be broken down?
6. **Goal trace** — Does `## Verification` actually test the agreed goal from Step 2, and do the Steps lead to it? If the goal drifted while writing, fix it so top and bottom match.
7. **Record check** — Does `## Record` exist with the type/state row format and the edit-in-place rule, and no reference to `record-controls.md` or separate findings/defects/runbook logs?

Fix issues inline. Do not paste the plan into chat — Step 7 shows a short summary instead.

### Step 6 — Save the File

Save the plan to the working directory as:

```
<topic>-plan-YYYY-MM-DD.md
```

`<topic>` is a short kebab-case label (e.g. `auth-refactor-plan-2026-06-07.md`). Use today's date. If that filename already exists, append the next unused letter (`…-2026-06-07b.md`, then `c`) — never overwrite a plan.

Picking an approach in Step 3 is the user's approval to write the plan and prompt — save without asking again.

**On a replan** (Step 2), after saving the new plan, prepend `STATUS YYYY-MM-DD — SUPERSEDED by <new-plan-filename>.` (today's date) to the replaced plan as a new first line — the existing title moves down one line — and move it into the `archive/` directly under the project dir; create it if it doesn't exist. Name it per the archive-naming rule in `prompt-sweep/prmpt-lifecycle.md` in the skills folder.

### Step 7 — Generate the Transition Prompt

Write a companion file alongside the plan:

```
<topic>-prompt-YYYY-MM-DD.md
```

The transition prompt should contain:
- One sentence on the goal and chosen approach
- The first concrete step to take
- An instruction to read the full plan file before doing anything: "Full plan is in `<topic>-plan-YYYY-MM-DD.md` — read it before starting."

Same-day name clash → next unused letter, as in Step 6. If this is a **replan** (Step 2), or a prior `<topic>-prompt-*.md` already exists for this topic, **demote the prior prompt to SUPERSEDED** (on a replan, the replaced plan's newest prompt) before writing the new one: prepend `STATUS YYYY-MM-DD — SUPERSEDED by <new-prompt-filename>.` (today's date) as its first line. Do not delete it — `/prompt-sweep` archives superseded prompts later, with the user's approval. **Never demote a `keep-loose` REUSABLE prompt** (first line `LIFECYCLE: REUSABLE — keep-loose.`) — skip it entirely when choosing the prior prompt.

Tell the user both filenames and give a short summary of the plan — the goal, the approach, and the step headings — then echo the transition prompt.

**The transition prompt MUST be the last thing you output — always, every run.** Present it under a clear heading (e.g. `## Session prompt — paste to resume`) inside a single fenced code block, so it's clean to copy. Nothing may come after it except the one path line below: no summary of the plan, no recap of what you built, no "want me to start?", no offer to begin the work. If you have closing remarks, they go BEFORE the prompt block.

**Immediately after the fenced block, output exactly one line — the full path to the prompt file:**

```
Session prompt written: <full path to the *-prompt-*.md file>
```

Absolute path, no code block, no commentary after it. That line ends the turn.

### Step 8 — Finish

The deliverables are the two files from Steps 6–7: the plan (`*-plan-*.md`) and the standalone transition prompt (`*-prompt-*.md`). **Do not create a README** — keep the project lean; the plan doc is the self-contained resume point and the prompt file is the paste-to-resume pointer. Leave any existing README untouched.

That's the end — the echoed transition prompt followed by the `Session prompt written: <path>` line is the final output. No handoff, no next steps, nothing after that path line.

## Working artifacts — files created while executing the plan

Executing a plan generates byproducts the plan itself never named: censuses, reports, verification checklists, diffs, scratch notes. Two rules cover all of them.

**Naming** — `<topic>-<kind>-YYYY-MM-DD.md`, same shape as the plan and prompt. `<kind>` says what it is (`census`, `report`, `goal-verification`). Add a letter suffix for same-day revisions (`…-2026-06-07b.md`).

**Where it goes** — decided by lifespan, not by kind:

| | Durable | Ephemeral |
|---|---|---|
| Test | someone reads it in three months with none of this session's context | only meaningful while the plan is running |
| Lives | project root | `<project>/run/`, ignored wholesale |

Create `run/` on first need, beside `archive/`. In a version-controlled project it gets **one** ignore rule, once — never a new pattern per kind of file, which is how the ignore list rots.

The plan and the prompt are the exception: they stay flat at the project root even though they are session artifacts, because they are the resume pointer and have to be obvious to the next session. Everything else earns its place at the root by passing the durability test.

Write the plan so the executing session inherits this — the Closure section already points at it.

## Rules

- User-invoked only. Never activate automatically.
- Goal question first, on its own; remaining questions in one batch.
- Max 4 clarifying questions. Stop earlier if you have what you need.
- Always propose 3–4 approaches. Not fewer.
- Always self-review before saving the plan.
- This skill produces plans, not code. Never write or scaffold implementation.
- Stop at the saved doc. No handoff to other skills.
