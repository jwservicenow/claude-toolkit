# claude-toolkit — Findings

STATUS: ACTIVE. Opened 2026-09-07. Version-free by design — it describes the toolkit, not one
iteration of it.

Created because the toolkit had no findings artifact, so knowledge about its own skills was
being recorded in commit messages only. `record-controls.md` §3 says plainly that a commit
message is not a record: it describes a change, sits outside the `F#` numbering everything else
cites, and is invisible unless someone runs `git log` against the right path. Seven entries below
were recovered from exactly that state.

## The artifact set

Each file owns its content; the others cite it and never restate it.

| File | Owns |
|---|---|
| `skills/newplan/record-controls.md` | **`CANONICAL:record-controls`** — the record obligation and the set-level invariants. The controlling spec |
| `claude-toolkit-findings-2026-09-07.md` — **this file** | Findings about the toolkit's own skills and commands, `F1…` |
| `skills/prompt-sweep/prmpt-lifecycle.md` | **`CANONICAL:prompt-lifecycle`** — prompt states, banners, archiving |
| `README.md` | The repo front page. Not a resume point |
| `claude-toolkit-prompt-2026-*.md` / `shared-prompt-2026-*.md` | The paste-to-resume handoffs, newest letter suffix wins. Pointers, never records. **Two lineages exist — see `F7`** |

The roles in this table, and the obligation to write to them as knowledge lands, are **CANONICAL**
in `skills/newplan/record-controls.md` (`CANONICAL:record-controls`) — cited, never restated.

**No defects artifact and no runbook exist yet.** That is a deliberate gap, not an oversight: no
`D#`-class or `§n`-class item has needed a home here. The first one that does is the signal to
create them, per `record-controls.md` §7.4 — not a reason to misfile it on this page.

---

## What goes here

Anything measured, proven or ruled out **about the toolkit's own skills, commands and scripts** —
audits, design failures found before they fired, constraints the repo imposes on itself. Findings
about a *project* that merely used a skill belong to that project's own findings doc.

Every entry names its source (`record-controls.md` §4): the commit that carries the change, and
what was actually checked.

---

## F1 — `VERIFIED` — `/newsession`'s close-out sweep could never have run in its default mode

Step 2.5 declared itself *"runs in both modes, always."* Step 1's routing sent a bare
`/newsession` straight to Step 3, so the sweep would never have executed in **the mode that is
used most**. The claim was written without checking the routing that governs it.

Found by auditing the step before its first live run — it had never executed once. All three
argument paths now reach it explicitly.

Source: commit `1a5e486`. The check that catches this class: for any step claiming "always",
trace every branch in the skill's own dispatch section and confirm each one names it.

---

## F2 — `VERIFIED` — the sweep claimed write authority from a section no existing plan had

Step 2.5 justified writing to project artifacts by citing the plan's `## Controls` section,
*"approved when the plan was written."* That section was introduced in the same change that
introduced the sweep, so **every plan then in existence lacked one** — the sweep would have
written into project artifacts with no approval anywhere.

Replaced with an append-only rule that stands on its own: appending `F15` to a findings doc the
plan already owns is not a new decision and needs no new approval. Creating an artifact still is.

Source: commit `1a5e486`. Generalises to any skill deriving authority from a template it also
introduced — the authority is retroactive and does not exist.

---

## F3 — `VERIFIED` — the sweep had no rule for a missing owning artifact

Nothing in Step 2.5 said what to do when the artifact that owns an item does not exist. During a
**silent** flush it could therefore have invented files in a directory of its choosing, with no
output telling anyone it had.

It now carries the item into the handoff's Deferred section, naming the artifact it is owed to,
and creates nothing. Creating an artifact is a decision for the user, not for a flush.

Source: commit `1a5e486`. This is why `F7` below sat unrecorded rather than being filed somewhere
convenient, and why this very file needed asking for.

---

