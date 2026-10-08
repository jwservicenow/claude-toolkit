# PDI starter kit — Claude Code as admin on your ServiceNow PDI

Claude Code reads any table on your personal developer instance (PDI) and makes the changes you
approve. About 20 minutes.

**You need:** a Mac, a PDI where you have the `admin` role, and a Claude Pro, Max, Team or
Enterprise plan.

## Setup

1. Install Claude Code (skip if `claude --version` prints a version), then open a new Terminal
   window:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
2. Start it in a working folder:
   ```bash
   mkdir -p ~/pdi-claude && cd ~/pdi-claude && claude
   ```
3. Copy [**The Prompt**](pdi_rest_basic_auth_guide.md#the-prompt), paste it in and follow along,
   with your PDI open in a browser and logged in as admin.

That's it. The Prompt creates one user on your instance, `claude.integration`, and puts a small
helper, a runbook and one Keychain item on your Mac.

## How it stays safe with admin

- **You approve every write.** Claude shows the method, path and body first.
- **Secrets never reach the chat.** Every response goes through a redaction filter, and the
  password lives only in the macOS Keychain.
- **API only.** The user can't log in to the UI.
- **One switch to cut it off.** Clear **Active** on `claude.integration`.

## More, if you want it

| Piece | What's in it |
|---|---|
| [REST guide](pdi_rest_basic_auth_guide.md) | The Prompt, the role list, everyday use, troubleshooting, removal |
| [CLAUDE.md snippet](claude_md_snippet.md) | The standing rules Claude follows on your instance; the prompt adds them for you |
| [Runbook template](pdi_runbook_template.md) | Claude's notes about your instance; the prompt downloads it for you |
| [Native MCP servers](pdi_native_mcp_install_guide.md) | Optional: the platform's own 36 MCP tools. Needs Australia / Zurich Patch 9+ with Now Assist |
| [Table API over OAuth](optional_oauth_table_api.md) | Optional: token-based sign-in instead of Basic Auth |

## Status — 2026-10-07

The paste-in prompt was run end to end on a second Australia PDI in a fresh Claude Code session,
and every step passed. The helper was also tested in bash and zsh against a local stub server and
against the reference PDI (Australia). Each guide's status note says exactly what was and wasn't
tested.
