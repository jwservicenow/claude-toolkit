# ITSM Mirror Test Results — Code Side

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Branch:** `australia`
**Mirror:** ServiceNow/ServiceNowDocs (GitHub)
**Status:** Direct-fetch (Code) sweep COMPLETE · `/servicenow_rag` prompt tests COMPLETE · Claude Desktop PENDING

> All numbers below are from an **exhaustive file-size sweep** of each bundle and were verified live against `raw.githubusercontent.com`.

**Prompt-test headline (`/servicenow_rag`, Code):** 8 prompts run (2 per area) — **3 PASS (recoverable), 5 FLAG.** Verdicts and the populated/empty pages behind each are in the Prompt-Test Results section near the end; every empty and every "answerable" page was re-verified live (HTTP + bytes).

---

## Pre-Flight — Bundle Location & Structure

**Result: split bundling — two of four areas are NOT under ITSM.** Incident and Change live under the ITSM umbrella; Service Catalog and Knowledge live under `servicenow-platform/`. This is the ITSM analog of ITOM's mis-bundled MID Server.

| Area | Location | Files | Empty | % empty | Empties verified |
|---|---|---:|---:|---:|---|
| Incident Management | `it-service-management/incident-management/` | 133 | 17 | 13% | HTTP 200 / 0 bytes (all 17) |
| Change Management | `it-service-management/change-management/` | 192 | 74 | 39% | HTTP 200 / 0 bytes |
| Service Catalog | `servicenow-platform/service-catalog/` | 261 | 88 | 34% | HTTP 200 / 0 bytes |
| Knowledge Management | `servicenow-platform/knowledge-management/` | 290 | 100 | 34% | HTTP 200 / 0 bytes |
| **Total (4 areas)** | — | **876** | **279** | **32%** | 0 stub files |

**Verified, not assumed:**
- Service Catalog and Knowledge have **zero** files under `it-service-management/` — only a 1.3 KB pointer (`service-catalog.md`). The bundle-routing split is real, not duplication.
- Empties in all four target bundles return **HTTP 200 with 0 bytes** (re-checked all 17 Incident empties individually plus samples from the other three). Note: one out-of-scope path matched by a loose pattern returned a 404; inside the target bundles the behavior is uniformly 200/0b.
- `canonical_url` is **healthy** — present on 8/8 populated Incident samples and on Change/Catalog/Knowledge samples (one isolated Incident exception, not a pattern). Unlike ITOM, this is not a finding.

**Indexes (both oversized):** `it-service-management/index.md` = **1.01 MB**; `servicenow-platform/index.md` = **1.24 MB**. Service Catalog and Knowledge are buried in the *larger* of the two — the bundle-routing split compounds the pagination problem.

---

## Root-Cause Confirmation

Same defect as ITOM and ITAM: empty topic files return **HTTP 200 / 0 bytes**, not 404 — no error signal, so a retrieval tool treats the gap as a successful fetch and improvises. Verified live across all four bundles. Zero stub files — content is binary (full or empty).

---

## Suite 1 — Incident Management

- **IM-1 index:** part of the 1.01 MB ITSM monolithic index; no sub-index.
- **IM-2 canonical_url (Code):** PASS — present on populated samples.
- **IM-3 assignment rules multi-hop (Code):** answerable, but the basics are hollow — **`create-an-incident.md` and `work-on-incidents.md` are both empty**, as are all four Major Incident Workbench tabs (`mi-workbench-summary/collaborate/communicate/pir-tab.md`), `major-incident-overview.md`, `incident-sla-mgmt-dashboard.md`, and the incident-template how-tos (`t_CreateAnIncidentTemplate.md`, `t_UseATemplateFromAForm.md`, `t_UseATemplateFromAModule.md`).
- **IM-4 empty sweep (Code):** FLAG — 17 empties (13%), incl. the most basic create/work pages above.
- **IM-5 SLA pagination (Desktop):** PENDING — predicted risk: SLA overview pages empty + 1 MB index.

## Suite 2 — Change Management

- **CM-1 index:** part of the 1.01 MB ITSM index; no sub-index.
- **CM-2 approval workflow multi-hop (Code):** FLAG — the approval/CAB entry points are empty: `activate-change-approval-policy.md`, `activate-cab-workbench.md`, `request-cm-risk-assessment.md`, `define-risk-and-impact-conditions.md`.
- **CM-3 canonical_url (Code):** PASS.
- **CM-4 older-branch xref (Code):** not separately run on xanadu (Desktop/branch test) — no genuine 404 observed on australia; all gaps are empty-file (200).
- **CM-5 state transitions (Desktop):** PENDING — predicted risk: the state-model pages are empty (`r_InstalledWithStateModel.md`, `t_ActivateStateModel.md`, `state-model-activate-tasks.md`, `change-data-model.md`).
- **Empty sweep:** FLAG — 74 empties (39%, the worst of the four), incl. standard-change catalog/template pages and risk-assessment pages.

