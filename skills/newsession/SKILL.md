---
name: newsession
description: Token flush for long conversations — when context is filling up or a topic is wrapping up, invoke /newsession. Two modes: `/newsession` (silent — writes the handoff file only, no output, no pre-flight check; the sole exception is the one flush that promotes an ad-hoc thread to a findings artifact, which says so once) and `/newsession full` (also runs the urgent must-do-now check, then writes the file and prints its path). Optionally shaped by a runbook or planning file. Strictly user-invoked — never auto-triggers.
---

# /newsession — Session handoff

Look at what actually happened in this conversation (this session only — not memory, not prior sessions).

**Strictly user-invoked.** Only activate when the user types `/newsession`. Never auto-trigger.

## Step 1 — Resolve the optional argument

If `$ARGUMENTS` is empty:
- Run **Step 2.5** (close-out sweep — it is silent, and it is the whole reason a flush is safe), then **Step 2.55** (third-flush promotion — the one step that may speak) and **Step 2.6** (artifact-set consistency check, silent), then go straight to Step 3 (Save). No pre-flight scan, no display. Skip Step 4 as well: write the file, then end the turn with the literal text `<!-- no output -->` and nothing else — the **only** exception being a Step 2.55 promotion, which replaces it that once. It renders as nothing, so the user sees no output, and the harness gets a non-empty reply so it never asks for one.
- Derive `<topic>` by Step 3's ordering (worked-on plan's label, else the current directory's name).

If `$ARGUMENTS` is the literal word `full`:
- Run Step 2, then Step 2.5, then Step 2.55, then Step 2.6, then Step 3, then Step 4.
- Derive `<topic>` by Step 3's ordering — `full` takes no focus argument, so rule 1 never applies.

Otherwise, if `$ARGUMENTS` is provided, determine how to treat it (Step 2 still does **not** run — only `full` turns it on; **Steps 2.5, 2.55 and 2.6 always run**; finish with Step 4):
1. If it contains a "/" or ends in a file extension, treat as a file path — read it as a runbook and let its content shape the handoff.
2. If it's a bare filename (no slash, has extension), locate it: `find <workspace root> -name "<filename>" -type f 2>/dev/null | head -5` (the workspace root is the ancestor directory holding the branch/project tree) — one match → use it; multiple → list and ask; none → ask for full path.
3. If it's a short phrase (no slash, no extension, one or more words), treat as a focus instruction — bias the handoff toward that topic/area without filtering out other important context.

## Step 2 — Critical-only check (`full` only — never runs by default)

This step runs **only** when `$ARGUMENTS` is the literal word `full`. Otherwise skip it entirely.

Even under `full`: **just write the handoff and report its path** (Steps 3–4). Do not survey loose
ends, do not produce a two-list summary, do not ask what to finish first. Unfinished work
belongs in the handoff's Next action / Deferred sections, not in a pre-flight discussion.

The **only** exception: a single high-bar scan for anything genuinely urgent that must be
done NOW or real harm follows if the session flushes without it — e.g. an uncommitted
change the user explicitly asked to push, a half-applied edit that leaves things broken, or
live/temporary state that must be restored. If — and only if — such an item exists, flag it
in **one line** before writing and let the user decide (honor normal change-control and
destructive-op acks). If nothing clears that bar (the usual case), say nothing and proceed
straight to Step 3.

## Step 2.5 — Close-out sweep (runs in **both** modes, always)

Runs before the handoff is written, whether or not `full` was passed. The failure it catches is
mode-independent.

Walk what this session actually did — measured, proved, ruled out, hit, broke, parked, decided —
and check each item reached its artifact. Write the ones that did not, into the artifact that
owns them:

| Unrecorded | Goes to |
|---|---|
| A measurement, proof or ruling-out a future session would re-derive | findings, next `F#` |
| A bug, gap, limitation, or work parked with a reason | defects, next `D#` |
| An operational trap tripped or verified — a wrong turn that cost time | runbook, next `§` |
| A criterion whose status moved | acceptance |

The spec is `shared/skills/newplan/record-controls.md` (`CANONICAL:record-controls`) — follow it,
do not restate it. Two of its rules bind here:

- **A commit message is not a record.** A session that committed descriptive messages all day and
  wrote no `F#` has recorded nothing. Check the artifacts, not the git log.
