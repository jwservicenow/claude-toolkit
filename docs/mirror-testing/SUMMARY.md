# ServiceNow Docs Mirror — Cross-Bundle Findings Summary

**Date:** June 24, 2026 (baseline) · **Re-swept:** June 25, 2026 · **Branch:** `australia` · **Prepared by:** Jim Wells, ServiceNow ITOM Practice

> **Update — June 25, 2026:** The mirror team republished after root-causing the empty-file defect.
> A full re-sweep confirms it is **fixed**: 0-byte files dropped from **~2,200 to 6** (the 6 are legacy
> pages, empty on every release). The two structural findings persist. Full before/after:
> [`RESWEEP-2026-06-25.md`](RESWEEP-2026-06-25.md).

The [ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror is the
operative retrieval source for AI-assisted technical work, because `docs.servicenow.com` is a
JavaScript SPA that AI tools cannot read. Four bundles were assessed with exhaustive file-size
sweeps plus retrieval-skill ("behavioral") prompts — **every number below verified live against
`raw.githubusercontent.com`.**

| Bundle | Files swept | Empty — baseline | Empty — **now** | Behavioral | Index size |
|---|---:|---:|---:|:--:|---:|
| ITOM — `it-operations-management` | 2,881 | 597 (20.7%) | **1** | 1P / 4F | ~1.2 MB |
| ITAM — `it-asset-management` | 1,607 | 452 (28%) | **0** | 0P / 4F | 637 KB |
| ITSM — 4 areas* | 876 | 279 (32%) | **0** | 3P / 5F | 1.01 MB |
| Platform — `servicenow-platform` | 3,059 | 873 (28.5%) | **5** | 1P / 4F | 1.21 MB |

\*ITSM's Service Catalog + Knowledge actually live under `servicenow-platform/` (see Theme 2) and are
counted in the ITSM sweep — they overlap the Platform row, so the columns are **not** summable.
Behavioral rollup was taken at baseline: **5 PASS / 17 FLAG of 22 area checks** — most FLAGs traced to
empty files now resolved; the structural FLAGs remain.

## Four cross-bundle themes

1. **Systemic empty files returning HTTP 200 — *Critical.*** Every bundle runs 20.7%–32% zero-byte
   files, with **zero stub files** (content is binary: full or empty). An empty file returns HTTP 200,
   not 404 — a retrieval tool sees a successful fetch with no content, no error to catch, and improvises
   (path-guessing, index pagination, Community fallback with no provenance signal). The empties cluster
   on the **entry-point / concept / "create" pages** a broad question lands on first — so the real issue
   is "the mirror cannot answer a foundational question," not the percentage.
2. **Bundle-routing — *High.*** High-value areas (CMDB, CSDM, Service Catalog, Knowledge, MID Server)
   live **only** under `servicenow-platform/`, not where an ITOM- or ITSM-scoped query looks for them.
3. **Oversized monolithic indexes — *High.*** Each bundle index is 652 KB–1.24 MB with no sub-indexes;
   the pagination this forces is what tips a run into path-guessing once it also hits an empty file.
4. **canonical_url metadata.** Healthy in ITAM, ITSM, and Platform; inconsistent **only in ITOM**.

## Status with the mirror team

The **empty-file defect (build bug) is fixed** — confirmed by the June 25 re-sweep (~2,200 → 6 zero-byte
files; the 6 are legacy pages empty on every release). Bundle-routing and oversized-index were raised but
**not committed**, and both persist — verified live. See [`RESWEEP-2026-06-25.md`](RESWEEP-2026-06-25.md).

Per-bundle detail: [`itom/`](itom/) · [`itam/`](itam/) · [`itsm/`](itsm/) · [`platform/`](platform/).
