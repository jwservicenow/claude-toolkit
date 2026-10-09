# PDI starter kit — Claude Code on your ServiceNow PDI

Connect Claude Code to your personal developer instance (PDI). **You need:** a Mac, a PDI where you have `admin`, and a Claude Pro, Max, Team or Enterprise plan.

## Two setups, in order
| Setup | Reads | Writes | Signs in as | Needs | Status | Prompt |
|---|---|---|---|---|---|---|
| **Setup 1 — REST with admin** (required) | Any table | Any table, after your yes | `claude.integration`, an API-only user you create | Any release | Run 2026-10-08: passed end to end. Later wording fixes not re-run | [SETUP_1_REST_ADMIN.md](SETUP_1_REST_ADMIN.md) |
| **Setup 2 — Native MCP** (optional, after Setup 1) | 36 built-in tools: CMDB, incidents, alerts | Through those tools, after your yes | You, approved in the browser | Zurich or Australia, Now Assist, MCP Store apps (Setup 2 tells you which) | Run 2026-10-09: 5 servers connected, 2 returned data. Later fixes not re-run | [SETUP_2_NATIVE_MCP.md](SETUP_2_NATIVE_MCP.md) |

1. Install Claude Code (skip if `claude --version` prints a version). Run this, then open a new Terminal window:
   ```
   curl -fsSL https://claude.ai/install.sh | bash
   ```
2. Start it in a working folder. Run these one at a time:
   ```
   mkdir -p ~/pdi-claude
   ```
   ```
   cd ~/pdi-claude
   ```
   ```
   claude
   ```
3. Paste Setup 1's prompt and follow along, with your PDI open in a browser as admin. For Setup 2, start a fresh session in the same folder and paste its prompt.

**Safety:** Claude asks before every change, and no password or secret goes in the chat; you type those only in the browser or a separate Terminal window.

| More | What's in it |
|---|---|
| [REST guide](claude_rest_admin_guide.md) · [MCP guide](pdi_native_mcp_install_guide.md) | What each prompt sets up, everyday use, troubleshooting, removal |
| [CLAUDE.md rules](claude_md_snippet.md) · [Runbook template](pdi_runbook_template.md) | The standing rules and instance notes the prompts write into `~/pdi-claude` |