- **Every entry names its source.** No code, no number.

**Appends only, and never creates.** The sweep may append to an artifact that already exists —
that is the artifact's declared purpose and the plan established it. It must **never create** an
artifact, and never write outside the ones the project already has.

**Authority to write without asking comes from the plan's `## Controls` section.** Plans written
before that section existed do not have one. In that case the append-only rule above still
stands and is the whole permission: adding `F15` to a findings doc the plan already owns is not a
new decision, so it needs no new approval.

**If the owning artifact does not exist**, do not invent it and do not ask mid-flush. Carry the
item into the handoff's Deferred section naming the artifact it is owed to, so it is visible and
survives. Creating a new artifact is a decision for the user, not for a flush.

**That holds for the first two flushes of an ad-hoc thread.** On the third, Step 2.55 creates the
artifact and these items go into it instead of into Deferred — see `record-controls.md` §8. Until
then, a growing Deferred section is the accumulation that step is watching for, not a fault.

**It writes silently.** No narration, no summary, no list of what it wrote, in either mode. A
bare `/newsession` still outputs `<!-- no output -->` and nothing else; `full` still prints only
its one line from Step 4. **The sweep never speaks — only Step 2.55 may, and only on the flush
that creates an artifact.** If the sweep finds nothing, it says nothing — which is the expected
case when the timing rule in the spec is being followed. A sweep that regularly finds a backlog
means the rule is not being followed and the sweep is being used as the mechanism instead of the
backstop.

## Step 2.55 — Third-flush promotion (runs in **both** modes, always)

Runs between the sweep and the consistency check, and only fires for **ad-hoc threads** — work
that grew out of a one-off question and never had a `/newplan`. The rule is `record-controls.md`
**§8** (`CANONICAL:record-controls`) — follow it, do not restate it.

**Fire when all three are true**, evaluated after Step 3's topic is derived:

1. this session worked **no** `*-plan-*.md` (topic-derivation rule 2 did not match), **and**
2. **two or more** prior prompts exist for this topic — this flush is the third or later, **and**
3. no findings artifact exists for it yet.

Otherwise skip the step entirely and say nothing. Flushes one and two never fire it.

**Counting is the part that goes wrong. Count archived prompts too.** `/prompt-sweep` moves
superseded prompts into the project's `archive/`, so the cwd holds only the recent tail of a
chain. Counting live files alone reports a thread that has flushed seventeen times as its first
flush, and the step then never fires for exactly the long-running work it exists to catch.

Three mechanics, all required. The first two are about *finding* the archived files; the third is
about *matching* them, and a project with subfolders needs all three or it counts zero.

- **Resolve `archive/` against the project root, never the cwd.** A project keeps **one**
  `archive/`, at its root, but a flush often runs from a subfolder — `foo/baz/`, working topic
  `bar`. `find ./archive …` from there matches nothing, `2>/dev/null` swallows the error, and the
  chain counts zero. That is the same undercount as counting live files only, one directory down.
  Walk up from the cwd to the nearest ancestor that contains an `archive/` and use that path.
- **Search that archive recursively**, for prompts *and* for the findings file in check 3. A chain
  that was archived along with its findings doc must not get a second one.
- **Strip the archive prefix before matching the topic.** `/prompt-sweep` prefixes each archived
  file with **the folder it was swept from** — the project directory for a root-level topic, but
  the *subfolder* for everything else. Topic `bar` in `foo/baz/` archives as `baz-bar-prompt-*.md`,
  **not** `foo-bar-prompt-*.md`. Stripping only `<project-dir>-` therefore misses every subfolder
  topic and reads the topic as `baz-bar`.
  **Strip a leading `<dir>-` where `<dir>` is the project directory or the name of any directory
  that exists inside it, and loop — the prefix stacks**: archived, then re-swept later, it is
  carried twice (`foo-foo-bar-prompt-*.md` is topic `bar`).
  **Stop before the last strip eats the topic** — the remainder must still match `*-prompt-*`.
  `baz-baz-prompt-*.md` strips once to `baz-prompt-*.md`, topic `baz`; a second strip would leave
  `prompt-*.md` and lose it.

