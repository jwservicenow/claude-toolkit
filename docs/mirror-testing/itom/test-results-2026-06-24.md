# ITOM Gap Testing — Structured Test Script

**Prepared by:** Jim Wells, ServiceNow ITOM Practice  
**Date:** June 24, 2026  
**Branch:** `australia`  
**Surfaces:** Claude Code · Claude Desktop  
**Goal:** Cover ITOM areas missed in initial testing (Service Mapping, MID Server, Agent Client Collector, Event Management, HLA). Results feed into the mirror admin email before it is sent.

---

## Testing Paths

Two runners. Every test is labeled with who executes it.

**Path A — Claude Code** `(Code)`  
Runs via `/servicenow_rag` in this Claude Code session. Jim triggers each test by typing `/servicenow_rag <prompt>`. Results appear directly in this session and are recorded here.

**Path B — Claude Desktop** `(Desktop)`  
Jim runs the prompt in Claude Desktop using the ServiceNow project instructions. After getting a response, paste the full result back into this Claude Code session. Each Desktop test includes a **Paste result here:** block for that output.

---

## Quick Search Prompts

One per bundle. Run each via `/servicenow_rag <prompt>` as a fast first-pass before the full suite. Results count toward the findings log.

| Bundle | Prompt |
|---|---|
| Service Mapping | How does Service Mapping discover and map the components of an application service, and what is the role of entry points in that process? |
| MID Server | What are the MID Server hardware and OS requirements, and how do you configure a MID Server cluster for high availability? |
| Agent Client Collector | How is the Agent Client Collector deployed to a monitored host, and how does it communicate back to the MID Server? |
| Event Management | How are alert aggregation rules configured in ServiceNow Event Management, and what fields control deduplication and correlation? |
| HLA | How does Health Log Analytics detect anomalies in log data and generate alerts that flow into Event Management? |

---

## Pre-Flight — Confirm Bundle Availability

`(Code — /servicenow_rag)`

```
Fetch https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/llms.txt
Grep the output for each of the following bundle names and record the index path:
  - Service Mapping
  - MID Server
  - Agent Client Collector
  - Event Management
  - Health Log Analytics
```

| Bundle | In llms.txt | Index path | Notes |
|---|---|---|---|
| Service Mapping | | | |
| MID Server | | | |
| Agent Client Collector | | | |
| Event Management | | | |
| Health Log Analytics | | | |

---

## Suite 1 — Service Mapping

### Test SM-1 · Sub-Directory File Count `(Code — /servicenow_rag)`

> **Structure note:** Service Mapping has no separate bundle index. All files live under `it-operations-management/service-mapping/` within the single ITOM index.md. A duplicate path also exists at `product/service-mapping/` — note whether both directories are referenced.

```
List all files under:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/service-mapping/
Also check whether any files exist under:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/product/service-mapping/
Report: total file count per directory, whether the two paths contain the same or different files.
```

**Record:** File count (service-mapping/) _____ · File count (product/service-mapping/) _____ · Duplicate content: Y / N / Unknown

---

### Test SM-2 · Cross-Reference Density — Discovery Boundary `(Code — /servicenow_rag)`

```
Using the Service Mapping bundle on the australia branch:
How does Service Mapping use Discovery data to build application services?
Follow any cross-reference links encountered, including any that lead into the Discovery bundle.
Report: files fetched, whether cross-bundle links resolved or returned 404, and the answer.
```

**What we're checking:** SM → Discovery is the highest-risk cross-bundle xref boundary in ITOM.  
**Pass:** Cross-references resolve including Discovery bundle links  
**Fail / flag:** 404 on any cross-reference, especially cross-bundle

---

### Test SM-3 · canonical_url Spot-Check `(Code — /servicenow_rag)`

```
From the Service Mapping bundle index, fetch 5 topic files distributed across the bundle.
For each, report: filename, canonical_url present (Y/N), URL value if present.
```

| File | canonical_url present | URL (if present) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

---

### Test SM-4 · Pagination Depth `(Desktop — Jim runs, paste result here)`

**Prompt to run in Claude Desktop:**
```
What are the entry point types available in Service Mapping, and how is each configured?
```

