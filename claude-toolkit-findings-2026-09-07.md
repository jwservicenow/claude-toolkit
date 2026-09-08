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

**No defects artifact and no runbook exist yet, and this file holds every class for now** —
findings, parked decisions and traps alike, all numbered `F#`. That follows `record-controls.md`
§8's one-file rule and its reasoning: an empty defects log reads as *"nothing is parked"* rather
than *"nobody wrote it down."* An entry that is `D#`- or `§n`-class in nature says so in its own
first line, so the split is mechanical if this ever earns three files. `JIM` ruled on this
2026-09-07 when the first parked decision arrived — `F10`.

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

---

## F8 — `VERIFIED` — an ad-hoc thread degrades by generation loss, and nothing signals it

Work that never had a `/newplan` has no artifacts, so on every flush `/newsession` hits two rules
that resolve against each other:

- §7.4's orphan check finds orphans and **has nowhere to write them**;
- the soft cap's step 1, *"cut duplication of live artifacts first,"* is **free but empty** —
  with no artifacts, nothing in the prompt is a duplicate.

So step 2 fires instead — *keep it, never delete a fact that lives nowhere else* — and the prompt
grows every flush, re-derived each time by a different context window. By the fifth flush it is a
~170-line file where nothing carries an `F#` and nothing names its source.

**Nothing breaks, and that is why it was never caught.** The handoff resumes correctly at every
step. What decays is provenance: a number drifts from the code that produced it, and a hedge
hardens into a confident claim. `JIM` has an existing standing correction about exactly that
hardening, which is evidence this had already happened rather than a hypothetical.

Three separate places in `/newsession` already declared the condition — *"that is the signal to
create the artifact,"* *"exceeding it is the signal to create one,"* *"persistent overage is a
signal"* — and **nothing consumed any of them.** Three declared signals, zero consumers, so none
ever fired.

Now `record-controls.md` §8 and `/newsession` Step 2.55: on the third flush for a topic with no
plan, create `<topic>-findings-YYYY-MM-DD.md`, move the knowledge in, cite it. One file holding
every class, because empty artifacts read as *"nothing was found"* rather than *"nobody wrote
anything down."*

**A first design was rejected before it shipped: ask the user each time.** `JIM`: *"why nag? Just
kickoff /newplan."* The nag was defensive reasoning from `F3`, which forbids a silent flush from
inventing files *in a directory of its choosing* — but by the third flush three prompts already
sit in that directory, so nothing is being chosen and the guard does not apply. Automatic
creation, announced once, replaced it.

Source: this file, 2026-09-07. Threshold and one-file scope are `JIM`'s rulings; the failure
analysis was derived by tracing the soft-cap and §7.4 rules against a project with no artifacts.

---

## F9 — `VERIFIED` — the third-flush trigger counted only live prompts, so it never fired for long threads

`F8`'s Step 2.55 counted `<topic>-prompt-*.md` "against the cwd." `/prompt-sweep` moves superseded
prompts into the project's `archive/`, so **the cwd holds only the recent tail of a chain.** A
thread that had flushed seventeen times read as its first flush, and the step would never have
fired for exactly the long-running work it exists to catch.

Two independent mechanics, both needed, both missing:

| | Effect if omitted |
|---|---|
| Search `archive/` recursively, for prompts **and** the findings file | Long chains count near zero; an archived chain gets a second findings doc |
| Strip `/prompt-sweep`'s parent-folder prefix before matching the topic | Every archived chain reads as a different topic and counts zero |
| Strip it **repeatedly** — the prefix stacks on a re-swept chain | A twice-archived chain still counts zero, and splits into a third phantom topic |

Measured on `~/ClaudeOS/personal/projects/homelab`, 2026-09-07. Topic `homelab`: **3** live
prompts, **4** archived as `homelab-prompt-*`, **13** more as `homelab-homelab-prompt-*` — twenty
flushes. Live-only counting reads three; prefix-blind counting reads seven. Ten other topics in
that folder carry 3–19 archived prompts and zero live, and would never have triggered on resume.