## Suite 3 — Service Catalog

- **SC-1 index (Code):** lives under `servicenow-platform/` (bundle-routing); buried in the 1.24 MB platform index.
- **SC-2 variable/variable-set empty sweep (Code):** FLAG — `variable-attributes.md`, `variables-availability.md`, and `service-catalog-variable-editor.md` are empty — directly the SC-2/SC-3/SC-4 variable topics.
- **SC-3 variable-types multi-hop (Code):** partially answerable from populated pages, but the variable-attributes/availability entry points are empty.
- **SC-5 canonical_url (Code):** PASS.
- **Empty sweep:** FLAG — 88 empties (34%), incl. catalog-item authoring (`edit-cat-item-cat-builder.md`, `save-draft-catalog-item.md`) and order-guide request pages.

## Suite 4 — Knowledge Management

- **KM-1 index (Code):** lives under `servicenow-platform/` (bundle-routing); buried in the 1.24 MB platform index.
- **KM-2 KB + user-criteria multi-hop (Code):** FLAG (worst-hit prompt) — **both** pages the prompt needs are empty: `create-a-knowledgebase.md` and `create-user-criteria-record-in-knowledge-management.md`. Also empty: `create-knowledge-article.md`, `edit-knowledge-article.md`, `knowledge-article-states.md`, `article-versioning.md`.
- **KM-3 canonical_url (Code):** PASS.
- **KM-4 KB-vs-article properties (Desktop):** PENDING — predicted risk: article/KB property + authoring pages empty.
- **Empty sweep:** FLAG — 100 empties (34%, highest absolute count).

---

## Findings Log (Code side)

| ID | Area | Test | Finding type | Description | Severity |
|---|---|---|---|---|---|
| F1 | All 4 | Pre-flight | empty-file (systemic) | 279/876 files (32%) are 0-byte, HTTP 200 — exhaustive sweep, verified live | High |
| F2 | Catalog + Knowledge | Pre-flight | bundle-routing | Service Catalog and Knowledge live under `servicenow-platform/`, not ITSM; no co-location, only a 1.3 KB pointer | High |
| F3 | Incident | IM-3/IM-4 | empty-file (core) | `create-an-incident.md`, `work-on-incidents.md`, all 4 Major Incident Workbench tabs, incident-template how-tos empty | High |
| F4 | Change | CM-2/CM-5 | empty-file (cluster) | Approval-policy, CAB-workbench, state-model, risk-assessment, standard-change pages empty (74 total, 39%) | High |
| F5 | Service Catalog | SC-2/SC-3 | empty-file | `variable-attributes.md`, `variables-availability.md`, `service-catalog-variable-editor.md` empty | Med |
| F6 | Knowledge | KM-2 | empty-file | `create-a-knowledgebase.md` + `create-user-criteria-record-in-knowledge-management.md` both empty — KM-2 prompt lands on two empties | High |
| F7 | ITSM + platform | IM-1/CM-1/SC-1/KM-1 | oversized-index | ITSM index 1.01 MB; servicenow-platform index 1.24 MB; no sub-indexes | Med |
| — | All 4 | IM-2/CM-3/SC-5/KM-3 | (no finding) | canonical_url present on populated samples (one isolated exception) | — |

**Finding types:** `empty-file` (0 bytes, HTTP 200) · `stub-file` (<200 b) · `no-canonical-url` · `monolithic-file` · `xref-broken` · `oversized-index` · `bundle-routing` · `path-guess` · `retrieval-drift`

---

## Pass / Fail Summary (Code side)

| Test | Area | Result |
|---|---|---|
| Pre-Flight | Bundle location | Located — Catalog & Knowledge mis-bundled (F2) |
| IM-1 | Incident | Done — part of 1.01 MB index |
| IM-2 | Incident | PASS — canonical_url ok |
| IM-3 | Incident | FLAG — core create/work pages empty |
| IM-4 | Incident | FLAG — 17 empties (13%) |
| IM-5 | Incident | **FLAG** (`/servicenow_rag`) — SLA conditions/pause not in-bundle; MI tab pages empty. Desktop pending |
| CM-1 | Change | Done — part of 1.01 MB index |
| CM-2 | Change | FLAG — approval/CAB pages empty |
| CM-3 | Change | PASS — canonical_url ok |
| CM-4 | Change | Deferred (xanadu branch / Desktop) |
| CM-5 | Change | **PASS** (`/servicenow_rag`) — approval + state-model pages survive; activate pages empty. Desktop pending |
| SC-1 | Service Catalog | FLAG — bundle-routing, 1.24 MB index |
| SC-2 | Service Catalog | FLAG — variable pages empty |
| SC-3 | Service Catalog | FLAG — variable entry points empty |
| SC-4 | Service Catalog | **PASS/FLAG** (`/servicenow_rag`) — variable types answerable; variable-attributes empty. Desktop pending |
| SC-5 | Service Catalog | PASS — canonical_url ok |
| KM-1 | Knowledge | FLAG — bundle-routing, 1.24 MB index |
| KM-2 | Knowledge | FLAG — KB + user-criteria pages empty |
| KM-3 | Knowledge | PASS — canonical_url ok |
| KM-4 | Knowledge | **FLAG** (`/servicenow_rag`) — KB-create + user-criteria + properties reference all empty. Desktop pending |

