# ITOM Mirror Test Results

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Branch:** `australia`
**Mirror:** ServiceNow/ServiceNowDocs (GitHub)
**Surfaces:** Claude Code (`/servicenow_rag`) · Claude Desktop

Results across five ITOM areas missed in initial testing — Service Mapping, MID Server, Agent Client Collector, Event Management, and Health Log Analytics. The companion **recommendations** doc in this folder translates these into prioritized fixes.

---

## Pre-Flight — Bundle Availability & Location

All five areas are present on `australia`, but they are **not co-located**:

| Area | Location | Sub-index | Note |
|---|---|---|---|
| Service Mapping | `it-operations-management/service-mapping/` | No — folded into single ITOM `index.md` | — |
| MID Server | `servicenow-platform/mid-server/` (~60 files) | No sub-index | **Not under `it-operations-management/`** — an ITOM-scoped query won't look here (`bundle-routing`) |
| Agent Client Collector | `it-operations-management/agent-client-collector/` | No — in ITOM `index.md` | Newest capability |
| Event Management | `it-operations-management/event-management/` | No — in ITOM `index.md` | — |
| Health Log Analytics | `it-operations-management/health-log-analytics/` | No — in ITOM `index.md` | — |

**Key structural finding:** MID Server living under `servicenow-platform/` rather than ITOM — combined with no sub-index in any area and a single monolithic ITOM `index.md` (>1 MB) — is a primary contributor to the navigation/drift problems below.

---

## Root-Cause Summary

The single root cause behind nearly every finding: **empty topic files return HTTP 200 with 0 bytes, not 404.** A retrieval tool sees a successful fetch that yielded no content, has no error to catch, and improvises — paginating the oversized index, guessing filenames, hopping branches, and ultimately falling back to non-authoritative (Community) content with no visible provenance signal. ~18 empty files were confirmed across the five areas; no *genuine* broken cross-reference was found in any bundle.

---

## Suite 1 — Service Mapping

- **SM-1 file count:** Service Mapping lives at `it-operations-management/service-mapping/`; no separate sub-index.
- **SM-2 Discovery boundary (Code):** PASS — SM→Discovery cross-references resolve; no genuine broken cross-bundle link.
- **SM-3 canonical_url (Code):** PASS — present and correct on populated topic pages sampled.
- **SM-4 pagination (Desktop):** FLAG — empty SM files (`prerequisites-service-mapping.md`, `t_DefineNewBusinessService.md`, `r_EntryPointsforBizSvcDef.md`, `map-application-suggestion.md`, `check-service-mapping-readiness-for-mapping.md`) triggered index navigation → path-guessing → Community fallback. The two "404s" seen (`c_TopDownDiscovery.md`, `c_SMMapping.md`) were *guessed* paths — repo-wide code search returns zero references — not broken doc links.

## Suite 2 — MID Server

- **MS-1 distribution (Code):** `bundle-routing` — MID Server has a full ~60-file directory at `servicenow-platform/mid-server/`, not under ITOM. Real risk is content split across two top-level bundles with no sub-index.
- **MS-2 platform reference (Code):** FLAG — `r_MIDServerSystemRequirements.md` (primary OS/hardware reference) is **0 bytes**; the direct answer is unavailable from the mirror.
- **MS-3 empty sweep (Code):** FLAG — 8 confirmed empties incl. cluster config, install prereqs, system methods, upgrade, troubleshooting.
- **MS-4 pagination (Desktop):** FLAG (worst observed) — 40+ fetches across `servicenow-platform` (>1 MB) and `platform-administration` (~900 KB) indexes, silent branch-hop (australia→yokohama→xanadu, all empty), then a **100% Community-sourced answer framed as official docs** — provenance blur, no mirror answer produced.
- **MS-5 canonical_url (Code):** PASS — present on populated pages (e.g. `mid-server-landing.md`).

## Suite 3 — Agent Client Collector