The prefix **stacks**: `homelab-homelab-health-dashboard-prompt-*.md` is topic `health-dashboard`,
archived and later re-swept. Stripping once leaves a phantom topic; stripping in a loop collapses
65 apparent topics in that folder to the 55 real ones and takes `health-dashboard` from an
apparent 9 to its true 16. Verified by re-running the dry test after the fix.

**The example command shipped in the fix was itself wrong**, and demonstrates the same trap:

```
find . -path '*/archive/*' -name '*prompt-*.md' -o -maxdepth 1 -name '*prompt-*.md'   # 15
find . -maxdepth 1 -name '*prompt-*.md'; find ./archive -name '*prompt-*.md'          # 174
```

`-maxdepth` after a predicate stops applying globally and silently returns the live files only.
No error, no warning, a plausible number. Now two separate commands, with the counts recorded so
nobody re-combines them.

**A third claim made during this work was wrong and is withdrawn** (§6 — the record of what was
believed matters): `uptime-kuma-planning-prompt-2026-08-12.md` was reported as able to fool
topic-derivation rule 2, because "planning" contains "plan". It cannot. Rule 2 globs `*-plan-*.md`
and the file has `-planning-`, so the delimiter does not close. It matches only the `.gitignore`
blanket `*[Pp][Ll][Aa][Nn]*.md`, which is expected for a prompt. The error came from reading an
`ls` that used the blanket pattern and attributing the hit to the topic glob. Verified both ways
with shell pattern matching before withdrawal.

Source: dry run of Step 2.55's conditions against every prompt chain in `homelab/`, 2026-09-07 —
`JIM` asked for it to be tested there. It found both defects on the first run, one day after
`F8` shipped.

---

## F10 — `PARKED` (`D#`-class) — archive-prefix stacking is compensated for, not fixed

`/prompt-sweep` Step 5 prefixes every archived file with its immediate parent folder name —
*"always, every file, **no dedup**."* A file that is archived, returned to the project root, and
archived again therefore carries the prefix twice.

**It is not hypothetical.** Prefix depth across the 159 archived prompts in
`~/ClaudeOS/personal/projects/homelab/archive/`, 2026-09-07:

| `homelab-` prefixes | Files |
|---|---|
| 0 | 68 |
| 1 | 64 |
| 2 | 27 |

There are **no nested `archive/` directories**, so a double sweep is the only path that produces
the 27 — swept, moved back, swept again. Measured with a prefix-stripping count over
`archive/*prompt*.md`; the absence of nesting checked with `find . -type d -name archive`.

**The decision: compensate in the consumer, do not change the naming rule.** `/newsession` Step
2.55 strips the prefix in a loop (`F9`). `/prompt-sweep` is left exactly as it is.

Why, and it is a genuine trade rather than laziness:

- 159 files already sit on disk under the current convention. Changing the rule makes the sweep
  disagree with its own history, and the archive stops being self-describing.
- Renaming them to dedup would break any path that points at one — and prompts are cited by path
  from plans, runbooks and other prompts, none of which are searchable by a bare `grep`, because
  `archive/` and every `*prompt*.md` are gitignored. The blast radius cannot be measured cheaply,
  which is itself the argument for not swinging.
- Stacking is harmless as long as every consumer strips in a loop. Today there is exactly one
  consumer.

**What would reopen it:** a *second* consumer needing topic matching. At that point the loop-strip
is duplicated logic in two skills, and the cheaper fix flips to making `/prompt-sweep` idempotent —
skip the prefix when the filename already starts with it — which fixes new files without touching
the 159. That is a one-line change guarded by one condition; it is deferred only because nothing
needs it yet.

Source: `JIM` asked whether `/prompt-sweep` still works after `F8`/`F9`. It does — it globs
`*-prompt-*.md`, so findings files never enter its scan, are never classified, moved or prefixed.
The stacking was found while confirming that, and parked on his instruction to record the decision
rather than act on it.
