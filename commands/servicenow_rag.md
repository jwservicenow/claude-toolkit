Answer this ServiceNow question by retrieving from the official docs mirror before responding:

Question: $ARGUMENTS

Steps:
1. Fetch the publication index:
   https://raw.githubusercontent.com/ServiceNow/ServiceNowDocs/australia/llms.txt
   Scan it to identify the relevant publication. Default branch is australia (current GA).
   If the question specifies a different release (xanadu, yokohama, zurich), use that branch instead.

2. Fetch that publication's index.md to find the specific topic file.
   Do not follow ../reference/ relative links — broken (open bug #17).

3. Fetch the topic file using its raw.githubusercontent.com URL.
   Never use docs.servicenow.com or GitHub blob URLs — both are JS SPAs with no readable content.

4. Supplement with Community — official docs cover definitions and structure; Community covers
   operational behavior, gotchas, and real-world implications. Search and fetch Community sources
   even when the mirror has relevant content:
   site:servicenow.com/community <topic keywords>

5. Cite using canonical_url from the file's YAML frontmatter.
   If absent (open bug #11), construct the docs.servicenow.com URL manually from the file path.
   Flag anything edition-gated or version-specific.

Fallback if mirror doesn't have it:
- Now Support KB — ~90% trusted, cite KB number
- ServiceNow Community — ~80% trusted, flag as community-sourced
  Search: site:servicenow.com/community <topic keywords>
- Third-party — flag as unverified

If retrieval fails entirely: say so and stop. Do not answer from memory.
