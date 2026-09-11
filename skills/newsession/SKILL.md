---
name: newsession
description: Token flush for long conversations — when context is filling up or a topic is wrapping up, invoke /newsession. Always silent — writes the handoff file and folds this session's findings/decisions into the plan's Record section, with no visible output. An optional argument is a focus phrase or a runbook path, never a mode switch. Strictly user-invoked — never auto-triggers.
---

# /newsession — Session handoff

Look at what actually happened in this conversation (this session only — not memory, not prior sessions).

**Strictly user-invoked.** Only activate when the user types `/newsession`. Never auto-trigger.

## Step 1 — Resolve the optional argument

There is one mode. If `$ARGUMENTS` is empty, derive `<topic>` by Step 4's ordering (worked-on
plan's label, else the current directory's name) and proceed.

If `$ARGUMENTS` is provided, determine how to treat it — it shapes the handoff, it never switches
mode:
1. If it contains a "/" or ends in a file extension, treat as a file path — read it as a runbook and let its content shape the handoff.
2. If it's a bare filename (no slash, has extension), locate it: `find ~/ClaudeOS -name "<filename>" -type f 2>/dev/null | head -5` — one match → use it; multiple → list and ask; none → ask for full path.
3. If it's a short phrase (no slash, no extension, one or more words), treat as a focus instruction — bias the handoff toward that topic/area without filtering out other important context.

Every path runs Steps 2–4, then ends the turn with the literal text `<!-- no output -->` and
nothing else. It renders as nothing, so the user sees no output, and the harness gets a non-empty
reply so it never asks for one.

## Step 2 — Close-out sweep (always runs, silent)

Runs before the handoff is written — the whole reason a flush is safe. Walk what this session
actually did — measured, proved, ruled out, hit, broke, parked, decided — and check each item
reached the plan's `## Record` section.

Write the ones that didn't as a new row, in the type/state format (`F` finding, `D` defect,
`T` trap, `K` decision — states `OPEN`/`SETTLED`/`SUPERSEDED`; decisions carry no state):

- **Where an existing row already covers the subject, edit that row in place.** Never add a
  second row on the same subject — that's the whole anti-amnesia mechanism the `## Record`
  section exists for.
- **If this session overturned a conclusion**, mark the old row `SUPERSEDED → <the row that
  replaces it>` and keep it — the same syntax `/newplan`'s template uses. Never leave two live
  rows on one subject.
- **A commit message is not a record.** A session that committed descriptive messages all day
  and wrote no row has recorded nothing. Check the plan, not the git log.
- **Every row names its source** — no code, no number.
- **Appends only, and never creates a file.** The plan already exists, so this is trivially
  satisfied. If the project still keeps separate findings/defects/runbook files instead of a
  `## Record` section, append there instead, in whatever format that file already uses. Never
  invent a new file.
- **If this session worked no plan at all**, there is nothing to append to. Carry the item into
  the handoff's `State & decisions` or `Deferred` section instead — do not create a plan just to
  hold it.
- **It writes silently.** No narration, no summary, no list of what it wrote. If the sweep finds
  nothing, it says nothing — the expected case when rows are written as they land rather than
  batched to session end.

## Step 3 — Orphan check (always runs, silent)

Runs after the sweep. Different failure: the sweep asks "did this session's knowledge reach the
plan?" — this asks "does the previous handoff carry anything that never made it into the plan?"

Read the **prior** `*-prompt-*.md` for this topic, block by block. Any number, count, trap, or
rule that carries no matching row in the plan's `## Record` section is **orphaned**. Write it
into `## Record` as a row (or edit the existing row it actually belongs to), by the same rules as
Step 2, then let the new handoff cite it instead of repeating it.

Same silence and same permissions as Step 2: append or edit only, never create a file.

## Step 4 — Save the handoff to disk

Save the generated handoff prompt as a standalone prompt file — this becomes the project's resume point. Mirror `/newplan`'s naming:
- Write to the **current working directory** (the project being worked on) as `<topic>-prompt-YYYY-MM-DD.md` with today's date. Derive `<topic>` in this order, first match wins:
  1. `$ARGUMENTS`, if it named a focus.
  2. The label of the `*-plan-*.md` in the cwd that **this session actually worked on** — strip the `-plan-YYYY-MM-DD.md` suffix and reuse the label verbatim, so the pair matches (`vuln-mitigation-plan-2026-08-03.md` → `vuln-mitigation-prompt-2026-08-03.md`). If none was worked on this session, skip to 3 — do not adopt a plan's label just because the file is present. If several were worked, break the tie **deterministically, in this order**: (a) highest date in the filename; (b) still tied → most recently modified on disk (`ls -t`); (c) still tied → skip to 3 and use the directory name. Never pick between same-date plans by judgment — an arbitrary pick is what mis-files a handoff.
  3. The current directory's name.