**Pass:** Under 3 minutes  
**Flag:** Over 3 minutes — record fetch count and time

**Paste result here:**
```
[paste Desktop response]
```

---

## Suite 2 — MID Server

### Test MS-1 · No Dedicated Directory — Distributed File Locations `(Code — /servicenow_rag)`

> **Structure note:** MID Server has no dedicated sub-directory. The closest root-level file is `it-operations-management/configure-a-mid-server.md`. MID Server content is otherwise distributed across `discovery/` and other ITOM sub-directories. This is itself a finding — flag as `no-dedicated-directory`.

```
Fetch:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/configure-a-mid-server.md
Report: file size in bytes, whether it contains links to other MID Server topic files, and whether those linked files resolve.
Also note: MID Server lacks a dedicated sub-directory. Content is spread across discovery/ and ITOM root. Log this as a structural finding.
```

**Record:** configure-a-mid-server.md size _____ bytes · Cross-links present: Y / N · Cross-links resolve: Y / N  
**Finding to log:** `no-dedicated-directory` — MID Server docs distributed, no sub-directory or sub-index

---

### Test MS-2 · Supported Platform Reference File Size `(Code — /servicenow_rag)`

```
Using the MID Server bundle on the australia branch:
What operating systems and versions are supported for MID Server installation?
Report: which file(s) were fetched, file size in bytes, and the answer.
```

**What we're checking:** Supported OS/platform reference — potential oversized file, high pagination risk.  
**Pass:** Answer returned, file size reported  
**Flag:** File over 500KB

---

### Test MS-3 · Empty / Stub File Sweep `(Code — /servicenow_rag)`

```
From the MID Server bundle index, fetch the topic files for:
  - MID Server extensions
  - MID Server upgrade
  - MID Server cluster configuration
Report content length for each. Flag any file under 200 bytes of body content.
```

---

### Test MS-4 · Pagination Depth — Supported Platforms `(Desktop — Jim runs, paste result here)`

**Prompt to run in Claude Desktop:**
```
What are all the supported operating systems and Java versions for MID Server in the current release?
```

**Pass:** Under 3 minutes  
**Flag:** Over 3 minutes — MID Server equivalent of r_SupportedApplications.md

**Paste result here:**
```
[paste Desktop response]
```

---

### Test MS-5 · canonical_url Spot-Check `(Code — /servicenow_rag)`

```
From the MID Server bundle index, fetch 5 topic files distributed across the bundle.
For each, report: filename, canonical_url present (Y/N), URL value if present.
```

| File | canonical_url present | URL (if present) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

---

## Suite 3 — Agent Client Collector

### Test ACC-1 · Sub-Directory File Count `(Code — /servicenow_rag)`

> **Structure note:** ACC has no separate bundle index. All files live under `it-operations-management/agent-client-collector/` within the single ITOM index.md.

```
List all files under:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/agent-client-collector/
Report: total file count and whether any sub-directories exist within it.
```

**Record:** File count _____ · Sub-directories present: Y / N

---

### Test ACC-2 · Empty / Stub File Sweep `(Code — /servicenow_rag)`

```
From the ACC bundle index, fetch topic files for:
  - ACC policy configuration
  - ACC extension installation
  - ACC metrics collection
Report content length for each. Flag any file under 200 bytes of body content.
```

**What we're checking:** ACC is the newest capability — highest likelihood of stub files across all ITOM bundles.

---

### Test ACC-3 · Multi-Hop Query `(Code — /servicenow_rag)`

```
Using the Agent Client Collector bundle on the australia branch:
How does ACC collect metrics and send them to the MID Server?
Follow any cross-reference links encountered.
Report: files fetched, cross-reference resolution status, and the answer.
```

---

### Test ACC-4 · canonical_url Spot-Check `(Code — /servicenow_rag)`

```
From the ACC bundle index, fetch 5 topic files distributed across the bundle.
For each, report: filename, canonical_url present (Y/N), URL value if present.
```

| File | canonical_url present | URL (if present) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

---

### Test ACC-5 · Pagination Depth `(Desktop — Jim runs, paste result here)`