Restricting `<dir>` to directories that actually exist is what stops a topic whose name happens to
begin with a folder name from being eaten by the loop.

Use `find`, **not** `grep` — `archive/` is gitignored, and the shell's `grep` silently skips
ignored paths. A count that comes back suspiciously low is this, every time.

```
root=<nearest ancestor of the cwd that contains archive/>
find . -maxdepth 1 -name '<topic>-prompt-*.md'          # the live tail
find "$root/archive" -name '*-prompt-*.md'              # the rest, prefix-stripped before matching
```

**Do not `2>/dev/null` the second command.** A missing `archive/` is the signal that `$root` was
resolved wrong; silencing it turns a wrong path into a plausible count of zero.

Two commands, deliberately. Combining them with `-o` puts `-maxdepth` after a predicate, where it
stops applying globally and silently returns the live files only — the exact undercount this
section exists to prevent. Verified against a real archive of 174 prompts: the combined form
returned 15, the two-command form 174.

Worked example. A project `foo/` whose topic `bar` has 3 live prompts, 4 archived as
`bar-prompt-*` and 13 as `foo-bar-prompt-*` totals **20** flushes. Had `bar` lived in `foo/baz/`,
those 17 would sit in `foo/archive/` as `baz-bar-prompt-*` — invisible from `foo/baz/` and
mis-topiced from `foo/`, which is why the first and third mechanics exist. Live-only counting reads 3;
prefix-blind counting reads 7. On a long-lived project the difference is not marginal — repeated
stripping can collapse dozens of apparent topics into the real ones, and a twice-swept topic can
go from an apparent single-digit count to several times that.

A dormant chain never fires this step, whatever its count, because the step only runs during a
flush of that topic. The count matters at exactly one moment: when a long-archived thread is
picked back up.

**When it fires**, create `<topic>-findings-YYYY-MM-DD.md` in the cwd, beside the prompts:

- Move the accumulated knowledge out of the prior prompt and this session into it — every
  measurement, proof, ruling-out, bug, gap and trap the thread produced.
- **One file, everything in it, numbered `F1…`** regardless of class, per §8. Do not also create a
  defects log or a runbook. Say in the header that it holds every class for now and why.
- Every entry names its source (§4). An entry recovered from a prior prompt that cannot name one
  says so plainly — `Source: carried in handoff prose since <prompt file>; not independently
  re-derived.` That is honest and citable; inventing a source is neither.
- Cite it from the new handoff's State & decisions by number. Do not restate it (§7.4).

**This is the one time a silent flush speaks.** Announce it in chat, once, in one or two lines —
what was created and what moved into it. Not a summary of the findings themselves:

```
Created llm-findings-2026-09-08.md — this thread's 3rd flush with no plan, so its knowledge
now has a home. F1..F6 moved out of the handoff and are cited from it.
```

A bare `/newsession` prints this **instead of** `<!-- no output -->` on that one flush, and goes
back to silent on every flush after. `full` mode prints it above its Step 4 path line. It never
fires twice for the same topic, because check 3 stops matching the moment the file exists.

**It creates exactly one file and nothing else.** No plan, no defects log, no runbook, no README.
`/newplan` stays the user's decision and is a different one — this step only gives existing
knowledge a home. If the check is uncertain whether the thread has a plan, treat it as having one
and skip: a missed promotion costs one more flush, an unwanted file costs the user's trust.

## Step 2.6 — Artifact-set consistency check (runs in **both** modes, always)

Runs after the sweep, before the handoff is written. Step 2.5 asks *"did this session's knowledge
reach an artifact?"* — this asks *"is the artifact set still internally consistent?"* Different
failure, and the sweep cannot see it, because the drift is usually not from this session's work.

The invariants are `record-controls.md` **§7** (`CANONICAL:record-controls`) — follow them, do not
restate them. Skip this step entirely if the project has no durable artifacts beyond the plan. After a Step 2.55 promotion there is one, so this check starts running from that flush onward.

Four checks, all mechanical. Run them against the artifact set the handoff points at:

