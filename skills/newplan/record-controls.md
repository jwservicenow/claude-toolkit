<!-- CANONICAL:record-controls -->
# Plan design controls — the record obligation

**Cited, never copied.** `/newplan` writes this into every plan by reference; `/newsession`
enforces it at close-out. If a rule here needs to change, change it here.

---

## Why this exists

A plan that produces knowledge and does not record it forces the next session to derive it
again. That is the most expensive failure mode in a long-running project, and it is silent —
nothing breaks, nothing fails a test, the work just gets done twice.

The failure has a specific shape, and it is not forgetfulness:

> A measurement lands. It gets reported in chat, and the code that produced it gets committed
> with a descriptive commit message. Both feel like recording. Neither is. The finding never
> reaches the artifact the next session actually reads, and four hours later there are ten of
> them, none written down.

Written 2026-09-07 after exactly that: six findings and four defects surfaced in one session and
were recorded only when the user asked where they were.

---

## 1. The record obligation

Each artifact owns a class of knowledge. When something in that class appears, it gets written
**to that artifact**, then and there.

| When this happens | It goes to | Numbered |
|---|---|---|
| Something is measured, proven, or ruled out that a future session would otherwise re-derive | **findings** | `F1…` |
| A bug, a gap, a limitation, or work deliberately parked — with why | **defects** | `D1…` |
| An operational trap is tripped or verified: a wrong turn that cost time and would cost it again, a host/service mechanic, a recovery step | **runbook** | `§n` |
| A criterion's status changes, or "done" is redefined | **acceptance** | by criterion |
| A decision is made, an approach is abandoned, a step's status moves | **the plan** | by step |

**The runbook is the one most often skipped**, because a trap feels like a private
embarrassment rather than a finding. It is not. The entry is the deliverable: *what looked
right, what actually happened, and the check that would have caught it.* A trap you solved and
did not write down is a trap you will solve again.

---

## 2. Timing — write it when it lands

**Record before you report.** The artifact entry is written *before* the finding is described in
chat, not after, and never batched to the end of a session.

Two reasons, both practical. A finding described in chat first is already "communicated," so the
write feels redundant and gets dropped. And a session that ends unexpectedly — context flush,
interruption, a crash — loses everything not yet on disk.

There is no batch size that is acceptable. One finding held back is the same failure as ten.

---

## 3. What is not a record

None of these is where the next session looks. Writing to them instead of the artifact is the
failure this spec exists to stop:

| Not a record | Why |
|---|---|
| **Chat** | Gone at the next context flush. Unsearchable, uncitable, unnumbered. |
| **A commit message** | Describes a change, not a finding. Invisible unless someone runs `git log` against the right path, and outside the `F#`/`D#` numbering everything else cites. |
| **A status line in the plan** | "Step 1.3 done" is a status, not the knowledge that produced it. |
| **The handoff prompt** | A pointer. A prompt that keeps growing is a missing artifact, not a formatting problem. |
| **A code comment** | Scoped to the line it sits on. It cannot hold a measurement, a count, or a rejected approach. |

---

## 4. Every entry names its source

An entry that cannot be re-derived is an assertion, not a finding.

- A number names the **script or command** that produced it, and the run.
- A rejected approach names **what was tried and what it produced**, so nobody retries it.
- A gap names **how absence was established** — which sources were checked and came back empty.
- A trap names the **check that would have caught it**.

"No code, no number" is the short form. A finding written without its source is worth less than
no finding, because it will be trusted later and cannot be verified.

---

## 5. Close-out sweep

Before a session's handoff is written, sweep it: walk what was measured, decided, hit or parked,
and confirm each one reached its artifact. Write the ones that did not.

This is a **backstop, not the mechanism.** Section 2 is the mechanism. A sweep that regularly
finds unrecorded items means the timing rule is not being followed, and the sweep will eventually
miss things the same way.

The sweep writes. It does not narrate, summarise, or ask.

---

## 6. Citation

Artifacts cite each other by number and never copy: `F14`, `D3`, `runbook §3.2`, `AC2`. One
block, one home. Two copies drift the first time one is edited.

When a later finding corrects an earlier one, **both stay**. Amend the old entry to point at the
new one. A finding that is silently rewritten destroys the record of what was believed and when,
which is usually the thing that explains a later mistake.