**Prompt to run in Claude Desktop:**
```
What metrics and data types can the Agent Client Collector gather from a monitored host?
```

**Pass:** Under 3 minutes  
**Flag:** Over 3 minutes

**Paste result here:**
```
[paste Desktop response]
```

---

## Suite 4 — Event Management

### Test EM-1 · Sub-Directory File Count `(Code — /servicenow_rag)`

> **Structure note:** Event Management has no separate bundle index. All files live under `it-operations-management/event-management/` within the single ITOM index.md.

```
List all files under:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/event-management/
Report: total file count and whether any sub-directories exist within it.
```

**Record:** File count _____ · Sub-directories present: Y / N

---

### Test EM-2 · Multi-Hop Query — Alert Rules `(Code — /servicenow_rag)`

```
Using the Event Management bundle on the australia branch:
How are alert aggregation rules configured, and what fields drive alert deduplication?
Follow any cross-reference links encountered.
Report: files fetched, cross-reference resolution status, and the answer.
```

**What we're checking:** Alert rules reference connector and integration topics — high cross-reference surface.

---

### Test EM-3 · Empty / Stub File Sweep — Connector Topics `(Code — /servicenow_rag)`

```
From the Event Management bundle index, identify topic files related to connectors or integrations.
Fetch up to 8 such files and report content length for each.
Flag any file under 200 bytes of body content.
```

**What we're checking:** Connector-specific docs are the most likely stubs in Event Management.

---

### Test EM-4 · canonical_url Spot-Check `(Code — /servicenow_rag)`

```
From the Event Management bundle index, fetch 5 topic files distributed across the bundle.
For each, report: filename, canonical_url present (Y/N), URL value if present.
```

| File | canonical_url present | URL (if present) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

---

### Test EM-5 · Pagination Depth `(Desktop — Jim runs, paste result here)`

**Prompt to run in Claude Desktop:**
```
What event sources and connector types are supported in ServiceNow Event Management, and how is each configured?
```

**Pass:** Under 3 minutes  
**Flag:** Over 3 minutes — connector reference files are a strong pagination candidate

**Paste result here:**
```
[paste Desktop response]
```

---

## Suite 5 — Health Log Analytics (HLA)

### Test HLA-1 · Sub-Directory File Count `(Code — /servicenow_rag)`

> **Structure note:** HLA has no separate bundle index. All files live under `it-operations-management/health-log-analytics/` within the single ITOM index.md.

```
List all files under:
  https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/markdown/it-operations-management/health-log-analytics/
Report: total file count and whether any sub-directories exist within it.
```

**Record:** File count _____ · Sub-directories present: Y / N

---

### Test HLA-2 · Empty / Stub File Sweep `(Code — /servicenow_rag)`

```
From the HLA bundle index, fetch topic files for:
  - Log source configuration
  - HLA anomaly detection
  - HLA alert generation
Report content length for each. Flag any file under 200 bytes of body content.
```

**What we're checking:** HLA is sparsely documented relative to feature scope — highest empty-file risk after ACC.

---

### Test HLA-3 · Multi-Hop Query `(Code — /servicenow_rag)`

```
Using the Health Log Analytics bundle on the australia branch:
How does HLA generate alerts from log anomalies, and how do those alerts flow into Event Management?
Follow any cross-reference links encountered, including any that lead into the Event Management bundle.
Report: files fetched, cross-reference resolution (including cross-bundle), and the answer.
```

**What we're checking:** HLA → Event Management is the second major cross-bundle boundary after SM → Discovery.

---

### Test HLA-4 · canonical_url Spot-Check `(Code — /servicenow_rag)`

```
From the HLA bundle index, fetch 5 topic files distributed across the bundle.
For each, report: filename, canonical_url present (Y/N), URL value if present.
```

| File | canonical_url present | URL (if present) |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

---

### Test HLA-5 · Pagination Depth `(Desktop — Jim runs, paste result here)`

**Prompt to run in Claude Desktop:**
```
What log sources and data collection methods are supported by Health Log Analytics?
```

**Pass:** Under 3 minutes  
**Flag:** Over 3 minutes