| Check | §7 | How |
|---|---|---|
| No artifact names a specific prompt version | 7.1 | `grep -l '\-prompt-[0-9-]*[a-z]\.md' <artifacts>` — a hit in a table row or a "read next" line is stale by definition; rewrite to the `*` glob. A filename quoted inside a finding's evidence block is the subject, not a pointer (§7.1) |
| Every artifact cites the spec | 7.2 | `grep -L 'CANONICAL:record-controls' <artifacts>` — every file listed is missing its header line |
| Citations run both ways | 7.3 | If the runbook cites `F#`/`D#`, confirm those entries name the owning `§n` back. A runbook with zero inbound `runbook §` references is the signature failure |
| **Nothing lives only in the handoff** | 7.4 | Read the **prior** prompt block by block. Any number, table, count, trap or rule that carries no `F#`, `D#`, `§n`, `AC#` or path is **orphaned** |

**7.4 is the one that matters**, and it is the only one needing judgement. For each orphan, write
it into the artifact that owns it by the Step 2.5 table, then cite it from the new handoff instead
of carrying it. An orphan is not a formatting problem — it is a missing `F#` sitting in a pointer
file, and it dies at this flush if it is not written now.

Same permissions and same silence as Step 2.5: **appends only, never creates.** If an orphan's
owning artifact does not exist, carry it into the handoff's Deferred section naming the artifact
it is owed to — do not invent one, do not ask mid-flush. Write nothing to chat in either mode.

A check that fails every session means `/newplan` set the project up without these invariants, or
the artifacts were hand-edited around them. Say so in the handoff's Open threads, once.

## Step 3 — Save the handoff to disk

Save the generated handoff prompt as a standalone prompt file — this becomes the project's resume point. Mirror `/newplan`'s naming:
- Write to the **current working directory** (the project being worked on) as `<topic>-prompt-YYYY-MM-DD.md` with today's date. Derive `<topic>` in this order, first match wins:
  1. `$ARGUMENTS`, if it named a focus.
  2. The label of the `*-plan-*.md` in the cwd that **this session actually worked on** — strip the `-plan-YYYY-MM-DD.md` suffix and reuse the label verbatim, so the pair matches (`<label>-plan-2026-08-03.md` → `<label>-prompt-2026-08-03.md`). If none was worked on this session, skip to 3 — do not adopt a plan's label just because the file is present. If several were worked, break the tie **deterministically, in this order**: (a) highest date in the filename; (b) still tied → most recently modified on disk (`ls -t`); (c) still tied → skip to 3 and use the directory name. Never pick between same-date plans by judgment — an arbitrary pick is what mis-files a handoff.
  3. The current directory's name.
