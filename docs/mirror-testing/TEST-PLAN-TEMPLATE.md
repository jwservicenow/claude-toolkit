# <TOPIC> Mirror Test Plan — Template

**Prepared by:** <name>, ServiceNow <practice>
**Date:** <YYYY-MM-DD>
**Branch:** `australia`  (swap for xanadu / yokohama / zurich to test another release)
**Mirror:** ServiceNow/ServiceNowDocs (GitHub, raw.githubusercontent.com)
**Status:** Code side <NOT STARTED|IN PROGRESS|COMPLETE> · Desktop side <PENDING|COMPLETE>

> Copy this file to `mirror-testing/<topic>/test-results-<date>.md` and fill it in.
> Keep a candid internal copy; publish a softened/anonymized copy per convention.

---

## Finding-type vocabulary  (use these exact labels in the Findings Log)

| Type | Meaning |
|---|---|
| `empty-file`      | HTTP 200 with 0 bytes — fetch succeeds, no content, no error signal |
| `oversized-index` | Single `.md` > 500KB — pagination/truncation risk for retrieval |
| `bundle-routing`  | Topic lives in an unexpected bundle (or is split across bundles) |
| `missing-xref`    | Expected cross-bundle navigation link absent or unverifiable |
| `no-canonical-url`| `canonical_url` front-matter missing on a populated page |

## Pass / Flag rule

- **Pass** — AI answers from a mirror-cited source in under 3 minutes.
- **Flag** — answer drifts, lands on an empty file, or guesses a path.

---

## Pre-Flight — Bundle Location & Structure

**Result: <PASS|FLAG> — <one-line verdict>.**

| Sub-dir | .md files | Empty (0-byte) | % empty |
|---|---:|---:|---:|
| <sub-dir> | <n> | <n> | <n>% |
| **TOTAL** | **<n>** | **<n>** | **<n>%** |

**Headline:** <X of Y files (Z%) are 0 bytes. Stub count (<200b): <n>.>

---

## Root-Cause Confirmation

Empties return **HTTP 200 with 0 bytes** — no error signal. Verified on samples:

| File | HTTP | Bytes |
|---|---|---|
| <path> | 200 | 0 |

<One-line interpretation of the retrieval impact.>

---

## Suite 1 — <Sub-area>

- **<ID>-1 file count:** <n> files.
- **<ID>-2 empty/stub sweep:** <n> empty (<%>). <notable clusters>
- **<ID>-3 canonical_url:** <present & correct | finding>.
- **<ID>-4 (Desktop):** PENDING — prompt: "<the question to paste into Claude Desktop>".

## Suite 2 — <Sub-area>
<repeat the four-line pattern: file count → empty/stub → canonical_url → Desktop prompt>

---

## Findings Log (Code side)

| ID | Sub-area | Test | Finding type | Description | Severity |
|---|---|---|---|---|---|
| F1 | <area> | <test> | <type> | <description> | <High|Med|Low> |

---

## Pass / Fail Summary

| Test | Sub-area | Result |
|---|---|---|
| Pre-Flight | <area> | <PASS|FLAG> — <note> |
| <ID>-1 | <area> | <Done|PASS|FLAG|PENDING> |
