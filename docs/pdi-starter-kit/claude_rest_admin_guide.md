# Claude REST (with admin) guide

Part of the [PDI starter kit](README.md). Claude Code reaches your PDI through the REST Table API,
signed in with Basic Auth as one admin integration user. The setup is the paste-in prompt,
[SETUP_1_REST_ADMIN.md](SETUP_1_REST_ADMIN.md); start with the [kit README](README.md). Everything
below is reference.

## What the prompt creates

- **On your instance:** one user, `claude.integration`, web-service-only (it can't log in to the
  UI), holding the roles below. No other changes.
- **In `~/pdi-claude` on your Mac:** `pdi-curl.sh` (the helper), `pdi-redact.py` (the redaction
  filter), `pdi_runbook.md` (Claude's notes about your instance) and `CLAUDE.md` (the standing
  rules; the same text as the [CLAUDE.md snippet](claude_md_snippet.md)). Plus one Keychain item.

**Roles for `claude.integration`:** `admin`, `itil_admin`, `asset`, `discovery_admin`,
`snc_internal` (if offered), `acc_admin_for_global`, `agent_client_collector_admin`,
`mid_server`, `cmdb_inst_admin`.

---

## Everyday use

Start Claude Code with these two commands, one at a time, so the rules in that folder's
`CLAUDE.md` load:

```
cd ~/pdi-claude
```
```
claude
```

Ask Claude in plain words: *"List the 10 newest incidents"*, *"Which CIs in cmdb_ci_server have
no serial number?"*, *"Set the short description of INC0010001 to …"*. Claude reads with `pdi`
straight away and asks before any `pdi_write`.

When Claude Code asks permission to run a command, approve `pdi_write` calls one at a time.
Don't choose the option that stops it asking for those.

**Where REST inserts land:** a config record created over REST goes into the integration user's
current application scope, even when the request body names a different `sys_scope`. Keep that
scope on **Global**, the default. To create a record in a scoped app, switch the user's
`apps.current_app` preference (`sys_user_preference`) to that app, do the write, and switch it
back to Global. Seen on the reference PDI, 2026-10-06; a scope left on a scoped app stranded
config records there (2026-10-07).

## What the safety rails are

The integration user is admin, so it can change anything on the instance, security settings
included. These rails are what keep that under your control:

| Rail | What it stops |
|---|---|
| Claude asks before every write | You see method, path and body before anything changes |
| Redaction filter on every response | An admin reads password-type fields in clear text; the filter turns them into `<REDACTED>` before they reach the chat |
| Keychain, read per call | No password in a file, a command line, shell history or the chat |
| Web service access only | The account can't log in to the UI or a portal |
| One named integration user | Every change shows as `claude.integration` in the audit history; clearing **Active** on that user cuts Claude off at once |

## Troubleshooting

- **`claude: command not found` after installing**: open a new Terminal window. If it's still
  missing, follow
  [Fix your PATH](https://code.claude.com/docs/en/troubleshoot-install#command-not-found-claude-after-installation).
  Claude Code needs macOS 13 or later; `brew install --cask claude-code` is an alternative
  installer. Full details: [Claude Code setup](https://code.claude.com/docs/en/setup).
- **`HTTP 401`**: the Keychain password and the instance password don't match, or the account
  is locked out after failed attempts. Reset the password on the user record, then re-run the
  Step 3 command with `-U`. Check that the user's **Locked out** box is clear.
- **`HTTP 403`**: a role is missing for that table or API. Re-run Step 5b and compare.
- **HTML instead of JSON, or a timeout**: the PDI is probably asleep. Wake it from
  developer.servicenow.com.
- **`pdi: no keychain item`**: the Keychain item's account or service name doesn't match
  `pdi-curl.sh`. The service name must be `servicenow-pdi-<your-instance>`.

## Removing it

1. In the PDI: open `claude.integration` (All → User Administration → Users) and clear
   **Active**, or delete the record.
2. On the Mac:
   ```bash
   security delete-generic-password -a claude.integration -s servicenow-pdi-<your-instance>
   ```
3. Delete the `~/pdi-claude` folder.

## Status

> **Status — 2026-10-09.** This version of the prompt (core roles only, rules written to
> `~/pdi-claude/CLAUDE.md` without asking) was run end to end on 2026-10-08 on Sonnet 5.5 at
> medium effort, and every step passed. Wording fixes made after that run were not re-run. An
> earlier version was run end to end on 2026-10-07 on a second Australia PDI in a fresh Claude
> Code session: every step passed, including the Step 5c write (create HTTP 201, delete 204). In that run the user record
> and role grants were made over REST as admin rather than in the browser; the password was set
> with Set Password in the browser. Identity type Machine sets Web service access only on save
> (checked in the instance's business rule). On that PDI, `snc_internal` didn't exist; the prompt
> handles that.

## Sources

- [Create a user](https://www.servicenow.com/docs/r/australia/platform-administration/user-administration/t_CreateAUser.html):
  Web service access only, Identity type, Set Password. Australia, updated 2026-03-12.
- [Non-interactive sessions](https://www.servicenow.com/docs/r/australia/platform-administration/user-administration/c_NonInteractiveSessions.html):
  non-interactive users can only authenticate API connections. Australia, updated 2026-03-12.
- Role names: read from a working admin integration user on the reference PDI (Australia),
  2026-10-07.
- [Claude Code setup](https://code.claude.com/docs/en/setup): installer, requirements, sign-in.
  Read 2026-10-07.
- macOS `security` man page: `-w` placed last prompts for the password instead of taking it on
  the command line.