- If the cwd is a branch root (the parent of a `projects/` tree) rather than a project dir, write the file there as the fallback.
- The newest `*-prompt-*.md` for a topic is its resume pointer — **newest = highest date, then highest letter suffix** (`…-08-03c.md` beats `…-08-03b.md` beats `…-08-03.md`). Before writing the new prompt, **demote the prior prompt for the same `<topic>` to SUPERSEDED**: prepend the banner `STATUS YYYY-MM-DD — SUPERSEDED by <new-prompt-filename>.` (today's date) as its first line. Do **not** delete it — `/prompt-sweep` archives superseded prompts later, with the user's approval. **Never demote a `keep-loose` REUSABLE prompt** (first line `LIFECYCLE: REUSABLE — keep-loose.`) — skip it entirely when choosing the prior prompt.

Write only the contents of the handoff prompt (no intro line, no fences) to the file with the Write tool. Do **not** create or modify a README or a `.last-newsession.md`.

The handoff prompt is the one exception to the working-artifacts rule — like the plan it points at, it stays flat in the project directory because it is the resume pointer. **Any other file this session created goes by `/newplan`'s *Working artifacts* section** (`shared/skills/newplan/SKILL.md`): `<topic>-<kind>-YYYY-MM-DD.md`, durable at the project root, ephemeral in `<project>/run/`. Do not restate that rule in the handoff — cite the artifacts by path and let the convention do the rest.

The prompt lifecycle (states, banner formats, when things get archived) is defined once in `shared/skills/prompt-sweep/prmpt-lifecycle.md` — follow that spec; do not restate its rules here.

## Step 4 — Report the filename only (skipped when there was no argument)

**Never print the handoff prompt in chat.** It is written to disk in Step 3 and nothing more.

Output format — exactly one line, nothing else:
`Handoff written: <full path to the prompt file>`

A Step 2.55 promotion prints its own one-or-two lines immediately above this one, and only on the flush that created the file.

No preamble, no code block, no summary of the handoff's contents, no next-step commentary.
(A bare `/newsession` never prints this line. Its entire visible reply is `<!-- no output -->`
per Step 1 — never the path, never `Done.`, never a summary, even if something asks for
visible output. **One exception, once per topic:** a Step 2.55 promotion replaces `<!-- no
output -->` with its own one-or-two lines on the flush that created the artifact. It is the
only thing a bare flush may ever say, and it still never prints the path.)

## Handoff prompt content (written to the file in Step 3)

Generate a dense, structured handoff prompt the user can paste as the first message of a new Claude Code session.

Strip all fluff, filler words, pronouns, polite transitions. Aggressive shorthand, bullets, high-density keywords. Plain-text section labels (no markdown bold/asterisks), each on its own line ending with a colon. Content follows on the next line(s). Omit any section with nothing real to say. Length is set by how much real state there is, up to the hard ceiling below. Never drop a path, ID, command, or lookup table to make it shorter; cut prose and duplication instead.

**Scope to the live thread — "cut prose, not data" applies only to work the Next action can touch.** That rule assumes the paths are still live. It is not a licence to carry forward every command and lookup table the session ever used, and applying it to retired work is what turns a handoff into an archive of its own history.

A thread **closed during this session** — decided, executed, verified, and written into a durable artifact — does not carry its mechanics forward. It compresses to **one line**: that it is closed, that it must not be reopened, and where the detail permanently lives (a findings doc, an inventory entry, a commit hash). Its hosts, ports, tokens, endpoint quirks, and trap lists stay in that artifact. Promoting them into the handoff duplicates the artifact and buries the one thing the next session actually needs.

Test each block before keeping it: **could the Next action plausibly touch this?** If the answer is no because the thing was just shut down, deleted, rejected, or superseded, it is not state — it is history, and history belongs in the artifact the closure step already wrote.

Traps and hard-won corrections are the one judgement call: keep a trap only if it can still bite the *next* action. A trap about infrastructure the session just retired goes with the rest of that thread.

**Do not duplicate the artifacts this handoff points at.** The rules above catch *retired* work. This one catches the opposite failure: an artifact that is fully live, whose contents therefore pass the Next-action test, and which the handoff restates anyway. A project may own several durable artifacts, not just a plan — a defect log, a runbook, a findings doc, acceptance criteria. **Each one owns its content; the handoff cites it and never reproduces it.** Cite the section (`plan §Phase 1 step 7`, `runbook §1`, `defects D4`) instead of copying source tables, port maps, pipeline descriptions, measurements, or per-file statistics.

**Section ownership — where a block belongs when the project has these artifacts:**

| Handoff section | Owned by | Handoff carries |
|---|---|---|
| Deferred | the defect/backlog log | a pointer, plus anything the Next action must not re-litigate |
| Traps | the runbook | only traps the Next action can actually trip on |
| State & decisions | the plan and findings doc | current position, not the reasoning that produced it |
| Key artifacts | — | paths only |

If the owning artifact does not exist, the content stays in the handoff and **that is the signal to create the artifact**, not to let the section grow. Two copies of a block mean the next session reads it twice and the copies drift the first time one is edited. Narrow exception: anything needed to act *before* the plan has been read.

**The prior prompt is not a template.** Re-derive every block from this session's actual state. A block earns its place by passing the Next-action test on its own — having appeared in the previous prompt is not a reason to keep it, and copying its shape forward is how a handoff grows monotonically: nothing is ever removed because nothing is ever re-examined. Read the prior prompt to know what is superseded, not to know what to write.

**Soft cap — 120 lines, and never more than half the plan's line count.** Whichever is smaller. **If the session worked no plan, the cap is a flat 120 lines** — the half-the-plan clause simply does not apply, and it never prunes below 120 on its own.

**Soft means the number never wins against a fact.** Aim for it while writing, not by trimming after. When the draft is over:

1. **Cut duplication first** — anything already owned by a live artifact (runbook, defects log, findings, plan, CLAUDE.md). This is free: the content is not lost, and the section-ownership rules above already required it. Most overage is this.
2. **If it is still over, keep it.** Never delete a fact that lives nowhere else to hit a number. A handoff that resumes correctly at 130 lines beats one that fits at 118 and dropped the path the next session needed.
3. **Say so.** Add one line as the last line of the file: `Cap: N lines against a soft cap of 120 — over by M. Kept: <what and why>.` In `full` mode, append the same overage to Step 4's single line. A bare `/newsession` still prints nothing — the notice lives in the file, which is where it survives.

Persistent overage is a signal, not a failure: the plan is probably missing something the handoff is compensating for. Put it in the plan and cite it next time.

Traps are capped at those the Next action can actually trip on; **any trap cut for the cap must be written into the runbook first** — or the plan, if the project has no runbook — so the cap never loses one.

**When there is no Next action, the pruning test still applies — in a different form.** Every rule above tests a block by asking *"could the Next action plausibly touch this?"* An exploratory session may legitimately have no Next action, and the test must not simply lapse — that is how a handoff grows unbounded. Substitute: **"would the next session need this to pick the thread back up?"** Same severity, same burden of proof. A block that only records how this session got somewhere fails both forms.

**Sessions with no plan are a normal case, not a degraded one.** A long exploratory session — questions, reading, decisions, no plan file — still deserves a good handoff. It just carries different content: what was learned and what is still open, rather than progress against steps. Two sections flex accordingly (see below), and `Open threads:` usually becomes the most valuable block in the file. Do not invent a plan-shaped Goal or a Next action that the session never actually produced.

Sections:

Goal:
One sentence — what this work is trying to accomplish. **With no plan, this is what the session was *about*, not an objective** — "understand how X works and decide whether to adopt it" is a valid Goal.

State & decisions:
Locked decisions, technical configs, architecture choices, and current status of work done. Present tense — where things stand now, not a diary of how they got there. No re-litigation needed.

Constraints:
Active rules or guardrails agreed to this session. One line each.

Next action:
Single most immediate thing to do. Enough context to execute without re-reading history. If a verification or test result is pending, include the pass/fail criteria and what each outcome means — not just the command to run. **May legitimately be absent** when the session was exploratory and produced no committed next step — omit it rather than inventing one, because an invented next action sends the following session off on work nobody asked for. When it is absent, prune by the substitute test above.

Awaiting:
Only if the session ends blocked on user input. One sentence — what's blocked and what input is needed.

Open threads:
Optional, and usually the most valuable section in a session with no plan. Questions raised and **not resolved** — one line each, stated as the question, not as a topic. Distinct from `Deferred:`: an open thread is live and unanswered, a deferred item is a decision already taken to park something. Include enough context to re-ask the question cold. Where a partial answer exists, say what is known and what is missing.

Deferred:
Topics discussed but intentionally parked. One line each — prevents the next session from re-litigating resolved decisions. **If the project has a defect/backlog log, that log owns these** — carry a pointer and only what the Next action must not reopen. A Deferred block that keeps growing across prompts means the log is missing.

Traps:
Optional. Only hard-won gotchas that **the Next action itself can trip on** — a false-failure signal, a command that silently returns nothing, a flag that means the opposite of what it looks like. **If the project has a runbook, the runbook owns these** — carry at most 3 lines here and cite the runbook for the rest. With no runbook the soft cap is 10 lines, and exceeding it is the signal to create one. Both numbers are soft in the same sense as the line cap — a trap the Next action can genuinely trip on is never dropped to hit them, it is written to the runbook and cited. Never carry a trap forward because the previous prompt had it — re-derive it from this session or drop it.

Key artifacts:
Only what's needed for the next action — file paths, IPs, sys_ids, commands, URLs. Give the real path for anything in `run/` so the next session doesn't hunt for it at the project root. Include verbatim any lookup tables, slot maps, or ID-to-name mappings needed to interpret next-session output — do not summarize these into prose.

Resume instruction:
Max 2 lines: the file to read first, and the first move. Nothing else — do not restate State & decisions, do not list what not to re-derive, do not re-flag Deferred items. Those sections already carry themselves.

If a runbook was provided, add a footer line: `Read [path] first.` If the runbook describes infrastructure or operational targets (hosts, customer instances, production systems), also add: `Change control: state the action and wait for acknowledgement before proceeding.`