- **ACC-1 file count (Code):** Lives at `it-operations-management/agent-client-collector/`; no sub-directories.
- **ACC-2 empty sweep (Code):** FLAG — `acc-installation.md` (parent install concept) is 0 bytes; install content survives in `acc-endpoint-deployment.md` + `acc-install-*`, so the prompt remains answerable.
- **ACC-3 multi-hop (Code):** PASS — ACC→MID Server metrics flow resolves.
- **ACC-4 canonical_url (Code):** PASS — present (`acc-endpoint-deployment.md`).
- **ACC-5 pagination (Desktop):** PASS — under threshold, mirror-cited.

## Suite 4 — Event Management

- **EM-1 file count (Code):** Lives at `it-operations-management/event-management/`; no sub-directories.
- **EM-2 alert rules multi-hop (Code):** FLAG — `create-alert-management-rule.md` (the step-by-step "how") is 0 bytes; concept page `alert-management-rule.md` (9.9 KB) covers the *what*, not the *how*.
- **EM-3 connector empty sweep (Code):** FLAG — `alert-filter-aggregated.md` is 0 bytes.
- **EM-4 canonical_url (Code):** PASS — present (`alert-management-rule.md`).
- **EM-5 pagination (Desktop):** FLAG (recovered) — hit empty `c_ServiceAnalyticsOverview.md`, paginated the ITOM index across several offsets, but recovered and produced a verifiable mirror answer.

## Suite 5 — Health Log Analytics

- **HLA-1 file count (Code):** Lives at `it-operations-management/health-log-analytics/`; no sub-directories.
- **HLA-2 empty sweep (Code):** FLAG — `hla-custom-alert-rules.md` is 0 bytes; anomaly/alert content present elsewhere, so prompt remains answerable.
- **HLA-3 multi-hop HLA→EM (Code):** FLAG — `missing-xref`: the HLA→Event Management alert flow (second major cross-bundle boundary) is described conceptually only; there is no navigable link to follow into the EM bundle.
- **HLA-4 canonical_url (Code):** PASS — present (`hla-landing-page.md`).
- **HLA-5 pagination (Desktop):** PASS — under threshold.

---

## Findings Log