**Amending the old entry is not enough — a correction is not done until it has propagated.** The
rule above governs finding → finding, inside the record set. A wrong belief rarely stays there. By
the time it is disproven it has usually been copied into the documents that *give instructions* —
the runbook, the plan, the handoff — and those are what the next session reads and acts on. A
correction that lands only in the findings file leaves the instruction intact, so the next session
does the disproven thing while the artifact set technically contains the truth.

So a correcting entry carries a **propagation list**: every artifact it searched and every place it
fixed. If the search was clean, it says so. Section 7.5 is how that is checked.

---

## 7. Set-level invariants — what a consistent artifact set looks like

Sections 1–6 govern one entry at a time. These govern the **set**, and they are the rules
`/newsession`'s Step 2.6 check enforces. Each is mechanical on purpose — a session should be able
to verify it with `grep`, not judgement.

**7.1 The handoff names artifacts by glob, never by version.** A prompt is superseded every
session; a fixed pointer like `…-prompt-2026-09-07c.md` in an artifact is stale within hours and
sends the next session to a dead file. Artifacts refer to `<topic>-prompt-YYYY-MM-DD*.md` and let
the newest-letter-wins rule resolve it.

*One exception, and only one:* a finding may **quote** a specific prompt filename as evidence —
that is the subject of the entry, not a pointer to follow. The check distinguishes them by
position: a name inside a table row or a "read this next" line is a pointer and fails; a name
inside a finding's evidence block does not.

**7.2 Every artifact cites this spec; none restates it.** One line in each header naming
`CANONICAL:record-controls`. An artifact that describes its own role in its own words has forked
the spec, and the fork drifts the first time either side is edited.

**7.3 Citation runs both ways.** If the runbook cites `F1`, `F1` names the `runbook §` that owns
its operational form. A one-way edge means half the set does not know the other half is
citable — which is how a section-numbered runbook ends up with zero inbound `§n` references and
gets restated instead of cited.

**7.4 Nothing lives only in the handoff.** This is the whole point. Every number, table, trap,
count or rule in the prompt must be *citable* — it carries an `F#`, `D#`, `§n` or `AC#`, or it
names a path. A block in the prompt that carries none of these is **orphaned**: no artifact owns
it, so it dies at the next flush, and it is invisible to everything that cites by number.

> An orphan is not a formatting problem. It is a missing artifact entry that happens to be
> sitting in a pointer file. §3 already says the handoff is not a record; 7.4 is how that is
> checked rather than assumed.

Found 2026-09-07: the six-area document split and the `--no-ignore-files` grep trap existed only
in the handoff, and three of four artifacts pointed at a prompt two generations dead. Fixed as
`F21` and `runbook §3.8`.

**7.5 A superseded claim survives nowhere in the set.** When an entry is corrected, grep the
*whole* set for the old claim — findings, defects, runbook, plan, and every prompt, superseded ones
included — and fix or banner each hit. The correcting entry names what it corrected. Clean grep, or
it is not finished.

> Superseded prompts matter more than they look. They are read-only, so nobody edits them, and a
> future session skim-reading one for context takes its instructions at face value. Banner them at
> the top rather than trusting the status line to be noticed.

Found 2026-09-09: a tool's own docstring claimed it produced clean output. That claim was recorded
as verified, then repeated in a defect entry, a runbook trap section, a stage table and two prompt
files. Three successive findings corrected the *conclusion* without touching any of them, so for a
week the instruction-bearing documents named the tool that caused the corruption as the tool that
fixed it. Every check that had been run was a prefix check; nothing validated to end-of-file.

---

## 8. Ad-hoc threads — the third-flush rule

Sections 1–7 assume a plan opened the artifacts. Plenty of work never starts that way: a one-off
question turns into a real effort, `/newsession` runs three, four, five times, and no artifact was
ever created because no `/newplan` ran.

**Nothing breaks in that case, and that is the problem.** The handoff resumes fine every time. But
§7.4's orphan check has nowhere to write to, and the soft-cap rule *"cut duplication first"* has
nothing to cut against, because with no artifacts every fact lives only in the prompt. So rule 2
fires instead — keep it — and the file grows every flush, rewritten each time by a different
context window. What decays is provenance: numbers drift from the code that produced them, and
hedges harden into confident claims. That is generation loss, not a failure, which is exactly why
nothing ever signals it.

**The rule.** On the **third** `/newsession` for a topic that has no plan, the flush creates
`<topic>-findings-YYYY-MM-DD.md` beside the prompts, moves the accumulated knowledge into it with
sources, and cites it from the new handoff. Flushes one and two change nothing — two prompts of
growth is not yet a project, and creating a file for every passing question is its own clutter.

