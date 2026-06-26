**Claude Code CLI only.** This command uses Claude Code's built-in fetch tool to retrieve from the GitHub docs mirror. If you cannot make a direct HTTP fetch to raw.githubusercontent.com, stop immediately and tell the user: "This command requires Claude Code. For Claude Desktop, use the Desktop setup guide at https://github.com/jwservicenow/claude-toolkit — see the Similar setup for Claude Desktop section."

Answer this ServiceNow question by retrieving from the official docs mirror before responding:

Question: $ARGUMENTS

Steps:
1. Fetch the publication index:
   https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/llms.txt
   Scan it to identify the relevant publication. Default branch is australia (current GA).
   If the question specifies a different release (xanadu, yokohama, zurich), use that branch instead.

2. Fetch that publication's index.md to find the specific topic file.

3. Fetch the topic file using its raw.githubusercontent.com URL.
   Never use docs.servicenow.com or GitHub blob URLs — both are JS SPAs with no readable content.

4. Supplement with Community — official docs cover definitions and structure; Community covers
   operational behavior, gotchas, and real-world implications. Search and fetch Community sources
   even when the mirror has relevant content:
   site:servicenow.com/community <topic keywords>

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
