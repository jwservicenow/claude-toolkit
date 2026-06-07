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
- Existing plan files (`*-plan-*.md`)
- Any other files that seem relevant to the topic the user described

Do not look for git history or commits.

State what you found in one sentence before moving on. If nothing is relevant, say so and continue.

### Step 2 — Ask Clarifying Questions

Ask up to **4 questions**, one at a time. Stop as soon as you have enough to propose approaches — don't use all 4 for the sake of it.

- Prefer multiple-choice questions over open-ended ones
- Focus on: purpose, constraints, success criteria, scope
- One question per message — wait for the answer before asking the next

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
What we're trying to achieve and why.

## Approach
The chosen approach and the reasoning behind it.

## Steps
Ordered list of concrete steps to execute the plan.

## Testing
How to verify it worked.

## Backout
How to undo or recover if something goes wrong.

## Risks
What could go wrong, how likely, and how bad.

## Open Assumptions
Things assumed to be true that have not been verified.

---

### Step 5 — Self-Review (do this before showing the user anything)

Review the draft silently:

1. **TBD scan** — Any incomplete sections, vague steps, or placeholders? Fill or flag them.
2. **Contradiction check** — Do any sections conflict with each other?
3. **Assumption verification** — Which assumptions can you confirm from the context you read in Step 1? Mark those confirmed in the plan. Move anything unverified to Open Assumptions.
4. **Remaining assumptions** — Anything you assumed while writing that the user never confirmed? Add to Open Assumptions.
5. **Scope check** — Is this focused enough to execute, or does it need to be broken down?

Fix issues inline. Then show the user the finished plan.

### Step 6 — Save the File

Save the plan to the working directory as:

```
<topic>-plan-YYYY-MM-DD.md
```

`<topic>` is a short kebab-case label (e.g. `auth-refactor-plan-2026-06-07.md`). Use today's date.

### Step 7 — Generate the Transition Prompt

Write a companion file alongside the plan:

```
<topic>-prompt-YYYY-MM-DD.md
```

The transition prompt should contain:
- One sentence on the goal and chosen approach
- The first concrete step to take
- An instruction to read the full plan file before doing anything: "Full plan is in `<topic>-plan-YYYY-MM-DD.md` — read it before starting."

Then echo the full contents of the prompt file to the screen so the user can copy-paste it immediately if starting now.

Tell the user both filenames. That's the end — no handoff, no next steps.

## Rules

- User-invoked only. Never activate automatically.
- One question at a time. Wait for each answer.
- Max 4 clarifying questions. Stop earlier if you have what you need.
- Always propose 3–4 approaches. Not fewer.
- Always self-review before showing the plan.
- This skill produces plans, not code. Never write or scaffold implementation.
- Stop at the saved doc. No handoff to other skills.