**One file, and everything goes in it.** Not findings plus defects plus a runbook. An ad-hoc
thread rarely produces enough of any one class to justify three files, and empty artifacts are
worse than absent ones — an empty findings doc reads as *"nothing was found"* rather than
*"nobody wrote anything down."* Number everything `F#`, including bugs and traps, and say so in
the file's header. If the thread later grows a real artifact set, the `D#`- and `§n`-class entries
split out then, and §6 keeps both copies pointing at each other.

**It is not asked for, and it is announced once.** By the third flush there is nothing left to
decide: three prompts already sit in that directory, so the topic and the location are settled and
the `F3` guard — a silent flush must not invent files *in a directory of its choosing* — does not
apply. The creation is the one thing a silent flush may say out loud, exactly once per topic.

`/newplan` remains the user's call and is a different decision: it is for when the work needs
steps and acceptance criteria. This rule only gives existing knowledge a home, which needs no plan.

---

## 9. Retirement — what happens to a record artifact when its plan closes

§§1–8 govern how a record is born and what it must contain. Nothing governed what happens to it
afterwards, and that asymmetry had a consequence: **prompts have a full lifecycle spec
(`CANONICAL:prompt-lifecycle`) with four states, a precedence order and a monthly sweep as
backstop; findings, defects and runbooks had one sentence inside `/newplan`'s Closure step.** A
findings doc that nobody retires simply loads forever, and no tool notices.

**Three outcomes, and the artifact's own name decides which.**

| Outcome | Applies to | What happens |
|---|---|---|
| **OUTLIVES** | A **version-free** artifact — `<topic>-defects.md`, `<topic>-runbook.md`, a findings doc named without a date | Stays exactly where it is. **Never** archived with the plan. It describes the project, not one round of work |
| **HISTORY** | A **dated** artifact whose successor exists — `<topic>-findings-2026-06-01.md` when `…-2026-09-07.md` is live | Banner it, leave it in place. It stops being a live record and becomes citable history |
| **ARCHIVED** | A dated artifact scoped to **that plan's round only**, which nothing else cites | Moves into the project's `archive/` with the plan and prompt |

**The banner, mirroring `CANONICAL:prompt-lifecycle`'s vocabulary so the two specs read alike:**

```
STATUS YYYY-MM-DD — HISTORY. Superseded by <successor-filename>. Read-only; cite, do not append.
```

`HISTORY` rather than `DONE` on purpose. A `DONE` prompt is finished and sweepable; a superseded
findings doc is still cited by number from live artifacts and must not be swept away behind those
citations.

**Two checks before anything moves, both mechanical:**

1. **Is it cited by something still live?** `grep -rn --no-ignore-files '<F#|D#|§n from this file>'`
   across the project. **The `--no-ignore-files` is not optional** — records are gitignored, so a
   bare `grep` returns zero hits and reads as "nothing cites it." That failure mode looks exactly
   like a clean result. If anything live cites it, it is HISTORY, never ARCHIVED.
2. **Is the name dated?** No date means OUTLIVES, and the question ends there.

**Who does this, and the honest gap.** `/newplan`'s Closure step is the **only** enforcement.
There is no equivalent of `/prompt-sweep` for records — nothing runs monthly and finds a findings
doc that should have been bannered two plans ago. Until there is, a plan that closes without
running its own Closure step leaves records live forever, and nothing will catch it.

Recorded 2026-09-07: found while closing a plan, when the closure checks for findings, defects
and runbooks turned out to trace back to a single sentence.

---

## 10. Search before you investigate

Before starting work on a symptom, grep the record set for it. Findings, defects, runbook, plan.
This costs one command and it is the only thing that stops the same problem being solved twice.

**The failure it prevents is not a duplicated entry — it is a contradictory one.** A session that
does not find the prior work does not re-read the old answer; it re-derives from scratch, and a
fresh derivation lands somewhere slightly different. Two sessions then leave two incompatible
answers to one question, both recorded, both cited, with nothing marking which is current.

This rule earns its place because a split artifact set makes it necessary. When everything lived in
one document, "have we seen this?" was answered by reading that document. Once a discovery has three
plausible homes — is it a finding, a defect, or a runbook trap? — a session that greps the wrong one
concludes the problem is new. The split is worth keeping; it just moves the cost onto this search,
and the search has to be mandatory rather than remembered.

Search on the **symptom**, not the diagnosis you currently favour. The prior entry was written by
someone who did not yet know the answer either, so it is filed under what was observed.
