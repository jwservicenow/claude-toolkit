# claude-code-toolkit

Slash commands, scripts, and setup guides for Claude Code — a working practitioner's toolkit. Includes one ServiceNow-specific skill and several general-purpose utilities.

## What's included

**Commands** (`commands/`)
- **`/servicenow_rag`** — routes ServiceNow technical questions through the official GitHub markdown mirror (`ServiceNow/ServiceNowDocs`), supplements with Community for operational context, falls back through a trust hierarchy (KB → Community → third-party with explicit flags), and halts cleanly if nothing retrievable. No fabricated table names, no uncitable claims.
- **`/newsession [optional runbook]`** — at session end, generates a ~500-token transition prompt you can paste into a fresh Claude Code session to resume work without replaying chat history. Optionally pass a runbook or planning file (bare filename or full path) so the next session is shaped by its content.

**Scripts** (`scripts/`)
- **`statusline-command.sh`** — custom Claude Code statusline showing working directory, model + context window size, and a live context-usage bar. Useful for spotting when you're approaching auto-compact.

**Docs** (`docs/`)
- **[`setup.md`](docs/setup.md)** — full setup guide for running Personal Pro + Enterprise Claude Code on the same Mac without crossing data streams. Aliases, separate configs, MCP setup, VS Code integration. ~15 minutes start to finish.

## Why `/servicenow_rag`

**The problem:** ServiceNow — like many enterprise sites — restricts AI web crawlers from indexing its documentation through strict `robots.txt` directives, in addition to being a JavaScript-heavy, dynamic architecture that hinders automated scraping. Standard AI fetch tools land on empty SPA shells or get blocked outright, so Claude falls back to memory and fabricates content.

**How the skill works:**

ServiceNow publishes a mirror of the same documentation as plain markdown on GitHub at `ServiceNow/ServiceNowDocs`, specifically for AI consumption. The skill bypasses the SPA + robots.txt blockade by going to that source instead:

1. Fetches `llms.txt` at the repo root — ServiceNow's curated index of every publication bundle. (`llms.txt` is an emerging open standard for LLM-accessible documentation, see llmstxt.org.)
2. Locates the right bundle from that index (e.g., `servicenow-platform`, `it-operations-management`).
3. Fetches the bundle's `index.md` to find the specific topic file's path.
4. Retrieves the topic file via `raw.githubusercontent.com` — plain markdown, no SPA, no robots block.
5. Supplements with `servicenow.com/community` for operational behavior and gotchas the official docs don't cover.
6. Falls back through trust tiers (Now Support KB → Community → third-party with explicit flags) when the mirror doesn't cover the topic.
7. Halts cleanly if nothing retrievable — no memory-based answer with a disclaimer.

**What you get:**

- **Restored access to authoritative docs.** AI tools can finally reach ServiceNow's official documentation as an authoritative source, instead of being blocked at the docsite's SPA shell or robots.txt wall.
- **Verifiable citations.** Every claim has a URL that was actually retrieved at query time, not pattern-matched from training data.
- **No more wrong table names.** `cmdb_ci_win_server` (real) instead of the hallucinated `cmdb_ci_windows_server`. RHEL 6+ (documented) instead of the invented RHEL 7/8/9.
- **Zero infrastructure.** No vector DB, no embedding pipeline, no scheduled crawl. ServiceNow publishes the mirror; the skill just retrieves from it.

## Install — slash commands

```bash
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/servicenow_rag.md \
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/commands/servicenow_rag.md
curl -o ~/.claude/commands/newsession.md \
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/commands/newsession.md
```

## Install — statusline

1. Download the script and make it executable:
   ```bash
   curl -o ~/.claude/statusline-command.sh \
     https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/scripts/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```
2. Add this block to `~/.claude/settings.json` (inside the top-level object):
   ```json
   "statusLine": {
     "type": "command",
     "command": "sh ~/.claude/statusline-command.sh"
   }
   ```
3. Restart Claude Code.

Requires `jq` (`brew install jq` if you don't have it).

## Use

```
/servicenow_rag what sys_property controls Discovery IP range exclusions?
/servicenow_rag system requirements for Service Mapping
/servicenow_rag difference between cmdb_rel_ci and svc_ci_assoc

/newsession
/newsession homelab_inventory.md
/newsession ~/path/to/some_runbook.md
```

## Update later

Re-run the relevant `curl` command(s) above. Each overwrites your local copy with the latest version from this repo.

## Verify `/servicenow_rag` is working

Ask it something too specific to fake from memory:

```
/servicenow_rag what sys_property controls Discovery IP range exclusions?
```

If Claude fetches `llms.txt` before answering, the skill fired. If it answers immediately with no fetch, something prevented activation.

## Constraints

- **Claude Code only.** Slash commands and statusline scripts are Claude Code features. (`/servicenow_rag` additionally requires Claude Code's raw-GitHub fetch behavior, which Claude Desktop's fetch policy blocks.)
- **`/servicenow_rag` specifics:**
  - Default branch is `australia` (current GA). For release-scoped work, mention the branch in your question (e.g., "on xanadu, what changed in...").
  - The mirror has known bugs — some files miss `canonical_url` frontmatter (the skill constructs the docsite URL manually); some internal `../reference/` links resolve to 404s (the skill ignores them and navigates via the bundle index instead).

## License

MIT — see [LICENSE](LICENSE).
