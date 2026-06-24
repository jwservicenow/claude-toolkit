# ServiceNow GitHub Docs Mirror — AI Retrieval Findings & Recommendations

**Prepared by:** Jim Wells, ServiceNow ITOM Practice  
**Date:** June 24, 2026  
**Audience:** ServiceNow GitHub Docs Mirror Administrators

---

## Background

The [ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror was evaluated as a retrieval source for AI-assisted technical work. Because `docs.servicenow.com` is a JavaScript single-page application — meaning its content is not readable by AI tools — the GitHub mirror, which exposes plain-text Markdown via `raw.githubusercontent.com`, is the operative path for grounded, citable answers.

Testing was conducted against the `australia` branch using two surfaces:

- **Claude Code** — via direct `raw.githubusercontent.com` fetch with `gh api` tree search and temp-file navigation
- **Claude Desktop** — via a custom fetch MCP connector with project instructions

This round focused on the ITOM bundles — MID Server, Service Mapping, Agent Client Collector (ACC), Event Management, and Health Log Analytics (HLA). Each Desktop result was independently re-verified on the Code side: cited files were re-fetched to confirm they exist and are populated, and reported empties and 404s were re-tested for exact HTTP status. Findings are ordered by impact.

---

## What's Working Well

**The cross-reference fix is the standout win.** On `australia`, internal cross-references that previously used fragile relative paths now resolve to absolute `raw.githubusercontent.com` URLs and work correctly — a real improvement for multi-hop queries that span topic files.

**Agent Client Collector is the positive control.** ACC is a healthy bundle (~306-file dedicated directory). Asked how ACC is deployed and how it communicates back to the MID Server, both Claude Code and Claude Desktop returned fast, accurate, fully mirror-cited answers — no branch-hopping, no pagination spiral, every cited file verified real and populated. This is important: it proves the retrieval method and the mirror format are sound. The findings below are about specific bundle content health, not the approach.

---

## Findings (by impact)

### 1. Systemic Zero-Byte Files Returning HTTP 200 — *Critical (Both surfaces)*

Across the five ITOM areas tested, we confirmed **18 zero-byte topic files** — surfaced incidentally during normal queries, not via an exhaustive sweep, so the true count is almost certainly higher. Breakdown: MID Server 8, Service Mapping 5, Event Management 3, ACC 1, HLA 1. This is the same defect first reported in the Azure cloud discovery patterns file (`azure-cloud-discovery-patterns.md`), now confirmed to be systemic.

**Impact:** The core problem is not that the files are empty — it is that an empty file returns **HTTP 200, not 404**. To a retrieval tool this looks like a successful fetch that yielded no content. There is no error to catch and no signal to fall back, so the tool treats the gap as success and improvises (see Finding #2).

**Recommendation:** (a) Populate the empty files; and (b) as a safety net, have the mirror pipeline emit either a real 404 or a minimal stub-with-marker for any zero-byte file, so retrieval tools can detect the gap instead of silently improvising. A list of confirmed empties is available on request.

---

### 2. MID Server Bundle — Empty Core Files Trigger Runaway Path-Guessing — *Critical (Both surfaces)*

Asked for MID Server hardware/OS requirements and cluster high-availability configuration — a routine ITOM question — neither surface could answer from the mirror. The two files that directly answer it, `r_MIDServerSystemRequirements.md` and `t_ConfigureAMIDServerCluster.md`, are both zero bytes, as are six other MID Server files (install prereqs, connection prereqs, configuration, upgrade/test, troubleshooting, system methods).

**Impact:** Because the empty files return HTTP 200 (Finding #1), Claude Desktop treated them as successful, then began **guessing filenames** (a cascade of 404s on paths that don't exist), **hopping branches** (australia → yokohama → xanadu, all empty), paginating a >1MB index 40+ times, and ultimately answering **entirely from ServiceNow Community content, with portions not clearly distinguished from official documentation.** The resulting risk is provenance blur: a confident, well-formatted answer whose actual sourcing is non-authoritative (community forums), with no visible signal that the response has left the official docs. Two structural contributors: MID Server content lives under `servicenow-platform/mid-server/`, **not** under `it-operations-management/` where an ITOM query would look; and the directory has no sub-index to navigate from once content files are empty.

**Recommendation:** Populate the eight MID Server files for `australia` as a priority; confirm the bundle's location is discoverable from the ITOM index.

---

### 3. Service Mapping — Empty Files — *High (Desktop)*

Five Service Mapping files are zero bytes, including `r_EntryPointsforBizSvcDef.md` (the primary entry-point attributes reference) and `t_DefineNewBusinessService.md` (full paths in the Appendix).

**Impact:** Same pattern as MID Server — the empty files trigger index navigation, then path-guessing, then a Community fallback. (Note: two 404s observed during testing — `c_TopDownDiscovery.md`, `c_SMMapping.md` — were *guessed* paths, not broken doc links. A repo-wide code search confirms nothing references either filename. They are a downstream symptom of the empty-file fallback, not a separate defect.)

**Recommendation:** Populate the five empty Service Mapping files.

---

### 4. Monolithic ITOM Index — Confirmed Cross-Bundle Drift Trigger — *High (Both surfaces)*

The ITOM Visibility bundle is a single `index.md` of roughly 1.2MB with no sub-indexes; Service Mapping content sits past the ~1.1M-character offset.

**Impact:** This is no longer a minor nuisance — it was a direct contributor to the pagination and source-drift seen in both the MID Server and Event Management runs. Claude Desktop paginates the index repeatedly trying to locate a section, and that hunting is what tips it into path-guessing once it also hits an empty file.

**Recommendation:** Split the ITOM index into functional sub-indexes (MID Server, Discovery, Service Mapping, Agent Client Collector, Event Management, Health Log Analytics), or publish a lightweight summary index alongside the full one. This single change would shorten navigation and remove a major drift trigger across the whole bundle.

---

### 5. Missing Canonical URL Metadata — *High (Both surfaces)*

Many topic files lack a `canonical_url` field in their YAML frontmatter — the expected pointer back to the corresponding `docs.servicenow.com` page.

**Impact:** When the field is absent, citation logic falls back to constructing a URL from the file path — a fragile heuristic that occasionally produces incorrect links. The impact is sharper in Claude Desktop, which has no grep-based fallback; citation quality degrades more, with the model either omitting a citation or producing a guessed URL.

**Recommendation:** Backfill `canonical_url` across the corpus, or inject it in the mirror pipeline. Prioritize ITOM Visibility, CMDB/CSDM, and Service Mapping bundles first.

---

### 6. Missing Cross-Reference Where One Is Expected — *Medium (Both surfaces)*

For the Health Log Analytics → Event Management flow, HLA content is present and the answer was correct, but there is **no navigable link** from the HLA files into the Event Management bundle.

**Impact:** The model bridged the two via inference plus Community blogs rather than a doc link — so the exact cross-bundle boundary carries unofficial provenance even when the answer reads as fully sourced. This is the absence of an expected link, not a broken one.

**Recommendation:** Add explicit cross-bundle links at known hand-off points (HLA → Event Management; Service Mapping → Discovery) so the retrieval chain stays inside official content.

---

### 7. Broken Relative Cross-References / Empty Files on Older Branches — *Medium (Code)*

The relative-to-absolute link conversion completed on `australia` is likely not yet applied to `xanadu`, `yokohama`, or `zurich`. The MID Server branch-hopping in Finding #2 also confirmed the empty files are empty on those branches.

**Impact:** AI tools following cross-references on older branches hit 404s; the empty-file gaps persist across releases.

**Recommendation:** Apply the same conversion — and the empty-file population — to all actively supported release branches.

---

## Test Results

**Mirror Navigation Retest — PASSED**  
No new search primitives — same navigation path, better link following.

- `llms.txt` is unchanged — same bundle listing format
- No search API, embeddings, or `llms-full.txt` added
- Retrieval path is unchanged: `llms.txt` → bundle `index.md` → grep → fetch file

**Verification discipline**  
Every Desktop answer was cross-checked on the Code side. No confabulation was found in the ACC, EM, or HLA answers — all cited files were re-fetched and confirmed real and populated. The failures above are genuine mirror-content gaps, not model hallucinations.

---

## Priority Summary

| Priority | Finding | Surface |
|---|---|---|
| Critical | Systemic zero-byte files returning HTTP 200 (18 confirmed across 5 ITOM areas) | Both |
| Critical | MID Server empty core files → path-guessing, branch-hop, non-authoritative fallback (mixed provenance) | Both |
| High | Service Mapping empty files (5 files) | Desktop |
| High | Monolithic ITOM index (~1.2MB) — confirmed cross-bundle drift trigger | Both |
| High | Missing canonical URL metadata | Both |
| Medium | Missing expected cross-bundle links (HLA→EM, SM→Discovery) | Both |
| Medium | Broken relative cross-references / empty files on older branches | Code |

---

## Appendix — Confirmed Empty Files & Broken Targets

All paths are repo-relative under `markdown/`, on the **`australia`** branch, verified **June 24, 2026** against `raw.githubusercontent.com`. Each file below returns **HTTP 200 with 0 bytes**. This list was compiled from files encountered during normal queries — it is **not** an exhaustive sweep, so the true count is likely higher.

**Service Mapping — `it-operations-management/service-mapping/` (5)**
- `prerequisites-service-mapping.md`
- `t_DefineNewBusinessService.md`
- `r_EntryPointsforBizSvcDef.md`
- `map-application-suggestion.md`
- `check-service-mapping-readiness-for-mapping.md`

**MID Server — `servicenow-platform/mid-server/` (8)**
- `r_MIDServerSystemRequirements.md`
- `c_MIDServerConfiguration.md`
- `t_ConfigureAMIDServerCluster.md`
- `mid-server-install-prereqs.md`
- `c_MIDServerConnectionPrerequisites.md`
- `r_MIDSystemMethods.md`
- `c_UpgradeAndTestMIDServer.md`
- `r_MIDServerTroubleshooting.md`

**Event Management — `it-operations-management/event-management/` (3)**
- `create-alert-management-rule.md`
- `alert-filter-aggregated.md`
- `c_ServiceAnalyticsOverview.md`

**Agent Client Collector — `it-operations-management/agent-client-collector/` (1)**
- `acc-installation.md`

**Health Log Analytics — `it-operations-management/health-log-analytics/` (1)**
- `hla-custom-alert-rules.md`

**Total: 18 confirmed zero-byte files across 5 ITOM areas.**

**On broken links:** No genuine broken cross-reference was found in any tested bundle. The 404s observed during testing (`c_TopDownDiscovery.md`, `c_SMMapping.md` in Service Mapping; various MID Server paths) were filenames the AI *guessed* after hitting empty files — a repo-wide code search confirms nothing in the docs links to them. The single root cause across every finding is the empty-file-returns-HTTP-200 behavior.
