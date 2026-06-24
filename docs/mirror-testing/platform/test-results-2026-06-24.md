# Platform (servicenow-platform) Mirror Test Results

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Branch:** `australia`
**Mirror:** ServiceNow/ServiceNowDocs (GitHub)
**Bundle:** `markdown/servicenow-platform/`
**Surfaces:** Claude Code — structural sweep COMPLETE · `/servicenow_rag` prompt tests COMPLETE · Claude Desktop — PENDING

This assessment applies the ITOM/ITAM/ITSM mirror-testing method to the **`servicenow-platform`** bundle — the single largest bundle in the mirror (3,059 `.md` files), and the home of CMDB, CSDM, Service Catalog, Knowledge Management, and MID Server. All Code-side findings below were verified live against `raw.githubusercontent.com` on June 24, 2026.

**Prompt-test headline (`/servicenow_rag`, Code):** 5 area prompts run — **1 PASS, 4 FLAG.** The empty files cluster precisely on high-value conceptual and how-to pages, so routine questions land on blank pages and the mirror cannot fully answer. Per-area results are in each suite below and summarized in the Pass/Fail table.

---

## Pre-Flight — Bundle Location & Structure

**Result: FLAG — major bundle-routing surprise + oversized index.**

`servicenow-platform` is a catch-all bundle. Several capabilities a practitioner would expect to find under their own top-level bundle live **only** here, with no dedicated bundle to route a topic-scoped query:

| Capability | Expected location | Actual location |
|---|---|---|
| CMDB | a `cmdb/` bundle | `servicenow-platform/configuration-management-database-cmdb/` |
| CSDM | a `csdm/` bundle | `servicenow-platform/common-service-data-model-csdm/` |
| Service Catalog | a `service-catalog/` bundle | `servicenow-platform/service-catalog/` |
| Knowledge Management | a `knowledge/` bundle | `servicenow-platform/knowledge-management/` |
| MID Server | `it-operations-management/` | `servicenow-platform/mid-server/` |

A repo-wide check confirms **no top-level `cmdb`, `csdm`, `service-catalog`, or `knowledge` bundle exists** — they are reachable only through the `servicenow-platform` index. This is the same `bundle-routing` failure mode first seen with MID Server in the ITOM assessment, but far broader: the platform's most-queried data-model topics are all buried in one bundle.

**Oversized index:** `servicenow-platform/index.md` is **1,213 KB** (`oversized-index`, >500 KB) — the single largest file in the bundle by far (next largest is 74 KB). It is also the index Claude Desktop paginated 40+ times during the ITOM MID Server run. With no sub-indexes, a query that lands here must page a 1.2 MB file to navigate.

---

## Bundle-Wide Empty-File Sweep

Full sweep of `servicenow-platform/` (every `.md`, sized via the GitHub git tree).

**Headline: 873 of 3,059 files (28.5%) are 0 bytes**, all HTTP 200, zero stubs (no file 1–199 bytes). Consistent with ITAM (28%) and ITSM (32%); the largest empty count in absolute terms of any bundle assessed.

| Sub-dir | .md files | Empty (0-byte) | % empty |
|---|---:|---:|---:|
| (bundle-root loose files) | 376 | 188 | 50% |
| knowledge-management | 290 | 100 | 34% |
| configuration-management-database-cmdb | 407 | 98 | 24% |
| service-catalog | 261 | 88 | 33% |
| service-graph-connectors | 222 | 72 | 32% |
| mid-server | 85 | 38 | 44% |
| password-reset | 101 | 36 | 35% |
| common-service-data-model-csdm | 59 | 34 | **57%** |
| document-management-services | 144 | 24 | 16% |
| dependency-views | 27 | 19 | **70%** |
| multi-instance-framework-hermes | 43 | 19 | 44% |
| now-assist-for-configuration-management-database-cmdb | 28 | 16 | 57% |
| cmdb-ci-class-models | 21 | 12 | 57% |
| (other sub-dirs) | ~995 | 129 | — |
| **TOTAL** | **3,059** | **873** | **28.5%** |