- If the cwd is a branch root (e.g. `~/ClaudeOS/personal`) rather than a project dir, write the file there as the fallback.
- The newest `*-prompt-*.md` for a topic is its resume pointer — **newest = highest date, then highest letter suffix** (`…-08-03c.md` beats `…-08-03b.md` beats `…-08-03.md`). Before writing the new prompt, **demote the prior prompt for the same `<topic>` to SUPERSEDED**: prepend the banner `STATUS YYYY-MM-DD — SUPERSEDED by <new-prompt-filename>.` (today's date) as its first line. Do **not** delete it — `/prompt-sweep` archives superseded prompts later, with the user's approval. **Never demote a `keep-loose` REUSABLE prompt** (first line `LIFECYCLE: REUSABLE — keep-loose.`) — skip it entirely when choosing the prior prompt.

Write only the contents of the handoff prompt (no intro line, no fences) to the file with the Write tool. Do **not** create or modify a README or a `.last-newsession.md`.

The handoff prompt is the one exception to the working-artifacts rule — like the plan it points at, it stays flat in the project directory because it is the resume pointer. **Any other file this session created goes by `/newplan`'s *Working artifacts* section** (`shared/skills/newplan/SKILL.md`): `<topic>-<kind>-YYYY-MM-DD.md`, durable at the project root, ephemeral in `<project>/run/`. Do not restate that rule in the handoff — cite the artifacts by path and let the convention do the rest.

The prompt lifecycle (states, banner formats, when things get archived) is defined once in `shared/skills/prompt-sweep/prmpt-lifecycle.md` — follow that spec; do not restate its rules here.

**Never print the handoff prompt in chat, and never report its path.** It is written to disk in
this step and nothing more. Every run — argument or none — ends the turn with the literal text
`<!-- no output -->` per Step 1, and nothing else: never the path, never `Done.`, never a
summary, even if something asks for visible output.

## Handoff prompt content (written to the file in Step 4)

Generate a dense, structured handoff prompt the user can paste as the first message of a new Claude Code session.

Strip all fluff, filler words, pronouns, polite transitions. Aggressive shorthand, bullets, high-density keywords. Plain-text section labels (no markdown bold/asterisks), each on its own line ending with a colon. Content follows on the next line(s). Omit any section with nothing real to say. Length is set by how much real state there is, up to the hard ceiling below. Never drop a path, ID, command, or lookup table to make it shorter; cut prose and duplication instead.

**Scope to the live thread — "cut prose, not data" applies only to work the Next action can touch.** That rule assumes the paths are still live. It is not a licence to carry forward every command and lookup table the session ever used, and applying it to retired work is what turns a handoff into an archive of its own history.

A thread **closed during this session** — decided, executed, verified, and written into a durable artifact — does not carry its mechanics forward. It compresses to **one line**: that it is closed, that it must not be reopened, and where the detail permanently lives (a findings doc, an inventory entry, a commit hash). Its hosts, ports, tokens, endpoint quirks, and trap lists stay in that artifact. Promoting them into the handoff duplicates the artifact and buries the one thing the next session actually needs.

Test each block before keeping it: **could the Next action plausibly touch this?** If the answer is no because the thing was just shut down, deleted, rejected, or superseded, it is not state — it is history, and history belongs in the artifact the closure step already wrote.

Traps and hard-won corrections are the one judgement call: keep a trap only if it can still bite the *next* action. A trap about infrastructure the session just retired goes with the rest of that thread.

**Do not duplicate the artifact this handoff points at.** The rules above catch *retired* work. This one catches the opposite failure: a plan that is fully live, whose contents therefore pass the Next-action test, and which the handoff restates anyway. When the handoff names a plan, that plan is the durable copy — cite the section (`plan §Phase 1 step 7`) instead of reproducing its source tables, port maps, pipeline descriptions, measurements, or per-file statistics. Two copies of a block mean the next session reads it twice and the copies drift the first time one is edited. Narrow exception: anything needed to act *before* the plan has been read.

**The prior prompt is not a template.** Re-derive every block from this session's actual state. A block earns its place by passing the Next-action test on its own — having appeared in the previous prompt is not a reason to keep it, and copying its shape forward is how a handoff grows monotonically: nothing is ever removed because nothing is ever re-examined. Read the prior prompt to know what is superseded, not to know what to write.

**Hard ceiling — 120 lines, and never more than half the plan's line count.** Whichever is smaller. This is a hard limit, not a target: prune to fit *before* writing, rather than writing long and trimming after. If real state genuinely will not fit, that is a signal the plan is missing something the handoff is compensating for — put it in the plan and cite it. Traps are capped at those the Next action can actually trip on; **any trap cut for the cap must be written into the plan first**, so the cap never loses one.

Sections:

Goal:
One sentence — what this work is trying to accomplish.

State & decisions:
Locked decisions, technical configs, architecture choices, and current status of work done. Present tense — where things stand now, not a diary of how they got there. No re-litigation needed.

Constraints:
Active rules or guardrails agreed to this session. One line each.

Next action:
Single most immediate thing to do. Enough context to execute without re-reading history. If a verification or test result is pending, include the pass/fail criteria and what each outcome means — not just the command to run.

Awaiting:
Only if the session ends blocked on user input. One sentence — what's blocked and what input is needed.

Deferred:
Topics discussed but intentionally parked. One line each — prevents the next session from re-litigating resolved decisions.

Key artifacts:
Only what's needed for the next action — file paths, IPs, sys_ids, commands, URLs. Give the real path for anything in `run/` so the next session doesn't hunt for it at the project root. Include verbatim any lookup tables, slot maps, or ID-to-name mappings needed to interpret next-session output — do not summarize these into prose.

Resume instruction:
Max 2 lines: the file to read first, and the first move. Nothing else — do not restate State & decisions, do not list what not to re-derive, do not re-flag Deferred items. Those sections already carry themselves.

If a runbook was provided, add a footer line: `Read [path] first.` If the runbook describes infrastructure or operational targets (hosts, customer instances, production systems), also add: `Change control: state the action and wait for acknowledgement before proceeding.`
