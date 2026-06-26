**Claude Code CLI only.** This command uses Claude Code's built-in fetch tool to retrieve from the GitHub docs mirror. If you cannot make a direct HTTP fetch to raw.githubusercontent.com, stop immediately and tell the user: "This command requires Claude Code. For Claude Desktop, use the Desktop setup guide at https://github.com/jwservicenow/claude-toolkit — see the Similar setup for Claude Desktop section."

Answer this ServiceNow question by retrieving from the official docs mirror before responding:

Question: $ARGUMENTS

Steps:
1. Fetch the publication index:
   https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/llms.txt
   Match the question to the right publication using this routing table (folder name → publication):
     CMDB, IRE, Discovery, MID Server, Service Mapping, ITOM → servicenow-platform
     ITSM, Incident, Change, Problem, Service Catalog        → it-service-management
     ITAM, Software Asset, HAM, SAM                         → it-asset-management
     CSM, Customer workflows                                 → customer-service-management
     Scripting, API, REST, GlideRecord                      → api-reference
     AI Control Tower, Now Assist, Generative AI, Gen AI,
       Now LLM, AI Gateway, AI Agent, AI Governance         → intelligent-experiences
       Note: Now Assist *product-specific skills* live in their product publication,
       not intelligent-experiences — e.g. Now Assist for ITSM → it-service-management,
       Now Assist for ITOM → servicenow-platform, Now Assist for CSM → customer-service-management
   If uncertain, pick the best match from the full list in llms.txt.
   Default branch is australia (current GA). Use xanadu/yokohama/zurich if the question specifies.

2. Fetch that publication's index.md. Take the index URL from the llms.txt link list —
   do NOT build it from the folder name. The real path includes a `markdown/` segment:
   `.../{branch}/markdown/{publication}/index.md` (e.g. markdown/intelligent-experiences/index.md).
   Constructing `.../{branch}/{publication}/index.md` without `markdown/` returns 404.
   Request the verbatim raw content — every line and every URL.
   Do not summarize or infer. Extract exact file paths from the returned links only.
   Large multi-app publications (e.g. it-asset-management ≈ 270k chars: SAM, then HAM, SaaS,
   Cloud) are too big to page from the top — the topic you want may sit past offset 200k.
   Don't page sequentially from 0. Instead: WebSearch the topic to find its landing-page
   slug (e.g. `ham-landing-page`), then fetch the index with a `start_index` near that
   region to pull the relevant sub-tree, or fetch the landing-page file directly and follow
   its in-page links. Page sequentially only for small/medium publications.

3. Fetch the topic file using its raw.githubusercontent.com URL.
   Never use docs.servicenow.com or GitHub blob URLs — both are JS SPAs with no readable content.
   For any IRE or CMDB configuration topic, also check for a non-CMDB sibling: if you fetch
   a file like create-ire-data-source-rule.md, also fetch create-non-cmdb-ire-data-src-rule.md
   (and vice versa). The docs publish paired CMDB/non-CMDB variants for most IRE config topics.
   A 404 on the sibling is fine — just skip it.

4. Supplement with Community using WebSearch:
   Query: site:community.servicenow.com <topic keywords>
   Fetch the top 1-2 results that look relevant (articles/forum posts, not search pages).
   Community covers operational behavior, gotchas, and real-world implications that docs omit.

   Prefer the curated, ServiceNow-authored boards first — they outrank generic community Q&A.
   By topic domain:
     AI / Now Assist / AI Agent / agentic / Now LLM / AI Control Tower:
       - Now Assist articles KB: https://www.servicenow.com/community/now-assist-articles/tkb-p/now-assist-articles
       - Intelligence & ML (AI Platform) KB: https://www.servicenow.com/community/intelligence-ml-articles/tkb-p/ai-platform-kb
       - ServiceNow AI Platform blog: https://www.servicenow.com/community/servicenow-ai-platform-blog
     ITAM / Hardware Asset Mgmt (HAM) / Software Asset Mgmt (SAM) / SaaS licensing:
       - HAM articles KB: https://www.servicenow.com/community/ham-articles/tkb-p/hardware-asset-management-kb
       - SAM articles KB: https://www.servicenow.com/community/sam-articles
   Bias the query toward the matching board, e.g.:
     site:servicenow.com/community/now-assist-articles <topic keywords>
     site:servicenow.com/community/ham-articles <topic keywords>
   Trust signal in the URL: `tkb-p` (knowledge base) and `ta-p` (article) are curated/authoritative;
   `m-p` and `td-p` are user forum threads — useful for gotchas, but lower trust. Cite accordingly.
   Discard the weak hits — do NOT cite or fetch:
     - Legacy Virtual Agent / NLU / chatbot threads when the topic is current Now Assist / agentic AI
       (the old VA boards rank highly on generic AI queries but are stale and off-topic).
     - Posts older than ~2 years for any Now Assist / AI Agent topic (the product changes every release).
     - Generic landing/category pages, "Home - ServiceNow Community", and search-result pages.
   If after filtering nothing authoritative remains, skip community entirely rather than citing a weak link.
   Brand-new features (e.g. agentic evals, MCP) may have little/no community coverage yet — that's
   expected; fall back to the docs as the authoritative source and say so.

5. Cite using canonical_url from the file's YAML frontmatter.
   If absent, derive the canonical URL: strip .md from the mirror filename →
   prepend https://docs.servicenow.com/docs/r/
   Example: r_MIDServerSystemRequirements.md → https://docs.servicenow.com/docs/r/r_MIDServerSystemRequirements
   These URLs are JS-rendered — do NOT fetch them. Cite only; they require a browser.
   Flag anything edition-gated or version-specific.

Fallback if mirror doesn't have it:
- Now Support KB — ~90% trusted, cite KB number
- ServiceNow Community — ~80% trusted, flag as community-sourced
  Search: site:servicenow.com/community <topic keywords>
- Third-party — flag as unverified

If retrieval fails entirely: say so and stop. Do not answer from memory.