**The CMDB/CSDM family is the worst-hit cluster.** CSDM (57%), CMDB CI class models (57%), Now Assist for CMDB (57%), and Dependency Views (70%) are the most-hollowed sub-dirs in the bundle — directly impacting CMDB/CSDM advisory work.

---

## Root-Cause Confirmation

Empties return **HTTP 200 with 0 bytes** — no error signal. Verified on samples spanning the bundle:

| File | HTTP | Bytes |
|---|---|---|
| common-service-data-model-csdm/csdm-conceptual-model.md | 200 | 0 |
| configuration-management-database-cmdb/application-services.md | 200 | 0 |
| cmdb-ci-class-models/cmdb-ci-class-models-avi-lb.md | 200 | 0 |
| service-catalog/lookup-select-box.md | 200 | 0 |
| add-questionbank-for-survey.md (bundle root) | 200 | 0 |

An AI retrieval layer sees a successful fetch of an empty page and improvises — paginating the 1.2 MB index, guessing filenames, or falling back to non-authoritative content. Same failure mode as ITOM/ITAM/ITSM, largest blast radius yet.

---

## Suite 1 — CMDB (`configuration-management-database-cmdb`)

- **CMDB-1 file count:** 407 files (largest sub-dir).
- **CMDB-2 empty/stub sweep:** 98 empty (24%). High-impact empties include `application-services.md` (the application-service concept page), `ci-relationships.md`, `best-practices-id-reconcile.md` (identification & reconciliation best practices), `app-service-map-base-system.md`.
- **CMDB-3 canonical_url:** present & correct on populated samples. No finding.
- **CMDB-4 (`/servicenow_rag`, Code):** **PASS (empty-file hazard).** Prompt: "How does CMDB identification and reconciliation decide whether to update or create a CI, and what are the best practices?" The umbrella page `c_CMDBIdentifyandReconcile.md` (8.2 KB) and its next-hops `exploring-ire.md` (4.9 KB), `configuring-ire.md` (5.5 KB), `properties-id-reconciliation.md` (29 KB) are populated and answer the question. **But** the directly-named `best-practices-id-reconcile.md`, `r_ReconciliationRulesPrinciples.md`, `c_IdentificationRules.md`, and `create-reconciliation-rule.md` are all 0 bytes — a name-first grep lands on a blank page. *Desktop: PENDING.*

## Suite 2 — CSDM & CI Class Models

- **CSDM-1 file count:** CSDM 59 files; CMDB CI class models 21 files; Now Assist for CMDB 28 files.
- **CSDM-2 empty/stub sweep:** CSDM **57% empty (34/59)**, class models **57% (12/21)**, Now Assist for CMDB **57% (16/28)**. The foundational `csdm-conceptual-model.md` is 0 bytes, as are `ci-relationships.md`, `cmdb-asset-CI-IBI-sync-options.md`, `csdm-content-frame-using.md`, and `cmdb-ci-class-models-extend.md` (how to extend CI class models). A reader landing on the CSDM overview gets an empty page.
- **CSDM-3 canonical_url:** present & correct on populated CSDM samples (`build-domain.md`, `csdm-dynamic-ci-groups-by-service.md`). No finding.
- **CSDM-4 (`/servicenow_rag`, Code):** **FLAG (worst of the 5).** Prompt: "Explain the CSDM conceptual model and how its domains (Foundation, Design, Manage Technical Services, Sell/Consume) relate." The foundational `csdm-conceptual-model.md` is 0 bytes, and **3 of the 4 named domains are empty** — `foundation-domain.md`, `design-domain.md`, `manage-tech-servs-domain.md` (only `sell-consume-domain.md` 8.5 KB, `build-domain.md` 4.9 KB, `manage-business-services-domain.md` survive). The core of the question lands on blank pages. *Desktop: PENDING.*

## Suite 3 — Service Catalog