---

## Prompt-Test Results — `/servicenow_rag` (Code), 2 per area (8 total)

Run June 24, 2026. Pass = mirror has a populated page that answers in under 3 min; Flag = the named page(s) are empty or the answer must drift/cross-bundle. Every empty and every "answerable" page below was re-verified live (HTTP 200 + byte count).

**Incident Management**
1. *"SLA conditions and pause conditions for incident SLAs"* — **FLAG.** In-bundle coverage is sparse: `incident-sla-mgmt-dashboard.md` is 0 bytes; only `incident-sla-content-pack.md` (4.7 KB) is populated. Incident SLA condition/pause logic is not documented in `incident-management` — it lives in the Service Level Management bundle (cross-bundle); an incident-scoped retrieval finds little.
2. *"How is a major incident declared/managed in the Major Incident Workbench, and what does each tab do?"* — **FLAG (partial).** Declaration/management is answerable (`major-incident-workbench.md` 4.6 KB, `create-a-major-incident.md` 2.9 KB populated), but **every dedicated tab page is empty** — `mi-workbench-summary-tab.md`, `…collaborate-tab`, `…communicate-tab`, `…pir-tab`, plus `major-incident-overview.md`. "What each tab does" lands on blanks.

**Change Management**
1. *"How does the standard change approval workflow route approvals, and what tables are involved?"* — **PASS (empty-file hazard).** Answerable from `change-approval-policy.md` (2.4 KB), `using-change-approval-policies-cf.md` (3.2 KB), `cab-workbench.md` (3.2 KB). But the `activate-change-approval-policy.md`, `activate-cab-workbench.md`, and standard-change-template pages are empty — a name-first grep lands blank.
2. *"All state transitions in the Change workflow, including which roles trigger each?"* — **PASS (empty-file hazard).** Answerable from `c_ChangeStateModel.md` (7.6 KB), `normal-standard-emergency-states.md` (3.3 KB), `configure-change-model-states.md` (4.8 KB), `t_ConfigStateModelTransit.md`. But `change-data-model.md`, `r_InstalledWithStateModel.md`, `t_ActivateStateModel.md`, `state-model-activate-tasks.md` are all empty.

**Service Catalog** *(bundle-routed under `servicenow-platform/`)*
1. *"What variable types are available and their configurable properties?"* — **PASS (empty-file hazard).** Answerable from `c_ServiceCatalogVariables.md` (4.5 KB), `r_CreatingVariablesForFieldTypes.md` (2.7 KB), `c_ScriptableServiceCatalogVariables.md` (8 KB). But `variable-attributes.md` and `variables-availability.md` are empty.
2. *"How are variable sets and variable attributes configured?"* — **FLAG (partial).** Variable **sets** are well-covered (`c_ServiceCatalogVariableSets.md` 8.7 KB, `t_CreateAVariableSet.md` 7 KB, `c_DefineVariableSetLayout.md` 6.3 KB), but the named **variable attributes** topic is empty (`variable-attributes.md`, `variables-availability.md`, `service-catalog-variable-editor.md` all 0 bytes).

**Knowledge Management** *(bundle-routed under `servicenow-platform/`)*
1. *"Steps to configure a knowledge base with user criteria restrictions?"* — **FLAG (worst of the 8).** Both core pages the prompt needs are empty: `create-a-knowledgebase.md` and `create-user-criteria-record-in-knowledge-management.md` (also `t_RequestAKnowledgeBase.md`, `t_AssignAKnowledgeBaseManager.md`). Only diagnostic pages (`diagnose-knowledge-user-criteria.md` 4.2 KB) survive — no how-to to follow.
2. *"What KM properties are configurable at KB level vs article level?"* — **FLAG (partial).** The consolidated reference `r_KnowledgeProperties.md` is empty, as is `configure-act-know-feedback-properties.md`. Scattered specific property pages survive (`knowledge-service-portal-properties.md`, `diagnose-access-criteria-at-kb-level.md` / `-at-an-article-level.md`) but no single KB-vs-article properties page.
</content>