**Paste result here:**
```
[paste Desktop response]
```

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
- `empty-file` — file exists, zero bytes
- `stub-file` — file exists, under 200 bytes of body content
- `no-canonical-url` — canonical_url absent from frontmatter
- `monolithic-file` — excessive pagination in Desktop (>3 min / >5 fetches)
- `xref-broken` — cross-reference returns 404
- `xref-relative` — relative path found on older branch
- `xref-cross-bundle` — 404 on a link that crosses bundle boundaries
- `oversized-index` — bundle index >500KB
- `no-dedicated-directory` — topic has no sub-directory; docs distributed across parent bundle
- `retrieval-drift` — query shifted source mid-run (mirror → Community → mirror retry); final answer has mixed provenance with no user-visible signal
- `bundle-routing` — topic lives in an unexpected top-level bundle, or is split across bundles; index/structure assumption was wrong
- `missing-xref` — expected cross-reference is absent (not broken); no navigable link where one should exist, esp. across a bundle boundary
- `excessive-pagination` — runner makes many fetches (here 40+) across indexes/branches without producing a mirror answer
- `path-guess` — a 404 caused by the runner guessing a filename (no doc actually links to it); a downstream symptom of empty-file fallback, not a broken doc link

---

## Pass / Fail Summary

| Test | Bundle | Runner | Result | Finding ID |
|---|---|---|---|---|
| SM-1 | Service Mapping | Code | | |
| SM-2 | Service Mapping | Code | | |
| SM-3 | Service Mapping | Code | | |
| SM-4 | Service Mapping | Desktop | | |
| MS-1 | MID Server | Code | FAIL — bundle in `servicenow-platform/`, not ITOM | MS-F1 |
| MS-2 | MID Server | Code | FAIL — requirements file 0 bytes | MS-F2 |
| MS-3 | MID Server | Code | FAIL — cluster/prereq files 0 bytes | MS-F3, MS-F4, MS-F5, MS-F6 |
| MS-4 | MID Server | Desktop | FAIL — empty files + 404s + branch-hop + 40+ fetches, no mirror answer; 100% Community fallback | MS-F7, MS-F8, MS-F9, MS-F10 |
| MS-5 | MID Server | Code | _not run — primary files empty_ | |
| ACC-1 | ACC | Code | PASS — 306-file dedicated dir, no sub-dirs | |
| ACC-2 | ACC | Code | FLAG — `acc-installation.md` 0 bytes | ACC-F1 |
| ACC-3 | ACC | Code | PASS — MID communication content present | |
| ACC-4 | ACC | Code | _not run — spot-check deferred_ | |
| ACC-5 | ACC | Desktop | PASS — fast, no branch-hop, mirror-sourced, all 7 cited files real & populated (verified). Positive control: healthy bundle → clean Desktop behavior | _none_ |
| EM-1 | Event Management | Code | PASS — 380-file dedicated dir | |
| EM-2 | Event Management | Code | PASS — concept/correlation content present | |
| EM-3 | Event Management | Code | FLAG — 2 empty files (1 High) | EM-F1, EM-F2 |
| EM-4 | Event Management | Code | _not run — spot-check deferred_ | |
| EM-5 | Event Management | Desktop | PASS w/ friction — accurate verifiable answer; routed around empty procedure file via populated alternates; moderate index pagination + 1 empty file hit | EM-F3, EM-F4 |
| HLA-1 | HLA | Code | PASS — 230-file dedicated dir | |
| HLA-2 | HLA | Code | FLAG — `hla-custom-alert-rules.md` 0 bytes | HLA-F1 |
| HLA-3 | HLA | Code | PASS on HLA side; FLAG — no xref into EM bundle | HLA-F2 |
| HLA-4 | HLA | Code | _not run — spot-check deferred_ | |
| HLA-5 | HLA | Desktop | PASS — fast, no branch-hop; all 5 cited HLA files real & populated (verified). Correct answer, BUT HLA→EM flow bridged via HLA-side inference + community, not a navigable mirror link — confirms HLA-F2 provenance gap on the cross-bundle boundary | HLA-F2 |