- **SC-1 file count:** 261 files.
- **SC-2 empty/stub sweep:** 88 empty (33%). Portal/employee-center how-to pages heavily affected: `access-categories-portal.md`, `add-to-cart-portal.md`, `add-to-wishlist-portal.md`, `add-to-cart-ec.md`.
- **SC-3 canonical_url:** present on populated samples. No finding.
- **SC-4 (`/servicenow_rag`, Code):** **FLAG (partial).** Prompt: "How is a Service Catalog item ordered through the Service Portal and Employee Center, and how does the cart/checkout flow work?" The **end-user ordering how-tos are empty** — `add-to-cart-portal.md`, `add-to-cart-ec.md`, `order-item.md`, `request-cat-item-portal.md`, `c_RequestingAServiceCatalogItem.md`. The **admin/config side survives** — `t_ConfigureCartLayout.md` (10.8 KB), `c_EnableATwoStepCheckout.md`, `t_OrderProcess.md`, `request-cat-item-ec.md`. Answerable for configuration; the user-journey walkthrough hits blanks. *Desktop: PENDING.*

## Suite 4 — Knowledge Management

- **KM-1 file count:** 290 files.
- **KM-2 empty/stub sweep:** 100 empty (34%) — the single largest empty count of any named sub-dir. Affected: `access-articles-now-mobile.md`, `actionable-knowledge-feedback.md`, `analyze-knowledge-gaps-demand-insights.md`.
- **KM-3 canonical_url:** present on populated samples. No finding.
- **KM-4 (`/servicenow_rag`, Code):** **FLAG (partial).** Prompt: "How does Knowledge Management handle article lifecycle, versioning, and approval publishing?" The **concept/overview pages are empty** — `article-versioning.md`, `knowledge-article-states.md`, `r_KnowledgeWorkflows.md`, `publish-knowledge-article-workspace.md`, `schedule-article-publishing.md`. The **granular task how-tos survive** — `upload-new-version-article.md`, `approve-article-in-review.md`, `compare-two-article-versions.md`, `republish-retired-article.md`. The lifecycle/state-model overview lands blank; tasks are answerable piecemeal. *Desktop: PENDING.*

## Suite 5 — MID Server (cross-reference to ITOM)

- **MS-1 location:** `servicenow-platform/mid-server/` (85 files) — **not** under `it-operations-management/`, confirming the ITOM `bundle-routing` finding.
- **MS-2 empty/stub sweep:** **38 empty (44%)** — note the ITOM assessment found only 8 empties via incidental, targeted testing; the exhaustive sweep shows the true MID Server gap is ~5× larger. Includes `c_MIDServerConfiguration.md`, `c_MIDServerConnectionPrerequisites.md`, `c_MIDServerDashboard.md`, `add-ssl-certificates.md`.
- **MS-3 canonical_url:** present on populated pages (`mid-server-landing.md`). No finding.
- **MS-4 (Desktop):** Covered in ITOM assessment (worst-case pagination/drift) — see `itom/test-results-2026-06-24.md`.

## Suite 6 — Dependency Views & Service Graph Connectors

- **DV-1 dependency-views:** 27 files, **19 empty (70%)** — the highest empty rate in the bundle. `logical-grouping.md`, `create-predefined-filter.md`, `condition-script-parameters.md` all 0 bytes.
- **DV-2 service-graph-connectors:** 222 files, 72 empty (32%). Data-mapping reference pages affected (`cmdb-data-mapping-infoblox.md`, `sgc-data-mapping-tanium-endpoints.md`).
- **DV-3 canonical_url:** present on populated samples. No finding.
- **DV-4 (`/servicenow_rag`, Code):** **FLAG.** Prompt: "How do you build a dependency view (BSM map) and control which CIs and relationships appear?" The concept pages survive — `c_NextGenBSMMaps.md` (4 KB), `c_BusinesssServiceManagementMaps.md` (5.6 KB), `properties-dependency-views.md` (6.9 KB), `r_NGBSMMenus.md` (7 KB) — but **every build/control task page is empty**: `t_AccessNGBSM.md`, `t_CreateMapScript.md`, `t_FilterViewNGBSMMap.md`, `t_ChangeLayoutNGBSMMap.md`, `t_CreateModifyNGBSMMapRelatedItems.md`, `create-predefined-filter.md`, `logical-grouping.md`, `p_UseNGBSM.md`. The actionable half of the question (how to build/control) has no surviving page. *Desktop: PENDING.*

