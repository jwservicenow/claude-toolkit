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