| ID | Bundle | Surface | Test | Finding type | Description | Severity |
|---|---|---|---|---|---|---|
| SM-F1 | Service Mapping | Desktop | SM quick search | `empty-file` | `prerequisites-service-mapping.md` — 0 bytes | Medium |
| SM-F2 | Service Mapping | Desktop | SM quick search | `empty-file` | `t_DefineNewBusinessService.md` — 0 bytes | High |
| SM-F3 | Service Mapping | Desktop | SM quick search | `empty-file` | `r_EntryPointsforBizSvcDef.md` — 0 bytes; primary entry point attributes reference — direct answer to query was unavailable | High |
| SM-F4 | Service Mapping | Desktop | SM quick search | `empty-file` | `map-application-suggestion.md` — 0 bytes | Medium |
| SM-F5 | Service Mapping | Desktop | SM quick search | `empty-file` | `check-service-mapping-readiness-for-mapping.md` — 0 bytes | Medium |
| SM-F6 | Service Mapping | Desktop | SM quick search | `path-guess` | `c_TopDownDiscovery.md` — 404. CORRECTED 2026-06-24: repo-wide GitHub code search returns 0 references to this filename — nothing links to it. This was a Desktop *guessed* path after hitting the empty SM files, not a genuine broken doc link (same self-inflicted pattern as MID Server) | Low |
| SM-F7 | Service Mapping | Desktop | SM quick search | `path-guess` | `c_SMMapping.md` — 404. CORRECTED 2026-06-24: repo-wide GitHub code search returns 0 references — not a genuine broken doc link; Desktop guessed the path after the empty-file fallback | Low |
| SM-F8 | Service Mapping | Desktop | SM quick search | `monolithic-file` | ITOM index required 10+ paginated fetches (offsets spanning 0–1,100,000) before locating Service Mapping content | High |
| SM-F9 | Service Mapping | Desktop | SM quick search | `retrieval-drift` | Query shifted sources mid-run: index navigation → direct path guessing → Community fallback → mirror retry; query interrupted before completing | High |
| MS-F1 | MID Server | Code | MID quick search | `bundle-routing` | MID Server has a full dedicated directory (~60 files) at `servicenow-platform/mid-server/`, NOT under `it-operations-management/`. Script's `no-dedicated-directory` assumption is incorrect; real risk is content split across two top-level bundles | Medium |
| MS-F2 | MID Server | Code | MID quick search | `empty-file` | `servicenow-platform/mid-server/r_MIDServerSystemRequirements.md` — 0 bytes (HTTP 200). Primary OS/hardware requirements reference — direct answer to query unavailable from mirror | High |
| MS-F3 | MID Server | Code | MID quick search | `empty-file` | `servicenow-platform/mid-server/t_ConfigureAMIDServerCluster.md` — 0 bytes. Cluster high-availability configuration procedure — direct answer to query unavailable from mirror | High |
| MS-F4 | MID Server | Code | MID quick search | `empty-file` | `servicenow-platform/mid-server/mid-server-install-prereqs.md` — 0 bytes | High |
| MS-F5 | MID Server | Code | MID quick search | `empty-file` | `servicenow-platform/mid-server/c_MIDServerConnectionPrerequisites.md` — 0 bytes | Medium |
| MS-F6 | MID Server | Code | MID quick search | `empty-file` | `servicenow-platform/mid-server/r_MIDSystemMethods.md` — 0 bytes | Medium |
| ACC-F1 | Agent Client Collector | Code | ACC quick search | `empty-file` | `agent-client-collector/acc-installation.md` — 0 bytes (parent install concept page; install content exists in `acc-endpoint-deployment.md` + `acc-install-*`, so prompt still answerable) | Medium |
| EM-F1 | Event Management | Code | EM quick search | `empty-file` | `event-management/create-alert-management-rule.md` — 0 bytes. Step-by-step procedure for configuring alert rules — directly answers "how are rules configured"; concept file `alert-management-rule.md` (9.9KB) covers the what but not the how | High |
| EM-F2 | Event Management | Code | EM quick search | `empty-file` | `event-management/alert-filter-aggregated.md` — 0 bytes | Medium |
| HLA-F1 | HLA | Code | HLA quick search | `empty-file` | `health-log-analytics/hla-custom-alert-rules.md` — 0 bytes. Anomaly detection + alert generation content present elsewhere, so prompt still answerable | Medium |
| HLA-F2 | HLA | Code | HLA quick search | `missing-xref` | No navigable cross-bundle link from HLA into `event-management/`. The HLA→Event Management alert flow (second major cross-bundle boundary) is described conceptually only — nothing to follow into the EM bundle | Medium |
| MS-F7 | MID Server | Desktop | MS-4 / MID quick search | `xref-broken` | `servicenow-platform/mid-server/c_MIDServerOverview.md` — 404 (Desktop transcript + screenshot). NOTE: audit of all 8 real outbound links in the populated MID Server pages found **0 genuine 404s**. The 404 cascade Desktop showed was self-inflicted path-guessing after hitting empty files, not broken doc links. Root cause is empty-file + no-sub-index, not xref breakage | High |
| MS-F11 | MID Server | Code | Broken-ref audit | `empty-file` | Additional 0-byte files: `c_MIDServerConfiguration.md` (probe), plus `c_UpgradeAndTestMIDServer.md` and `r_MIDServerTroubleshooting.md` reached via real links from populated pages. Brings confirmed MID Server empties to 8. Key insight: 0-byte files return HTTP 200 — no error signal — so a fetcher treats them as success and improvises; worse than a clean 404 | High |
| EM-F3 | Event Management | Desktop | EM-5 / EM quick search | `empty-file` | `event-management/c_ServiceAnalyticsOverview.md` — 0 bytes (HTTP 200, verified). Desktop hit it, recovered via alternate populated files | Medium |
| EM-F4 | Event Management | Desktop | EM-5 / EM quick search | `excessive-pagination` | Desktop paginated the ITOM index across several offset jumps to locate correlation docs. Moderate (not MID-scale); recovered and produced a verifiable mirror answer. Symptom of the monolithic ITOM index | Low |
| MS-F8 | MID Server | Desktop | MS-4 / MID quick search | `monolithic-file` | Desktop paginated the `servicenow-platform` index (>1,000,000 chars) and the `platform-administration` index (~900K) without ever landing on a MID Server section. MID Server equivalent of SM-F8 | High |
| MS-F9 | MID Server | Desktop | MS-4 / MID quick search | `retrieval-drift` | Silent branch-hop australia → yokohama → xanadu (all empty), then fallback to 100% Community-sourced content. Final answer framed community claims as "from official docs, as quoted in community" — provenance blur with no user-visible signal; source-integrity risk | High |
| MS-F10 | MID Server | Desktop | MS-4 / MID quick search | `excessive-pagination` | 40+ fetches across multiple branches/indexes; very long runtime; no mirror answer produced. Worst pagination/time result observed across all bundles | High |

