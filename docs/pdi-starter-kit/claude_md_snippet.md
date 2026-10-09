# CLAUDE.md snippet — ServiceNow PDI access

Part of the [PDI starter kit](README.md).

Both paste-in prompts write these rules to `~/pdi-claude/CLAUDE.md` for you: Step 6 of
[SETUP_1_REST_ADMIN.md](SETUP_1_REST_ADMIN.md) writes the first block, and Step 8 of
[SETUP_2_NATIVE_MCP.md](SETUP_2_NATIVE_MCP.md) the second. Claude Code loads that file whenever you
start it in `~/pdi-claude`. If you set things up by hand, paste the block for your method there
and replace `<name>` with your instance name. To apply the rules in every folder instead, put
them in `~/.claude/CLAUDE.md`.

These rules are what make an admin integration user safe to hand to Claude: every call goes
through the helper that strips secrets, nothing changes without your yes, and Claude checks the
runbook before acting instead of working from memory.

**REST with admin:**

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

**Native MCP:**

```markdown
## ServiceNow MCP servers
- The sn-* MCP servers run as whoever signed in to them in the browser, with that user's roles.
- "Connected" doesn't prove a server works; make one real tool call.
- Before any MCP tool call that changes a record, tell me what it changes and wait for my yes.
- Never ask for, paste or print the OAuth client secret, a password, token or key in chat.
```

> Keep each block identical to its prompt step. If you change one, change the other.
