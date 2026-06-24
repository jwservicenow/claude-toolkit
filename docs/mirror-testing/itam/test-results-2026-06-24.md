# ITAM Mirror Test Results — Code Side

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Branch:** `australia`
**Mirror:** ServiceNow/ServiceNowDocs (GitHub)
**Status:** Direct-fetch (Code) testing complete · interactive-surface validation ongoing

> All numbers below are from an **exhaustive file-size sweep** of the bundle and were verified live against `raw.githubusercontent.com`.

---

## Pre-Flight — Bundle Location & Structure

**Result: PASS — ITAM is well-consolidated, not mislocated.** All ITAM lives in a single top-level bundle `markdown/it-asset-management/` (1,607 `.md` files). No splitting across `now-platform/` / `servicenow-platform/`. This is the opposite of ITOM's scattered MID Server surprise — a structural positive.

| Sub-dir | .md files | Empty (0-byte) | % empty |
|---|---:|---:|---:|
| software-asset-management | 427 | 70 | 16% |
| enterprise-asset-management | 396 | 95 | 24% |
| hardware-asset-management | 321 | 125 | 39% |
| cloud-cost-management | 128 | 29 | 23% |
| saas-license-management | 92 | 20 | 22% |
| asset-management (classic) | 62 | 29 | **47%** |
| contract-management | 54 | 31 | 57% |
| product-catalog | 44 | 29 | 66% |
| procurement | 44 | 22 | 50% |
| now-assist-for-software-asset-management-sam | 17 | 2 | 12% |
| asset-audits | 15 | 0 | 0% |
| now-assist-for-hardware-asset-management | 1 | 0 | 0% |
| (bundle root) | 6 | 0 | 0% |
| **TOTAL** | **1,607** | **452** | **28%** |

**Headline:** 452 of 1,607 files (28%) are 0 bytes. Zero stub files (<200b) — content is binary: fully populated or completely empty. This is ~25× the ITOM empty count (18) and confirms the root-cause thesis at scale.

---

## Root-Cause Confirmation

Empties return **HTTP 200 with 0 bytes** — no error signal. Verified on samples:

| File | HTTP | Bytes |
|---|---|---|
| asset-management/c_Stockrooms.md | 200 | 0 |
| asset-management/manage-transfer-orders.md | 200 | 0 |
| hardware-asset-management/Work-with-hardware-normalization.md | 200 | 0 |

An AI retrieval layer sees a successful fetch and improvises from an empty page — no broken-link/404 to flag the gap. Same failure mode as ITOM, far larger blast radius.

---

## Suite 1 — Hardware Asset Management (HAM)

- **HAM-1 file count:** 321 files, sub-dirs N (flat under `hardware-asset-management/`).
- **HAM-2 empty/stub sweep:** 125 empty (39%). The **classic `asset-management/` lifecycle + transfer-order + stockroom cluster is almost entirely empty** — `c_Stockrooms.md`, `c_FollowLifeCycleConsumbl.md`, `create-a-transfer-order.md`, `manage-transfer-orders.md`, `work-with-transfer-orders.md`, `move-transfer-order-line-through-stages.md`, `transfer-order-flows.md` all 0 bytes. Newer `enterprise-asset-management/` and `hardware-asset-management/` workspace equivalents (receive/putaway/pick/disposal in stockrooms) ARE populated (~2–8KB each). Coverage migrated to the workspace pages; the classic module pages were emptied.
- **HAM-3 canonical_url:** present & correct on all populated samples (e.g. `asset-lifecycle-automation.md`, `approximated-lifecycles-hardware-products.md`). No `no-canonical-url` finding.
- **HAM-4 (Desktop):** PENDING.

## Suite 2 — Software Asset Management (SAM)

- **SAM-1 file count:** 427 files (largest sub-dir), sub-dirs N.
- **SAM-2 multi-hop:** reconciliation/entitlement core IS populated — `c_SAMReconciliation.md` (5.2KB), `reconcile-licenses-global-entities.md` (7.4KB), `license-metric-results-fields.md` (11.3KB), `mapping-ms-license-metrics.md` (11.8KB).
- **SAM-3 empty/stub sweep:** 70 empty (16%). Key gaps that hit the test prompt directly: `license-types-impact-reconciliation.md` (0) — the compliant-vs-noncompliant driver page; `create-entitlements-workspace.md` (0), `playbook-entitlementsetup-workspace.md` (0), `create-entitlement-sap.md` (0), the M365-from-SA-add-on entitlement pages (0). Vendor-specific entitlement how-tos (Citrix, Microsoft SA) populated.
- **SAM-4 canonical_url:** present & correct (`Config-sam-workspace.md`). No finding.
- **SAM-5 (Desktop):** PENDING.

## Suite 3 — Asset ↔ CMDB Synchronization

- **ASSET-1 cross-bundle boundary:** Classic `asset-management/` (62 files) is the most hollowed sub-dir at **47% empty (29/62)** — the asset-class/CI-mapping conceptual pages (`c_AssetClasses.md`, `t_CreateAnAssetClass.md`) are 0 bytes. Asset↔CI synchronization narrative pages are among the empties. The navigable ITAM↔CMDB bundle link could not be confirmed because the entry-point pages that would carry it are empty — classify as `missing-xref` risk pending Desktop trace, not a confirmed 404.
- **ASSET-2 empty/stub sweep:** see 47% above. No 404s observed (all empties are 200/0b).

