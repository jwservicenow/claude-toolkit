# ServiceNow Docs Mirror — AI Retrieval Testing

This area holds test artifacts and recommendations from evaluating the
[ServiceNow/ServiceNowDocs](https://github.com/ServiceNow/ServiceNowDocs) GitHub mirror
as a retrieval source for AI assistants.

Because `docs.servicenow.com` renders as a JavaScript single-page application — not readable
by AI tools — the GitHub mirror, which exposes plain-text Markdown via `raw.githubusercontent.com`,
is the operative path for grounded, citable answers. These artifacts assess how reliably an AI
assistant can answer ServiceNow technical questions from that mirror, and recommend mirror-side
improvements where retrieval breaks down.

## Layout

```
mirror-testing/
  itom/    ITOM Visibility testing (Discovery, MID Server, Service Mapping,
           Agent Client Collector, Event Management, Health Log Analytics)
  itam/    IT Asset Management testing (HAM, SAM, Asset-CMDB sync,
           software normalization, SaaS License Management) — planned
  itsm/    ITSM testing (planned)
```

Each topic folder follows the same convention:

| File | Purpose |
|---|---|
| `recommendations-<date>.md` | Prioritized findings and mirror-side fixes |
| `test-results-<date>.md` | The full structured test script + findings log — runnable as-is |

Findings use a fixed vocabulary so results are comparable across topics:

| Finding type | Meaning |
|---|---|
| `empty-file` | HTTP 200, 0 bytes — successful fetch, no content, no error signal |
| `oversized-index` | A single `.md` over 500KB — pagination/truncation risk |
| `bundle-routing` | Topic in an unexpected bundle, or split across bundles |
| `missing-xref` | Expected cross-bundle link absent or unverifiable |
| `no-canonical-url` | `canonical_url` front-matter missing on a populated page |

The full blank scaffold lives in [`TEST-PLAN-TEMPLATE.md`](TEST-PLAN-TEMPLATE.md).

## How to run

The `test-results-*.md` file is self-contained: it lists the prompts, the exact files and
paths to fetch, and a findings log. To reproduce or extend a run, open it in an AI assistant
with fetch access to `raw.githubusercontent.com` (e.g. Claude Code) and work through the test
suites. Findings are recorded by ID in the findings-log table at the end of the file.

Tests target the `australia` branch (current GA) by default; substitute another release branch
(`xanadu`, `yokohama`, `zurich`) in the raw URLs to test a different release.

## Adding a new topic (e.g. ITSM)

1. Create `mirror-testing/<topic>/`.
2. Copy `TEST-PLAN-TEMPLATE.md` to `<topic>/test-results-<date>.md` and fill it in.
3. Add a `recommendations-<date>.md` (and optional `.html`) summarizing findings by impact.