## F4 — `VERIFIED` — a hard line cap loses to its own content by construction

`/newsession`'s 120-line ceiling was written as hard, with *"prune to fit before writing."* That
puts a number in direct competition with the content the next session needs, and **the number
wins every time**, because it is the only side of the contest that is measurable.

The cap is now soft, with three ordered steps on overage: cut duplication of live artifacts first
(free — the section-ownership rules already required it), then keep the overage rather than drop
a fact that lives nowhere else, then declare it in one line at the end of the file. The notice
goes in the file, not in chat, so a bare `/newsession` stays silent and the warning still
survives the flush.

Source: commit `0eec13c`. Persistent overage is a signal, not a failure: the plan is probably
missing something the handoff is compensating for.

---

## F5 — `VERIFIED` — the spec's own filename could not contain the word "plan"

The recording spec was going to be `plan-controls.md`. The repo's `.gitignore` carries a blanket
`*[Pp][Ll][Aa][Nn]*.md`, so that file would have worked on the machine that wrote it and been
**absent on a fresh clone** — silently breaking the `CANONICAL:record-controls` citations in both
`/newplan` and `/newsession`, with no error at any point.

Named `record-controls.md` instead. Verified with `git check-ignore` against both candidate names.

Source: commit `51054c5`. The general form: any file a skill cites by path must be tested against
the ignore rules of the repo it ships in, not just written to disk successfully.

---

## F6 — `VERIFIED` — §1–6 governed one entry at a time and could not see set-level drift

The spec specified when a single entry is owed and where it goes. It said nothing about the
**set** staying consistent, so four kinds of drift were invisible to every check in it:

| Drift | Why §1–6 missed it |
|---|---|
| An artifact naming a specific prompt version | Each entry is individually correct; the pointer just rots |
| An artifact describing its own role instead of citing the spec | Reads as documentation, not as a fork |
| A section-numbered runbook nothing cites back | One-way edges look like an absence of need |
| Content living only in the handoff | §3 declares the handoff is not a record but never checks it |

Now `record-controls.md` §7, four mechanical invariants. `/newplan` establishes them at write
time and tests for them in Step 5 self-review; `/newsession` Step 2.6 verifies them every flush,
both modes, silently, appends-only.

Measured against a real set the same day — the `ram-fca-v11` artifacts — the check found all four
drifts present at once, including two blocks of content that existed nowhere but the handoff.

Source: commit `d32637f`. §7.4 is the load-bearing invariant: anything in the prior prompt
carrying no `F#`, `D#`, `§n`, `AC#` or path is an orphan and dies at the next flush.

---

## F7 — `VERIFIED` — `/newsession` cannot derive a topic for a plan the ignore rule forbids naming

Step 3's topic-derivation rule 2 reads the label of the `*-plan-*.md` the session worked on. The
blanket `*[Pp][Ll][Aa][Nn]*.md` ignore rule means **a versioned plan can never carry that name**,
so rule 2 cannot match for any plan that is tracked in git. It falls through to rule 3, the
directory name, and writes a handoff whose topic does not match the chain it belongs to.

**This repo is the evidence.** Its handoffs exist in two lineages that are the same chain:

```
claude-toolkit-prompt-2026-08-07.md, …-08-07b.md     <- named by topic
shared-prompt-2026-08-31.md, shared-prompt-2026-09-05.md  <- named by directory, "shared"
```

The fall-through already happened here and forked the resume pointer. The same failure in
`~/ClaudeOS/personal/projects/llm` would write `llm-prompt-*.md` and orphan the `ram-fca-v11`
chain, which is six prompts long.

Established by reading Step 3's rules against `.gitignore` line 8 and confirming with
`git check-ignore`, then observing the two lineages on disk. **The fix is not chosen** — it is
`D#`-class work owed to a defects artifact this repo does not have, per the header above.

Source: this file. The behaviour predates it and was carried in handoff prose until now.