**Finding types:**
- `empty-file` — file exists, zero bytes (returns HTTP 200 — no error signal)
- `stub-file` — file exists, under 200 bytes of body content
- `no-canonical-url` — canonical_url absent from frontmatter
- `monolithic-file` — excessive pagination in Desktop (>3 min / >5 fetches)
- `xref-broken` — cross-reference returns 404
- `xref-cross-bundle` — 404 on a link that crosses bundle boundaries
- `oversized-index` — bundle index >500KB
- `no-dedicated-directory` — topic has no sub-directory; docs distributed across parent bundle
- `retrieval-drift` — query shifted source mid-run (mirror → Community → mirror retry); final answer has mixed provenance with no user-visible signal
- `bundle-routing` — topic lives in an unexpected top-level bundle, or is split across bundles; index/structure assumption was wrong
- `missing-xref` — expected cross-reference is absent (not broken); no navigable link where one should exist, esp. across a bundle boundary
- `excessive-pagination` — runner makes many fetches across indexes/branches without producing a mirror answer
- `path-guess` — a 404 caused by the runner guessing a filename (no doc actually links to it); a downstream symptom of empty-file fallback, not a broken doc link

---

## Pass / Fail Summary

| Test | Bundle | Runner | Result | Finding IDs |
|---|---|---|---|---|
| Pre-Flight | All five | Code | Located — MID Server mis-bundled | MS-F1 |
| SM-1 | Service Mapping | Code | Done | — |
| SM-2 | Service Mapping | Code | PASS | — |
| SM-3 | Service Mapping | Code | PASS (canonical_url present) | — |
| SM-4 | Service Mapping | Desktop | FLAG | SM-F1–F9 |
| MS-1 | MID Server | Code | FLAG (bundle-routing) | MS-F1 |
| MS-2 | MID Server | Code | FLAG (empty reference) | MS-F2 |
| MS-3 | MID Server | Code | FLAG (8 empties) | MS-F3–F6, F11 |
| MS-4 | MID Server | Desktop | FLAG (worst case) | MS-F7–F10 |
| MS-5 | MID Server | Code | PASS (canonical_url present) | — |
| ACC-1 | Agent Client Collector | Code | Done | — |
| ACC-2 | Agent Client Collector | Code | FLAG (1 empty) | ACC-F1 |
| ACC-3 | Agent Client Collector | Code | PASS | — |
| ACC-4 | Agent Client Collector | Code | PASS (canonical_url present) | — |
| ACC-5 | Agent Client Collector | Desktop | PASS | — |
| EM-1 | Event Management | Code | Done | — |
| EM-2 | Event Management | Code | FLAG (empty "how" page) | EM-F1 |
| EM-3 | Event Management | Code | FLAG (1 empty) | EM-F2 |
| EM-4 | Event Management | Code | PASS (canonical_url present) | — |
| EM-5 | Event Management | Desktop | FLAG (recovered) | EM-F3, EM-F4 |
| HLA-1 | HLA | Code | Done | — |
| HLA-2 | HLA | Code | FLAG (1 empty) | HLA-F1 |
| HLA-3 | HLA | Code | FLAG (missing-xref) | HLA-F2 |
| HLA-4 | HLA | Code | PASS (canonical_url present) | — |
| HLA-5 | HLA | Desktop | PASS | — |
</content>
