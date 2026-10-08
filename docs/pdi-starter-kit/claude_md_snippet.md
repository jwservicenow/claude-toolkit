# CLAUDE.md snippet — ServiceNow PDI access

Part of the [PDI starter kit](README.md).

Step 6 of the [setup prompt](pdi_rest_basic_auth_guide.md) offers to add this for you. If you
skipped it, or set things up by hand, paste the block below into `~/.claude/CLAUDE.md` (applies
to every Claude Code session) or into a `CLAUDE.md` in the folder you start Claude from (applies
only there). Replace `<name>` with your instance name.

These rules are what make an admin integration user safe to hand to Claude: every call goes
through the helper that strips secrets, nothing changes without your yes, and Claude checks the
runbook before acting instead of working from memory.

```markdown
## ServiceNow PDI access
- Instance: <name>.service-now.com, integration user `claude.integration` (admin,
  web-service-only).
- Before any action on the instance, read ~/pdi-claude/pdi_runbook.md: search it for the
  section you need rather than reading it all. When you verify a new fact about the instance,
  add it to the runbook with the date.
- All REST calls: `source ~/pdi-claude/pdi-curl.sh`, then `pdi <path>` for reads and
  `pdi_write <METHOD> <path>` (JSON body on stdin) for writes. Never hand-build a curl to the
  instance; it skips the redaction filter.
- Never read a password from the Keychain directly, and never paste or print a password, token
  or key in chat. If one appears, stop and tell me which password to change.
- Before any pdi_write, show me the method, path and body and wait for my yes.
- A 200 on a write means the row changed, not that the platform acted on it. Check for a
  draft/publish workflow or a business rule before calling a change done.
```

If you use the [native MCP servers](pdi_native_mcp_install_guide.md) too, add:

```markdown
- The ServiceNow MCP servers (sn-*) run as whoever approved them in the browser. "Connected"
  doesn't prove a server works; make one real tool call. For any table the MCP tools don't
  cover, use `pdi` / `pdi_write`.
```

> Keep this text and Step 6 of the setup prompt the same. If you change one, change the other.