---

## Findings Log (Code side)

| ID | Sub-area | Test | Finding type | Description | Severity |
|---|---|---|---|---|---|
| F1 | Bundle-wide | Pre-flight | empty-file (systemic) | 873/3,059 files (28.5%) are 0-byte, HTTP 200 — no error signal | High |
| F2 | Bundle | Pre-flight | bundle-routing | CMDB, CSDM, Service Catalog, Knowledge, MID Server have no top-level bundle — reachable only via `servicenow-platform` index | High |
| F3 | Bundle | Pre-flight | oversized-index | `index.md` 1,213 KB; no sub-indexes; paginated 40+ times in ITOM MID Server run | High |
| F4 | CSDM / class models | CSDM-2 | empty-file (cluster) | CSDM 57%, CI class models 57%, Now Assist for CMDB 57% empty; `csdm-conceptual-model.md` (foundational) is 0 bytes | High |
| F5 | CMDB | CMDB-2 | empty-file | `application-services.md`, `ci-relationships.md`, `best-practices-id-reconcile.md` empty | High |
| F6 | Dependency Views | DV-1 | empty-file (cluster) | 70% empty — highest rate in the bundle | Med |
| F7 | Knowledge Mgmt | KM-2 | empty-file | 100 empty (34%) — largest empty count of any named sub-dir | Med |
| F8 | Service Catalog | SC-2 | empty-file | 88 empty (33%); portal/EC ordering how-tos affected | Med |
| F9 | MID Server | MS-2 | empty-file | 38 empty (44%) — ITOM incidental test undercounted (8) by ~5× | Med |
| — | All sampled | *-3 | (no finding) | canonical_url present & correct — 26/26 populated files sampled across the bundle | — |

---

## Pass / Fail Summary (Code side)

| Test | Sub-area | Result |
|---|---|---|
| Pre-Flight | Bundle location/structure | FLAG — bundle-routing + 1.2MB index |
| CMDB-1/2 | CMDB | FLAG — 24% empty incl. core concept pages |
| CMDB-3 | CMDB | PASS — canonical_url ok |
| CMDB-4 | CMDB | **PASS** (`/servicenow_rag`) — hub answers; named pages empty. Desktop pending |
| CSDM-1/2 | CSDM | FLAG — 57% empty incl. conceptual model |
| CSDM-3 | CSDM | PASS — canonical_url ok |
| CSDM-4 | CSDM | **FLAG** (`/servicenow_rag`) — model + 3/4 domains empty. Desktop pending |
| SC-1/2 | Service Catalog | FLAG — 33% empty |
| SC-3 | Service Catalog | PASS — canonical_url ok |
| SC-4 | Service Catalog | **FLAG** (`/servicenow_rag`) — user ordering empty, config survives. Desktop pending |
| KM-1/2 | Knowledge | FLAG — 34% empty (100 files) |
| KM-3 | Knowledge | PASS — canonical_url ok |
| KM-4 | Knowledge | **FLAG** (`/servicenow_rag`) — lifecycle concepts empty, tasks survive. Desktop pending |
| MS-1/2 | MID Server | FLAG — 44% empty, mis-bundled |
| MS-3 | MID Server | PASS — canonical_url ok |
| DV-1/2 | Dependency Views / SGC | FLAG — 70% / 32% empty |
| DV-4 | Dependency Views | **FLAG** (`/servicenow_rag`) — concepts survive, all task pages empty. Desktop pending |

---

> Counts are point-in-time on `australia`, June 24, 2026. The ServiceNowDocs build team has acknowledged the empty-file defect as a build bug and is republishing; re-sweep after their fix to capture the "after" baseline.
