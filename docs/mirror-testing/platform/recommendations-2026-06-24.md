# ServiceNow GitHub Docs Mirror — Platform Bundle Findings & Recommendations

**Prepared by:** Jim Wells, ServiceNow ITOM Practice
**Date:** June 24, 2026
**Audience:** ServiceNow GitHub Docs Mirror Administrators
**Bundle:** `markdown/servicenow-platform/` (`australia` branch)

---

## Background

The [ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror is the operative retrieval source for AI-assisted technical work, because `docs.servicenow.com` is a JavaScript single-page application whose content is not readable by AI tools. The mirror exposes plain-text Markdown via `raw.githubusercontent.com`.

This round assesses the **`servicenow-platform`** bundle — the largest in the mirror (3,059 `.md` files) and the home of CMDB, CSDM, Service Catalog, Knowledge Management, and MID Server. All findings were verified live against `raw.githubusercontent.com` on June 24, 2026. Findings are ordered by impact.

---

## Behavioral Validation

The structural sweep below is corroborated by **5 area prompts run through the retrieval skill** (`/servicenow_rag`, Code side): **1 PASS, 4 FLAG.** The empties land precisely on high-value pages, so routine questions cannot be fully answered from the mirror:

- **CMDB** (PASS, with hazard) — the I&R hub and its next-hops answer, but the named `best-practices-id-reconcile`, reconciliation-rules-principles, and identification-rules pages are empty.
- **CSDM** (FLAG) — the conceptual-model page and 3 of the 4 named domains (Foundation, Design, Manage Technical Services) are empty.
- **Service Catalog** (FLAG) — the end-user ordering walkthrough is empty (configuration pages survive).
- **Knowledge** (FLAG) — the lifecycle/state-model/workflow concept pages are empty (task how-tos survive).
- **Dependency Views** (FLAG) — concept pages survive, but every "how to build/control a map" task page is empty.

This is the difference between "X% of files are empty" and "the mirror cannot answer a foundational CSDM question" — the latter is what an admin needs to act on.

## What's Working Well

**Canonical URL metadata is healthy here.** Unlike earlier ITOM observations, a 26-file sample spanning the bundle found `canonical_url` present and correct on every populated page — citation links are reliable for this bundle.

---

## Findings (by impact)

### 1. Systemic Zero-Byte Files Returning HTTP 200 — *Critical*

A bundle-wide sweep (every `.md` sized via the GitHub git tree) found **873 of 3,059 files (28.5%) are zero bytes** — all returning HTTP 200, with no stub files. This matches the rate measured in ITAM (28%) and ITSM (32%), confirming the defect is platform-wide, not bundle-specific. In absolute terms this is the largest empty-file count of any bundle assessed.

**Impact:** An empty file returns **HTTP 200, not 404**. A retrieval tool sees a successful fetch that yielded no content, has no error to catch, and improvises — paginating the oversized index, guessing filenames, or falling back to non-authoritative (Community) content with no visible provenance signal.

**Recommendation:** (a) Populate the empty files; (b) as a safety net, have the mirror pipeline emit a real 404 or a minimal stub-with-marker for any zero-byte file, so retrieval tools can detect the gap instead of silently improvising.

---

### 2. CMDB / CSDM Family Is the Worst-Hit Cluster — *Critical*

The data-model documentation most relevant to CMDB/CSDM advisory work is the most hollowed-out in the bundle:

| Sub-area | Files | Empty | % |
|---|---:|---:|---:|
| common-service-data-model-csdm | 59 | 34 | 57% |
| cmdb-ci-class-models | 21 | 12 | 57% |
| now-assist-for-configuration-management-database-cmdb | 28 | 16 | 57% |
| configuration-management-database-cmdb | 407 | 98 | 24% |

**Impact:** The foundational `csdm-conceptual-model.md` is zero bytes, as are `ci-relationships.md`, `application-services.md`, `best-practices-id-reconcile.md` (identification & reconciliation best practices), and `cmdb-ci-class-models-extend.md` (extending CI class models). A practitioner or AI asking foundational CMDB/CSDM questions lands on empty overview pages while detail survives one hop away — with no overview to route them there.

**Recommendation:** Prioritize the CMDB/CSDM family for repopulation — these are high-traffic conceptual entry points whose absence has outsized impact on grounded answers.

---

### 3. Bundle-Routing — Core Capabilities Have No Top-Level Bundle — *High*

CMDB, CSDM, Service Catalog, Knowledge Management, and MID Server live **only** under `servicenow-platform/`. A repo-wide check confirms there is no top-level `cmdb`, `csdm`, `service-catalog`, or `knowledge` bundle.

**Impact:** A topic-scoped query (e.g. "find CMDB docs") has no obvious bundle to target and must discover that the content is inside the catch-all `servicenow-platform` bundle. This is the same failure mode first seen with MID Server in the ITOM assessment, but far broader.

**Recommendation:** Either promote these high-traffic areas to discoverable top-level bundles, or ensure `llms.txt` and the bundle index clearly advertise them so retrieval tools can route correctly.

---

### 4. Monolithic Platform Index — *High*

`servicenow-platform/index.md` is **1,213 KB** with no sub-indexes — the single largest file in the bundle (next largest is 74 KB).

**Impact:** This is the index Claude Desktop paginated 40+ times during the ITOM MID Server run. Any query landing here must page a 1.2 MB file to navigate, and that hunting is what tips retrieval into path-guessing once it also hits an empty file.

**Recommendation:** Split the index into functional sub-indexes (CMDB, CSDM, Service Catalog, Knowledge, MID Server, …), or publish a lightweight summary index alongside the full one.

---

### 5. High-Empty-Rate Sub-Areas Beyond CMDB/CSDM — *Medium*

Several other sub-dirs are heavily affected: Dependency Views **70% empty** (19/27 — highest rate in the bundle), MID Server **44%** (38/85 — note the ITOM incidental test found only 8, undercounting by ~5×), Knowledge Management 34% (100 files — largest empty count of any named sub-dir), Service Catalog 33%, Service Graph Connectors 32%, and the bundle-root loose files 50% (188/376).

**Impact:** Same HTTP-200/0-byte improvise pattern; broad surface across the platform's most-used modules.

**Recommendation:** Fold these into the same repopulation pass as Finding #1, prioritizing by traffic.

---

## Priority Summary

| Priority | Finding |
|---|---|
| Critical | Systemic zero-byte files returning HTTP 200 (873/3,059 bundle-wide, 28.5%) |
| Critical | CMDB/CSDM family worst-hit (CSDM 57%, class models 57%, Now Assist for CMDB 57%); `csdm-conceptual-model.md` empty |
| High | Bundle-routing — CMDB/CSDM/Catalog/Knowledge/MID Server have no top-level bundle |
| High | Monolithic platform index (1.2 MB, no sub-indexes) |
| Medium | High-empty sub-areas: Dependency Views 70%, MID Server 44%, Knowledge 34%, Service Catalog 33% |

---

## Appendix — Verified Empty Files (samples)

All paths repo-relative under `markdown/servicenow-platform/`, on `australia`, verified June 24, 2026 — each returns **HTTP 200 with 0 bytes**.

**CSDM & CI class models**
- `common-service-data-model-csdm/csdm-conceptual-model.md`
- `common-service-data-model-csdm/ci-relationships.md`
- `common-service-data-model-csdm/cmdb-asset-CI-IBI-sync-options.md`
- `cmdb-ci-class-models/cmdb-ci-class-models-extend.md`

**CMDB**
- `configuration-management-database-cmdb/application-services.md`
- `configuration-management-database-cmdb/best-practices-id-reconcile.md`
- `configuration-management-database-cmdb/app-service-map-base-system.md`

**Service Catalog**
- `service-catalog/add-to-cart-portal.md`
- `service-catalog/add-to-cart-ec.md`
- `service-catalog/access-categories-portal.md`

**Dependency Views**
- `dependency-views/logical-grouping.md`
- `dependency-views/create-predefined-filter.md`

**MID Server**
- `mid-server/c_MIDServerConfiguration.md`
- `mid-server/c_MIDServerConnectionPrerequisites.md`

**Bundle-wide:** 873 of 3,059 files (28.5%). Full list available on request.
