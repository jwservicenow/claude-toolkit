# PDI starter kit — Claude Code with admin access to your ServiceNow PDI

Everything you need to have Claude Code work on your ServiceNow personal developer instance
(PDI) as an admin integration user: reading any table, making changes you approve, and keeping
its own notes about your instance.

**You need:** a Mac, a PDI where you have the `admin` role, and a Claude Pro, Max, Team or
Enterprise plan.

## Core — do these in order

| # | Piece | What it gives you | Time |
|---|---|---|---|
| 1 | [REST Basic Auth guide](pdi_rest_basic_auth_guide.md) | Installs Claude Code, then one paste-in prompt creates the `claude.integration` user, stores its password in the Keychain, writes the helper, tests it, adds the CLAUDE.md rules and starts your runbook | ~20 min |
| 2 | [CLAUDE.md snippet](claude_md_snippet.md) | The standing rules Claude follows on your instance. Step 6 of the prompt adds them for you; this page is for doing it by hand | 2 min |
| 3 | [Runbook template](pdi_runbook_template.md) | Claude's notes about your instance: access, scope, ACC, MID, Discovery, CMDB, and a traps list seeded from a working setup. Step 7 of the prompt downloads it for you | grows as you work |

**Core roles** for `claude.integration`: `admin`, `itil_admin`, `asset`, `discovery_admin`,
`snc_internal`, `acc_admin_for_global`, `agent_client_collector_admin`, `mid_server`,
`cmdb_inst_admin`. The full list, with the optional MCP and AI roles, is in the
[REST guide](pdi_rest_basic_auth_guide.md#part-2--run-the-setup-prompt).

## Optional

| Piece | Use it when |
|---|---|
| [Native MCP servers](pdi_native_mcp_install_guide.md) | You want the platform's own 36 MCP tools (CMDB, ITSM, ITOM) alongside REST. Needs Australia / Zurich Patch 9+ with Now Assist. Add the optional MCP roles to `claude.integration` |
| [Table API over OAuth](optional_oauth_table_api.md) | You want token-based sign-in for REST instead of Basic Auth. Not needed for the kit |

## How it stays safe with admin

`claude.integration` is admin, so it can change anything. What keeps that under your control:

- **You approve every write.** Claude shows the method, path and body first.
- **Secrets never reach the chat.** An admin reads password-type fields in clear text, so every
  response goes through a redaction filter. The password itself lives only in the macOS
  Keychain.
- **API only.** The user is web-service-only and can't log in to the UI.
- **One switch to cut it off.** Clear **Active** on `claude.integration`.

## Status — 2026-10-07

The helper was tested in bash and zsh against a local stub server and against the reference PDI
(Australia). The paste-in prompt has not yet been run end to end on a fresh PDI. Each guide's
status note says exactly what was and wasn't tested.