## Suite 4 — Software Normalization & Content

- **NORM-1 monolithic candidate:** `it-asset-management/index.md` = **652KB** → `oversized-index` (>500KB). This is the ITAM analog of ITOM's `r_SupportedApplications.md`. Largest topic files: SaaS integration pages 40–54KB (`integrate-sfmc-oauth.md` 53.9KB), `software-model-fields.md` 51.3KB — pagination candidates for Desktop.
- **NORM-2 multi-hop:** **The normalization entry-point pages are empty** while their sub-pages have content: `hardware-normalization.md` (0), `Work-with-hardware-normalization.md` (0), and SAM's `sam-normalization.md` (0) are all 0 bytes; supporting pages (`opt-in-hardware-normalization.md` 3.8KB, `normalization-suggestions.md` 4.1KB, `normalization-status.md` 3.2KB, `sam-normalization-dash.md` 3.4KB) are populated. A reader landing on the overview gets nothing; the detail exists one hop away with no overview to route them.
- **NORM-3 (Desktop):** PENDING.

## Suite 5 — SaaS License Management

- **SAAS-1 file count + stub risk:** 92 files, 20 empty (22%), sub-dirs N. Core overview pages empty: `usage-summary-saas.md` (0), `reclaiming-user-subscriptions-saas.md` (0), `add-reclamation-rule-sub.md` (0) — i.e. the "surface unused/reclaimable subscriptions" overview is gutted, while vendor-specific reclaim how-tos (monday, roadmunk, surveymonkey, both classic + workspace) ARE populated (~5–7KB each).
- **SAAS-2 multi-hop:** usage-ingestion data-stream how-tos populated and detailed (`create-data-stream-action-slc.md` 12KB, `create-data-stream-get-activity.md` 13KB). Same pattern: how-to depth present, conceptual/summary entry pages empty.
- **SAAS-3 (Desktop):** PENDING.

---

## Findings Log (Code side)

| ID | Sub-area | Test | Finding type | Description | Severity |
|---|---|---|---|---|---|
| F1 | Bundle-wide | Pre-flight | empty-file (systemic) | 452/1,607 files (28%) are 0-byte, HTTP 200 — no error signal | High |
| F2 | Bundle | Pre-flight | bundle-routing (positive) | ITAM cleanly consolidated in one bundle; no mislocation | — |
| F3 | HAM / asset-mgmt | HAM-2 | empty-file (cluster) | Classic lifecycle/transfer-order/stockroom pages all empty; workspace equivalents populated | High |
| F4 | SAM | SAM-3 | empty-file | `license-types-impact-reconciliation.md` + several entitlement-creation pages empty | Med |
| F5 | Asset↔CMDB | ASSET-1/2 | empty-file / missing-xref | asset-management 47% empty; asset-class/CI-mapping concept pages gone; ITAM↔CMDB nav link unverifiable | High |
| F6 | Normalization | NORM-2 | empty-file (entry-point) | `hardware-normalization.md`, `Work-with-hardware-normalization.md`, `sam-normalization.md` overview pages empty; sub-pages populated | Med |
| F7 | Normalization | NORM-1 | oversized-index | `index.md` 652KB → pagination risk on Desktop | Med |
| F8 | SaaS | SAAS-1/2 | empty-file (entry-point) | `usage-summary-saas.md`, `reclaiming-user-subscriptions-saas.md`, `add-reclamation-rule-sub.md` empty; vendor how-tos populated | Med |
| — | HAM/SAM/EAM/SaaS | HAM-3/SAM-4 | (no finding) | canonical_url present & correct on all populated samples | — |

---

## Pass / Fail Summary (Code side)

| Test | Sub-area | Result |
|---|---|---|
| Pre-Flight | Bundle location | PASS (consolidated) + systemic empty finding |
| HAM-1 | HAM | Done — 321 files |
| HAM-2 | HAM | FLAG — 39% empty, classic cluster gutted |
| HAM-3 | HAM | PASS — canonical_url ok |
| HAM-4 | HAM | PENDING (Desktop) |
| SAM-1 | SAM | Done — 427 files |
| SAM-2 | SAM | PASS — reconciliation core populated |
| SAM-3 | SAM | FLAG — 16% empty incl. compliance driver page |
| SAM-4 | SAM | PASS — canonical_url ok |
| SAM-5 | SAM | PENDING (Desktop) |
| ASSET-1 | Asset↔CMDB | FLAG — 47% empty, nav link unverifiable |
| ASSET-2 | Asset↔CMDB | FLAG — concept pages empty |
| NORM-1 | Normalization | FLAG — index.md 652KB |
| NORM-2 | Normalization | FLAG — entry-point pages empty |
| NORM-3 | Normalization | PENDING (Desktop) |
| SAAS-1 | SaaS | FLAG — overview pages empty |
| SAAS-2 | SaaS | PASS — ingestion how-tos populated |
| SAAS-3 | SaaS | PENDING (Desktop) |
</content>
</invoke>
