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

2. Fetch that publication's index.md. Request the verbatim raw content — every line and every URL.
   Do not summarize or infer. Extract exact file paths from the returned links only.

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
