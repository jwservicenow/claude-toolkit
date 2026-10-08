# Connecting Claude Code to your PDI — REST Table API with Basic Auth

Part of the [PDI starter kit](README.md).

**Start with the [three setup steps in the README](README.md#setup).** Step 3 sends you here
for The Prompt. Everything below it is reference.

## The Prompt

Copy everything in this block (GitHub shows a copy button at its top right) and paste it into
Claude Code. Claude stops and waits for you at each step marked **WAIT**.

~~~~text
Set up access from Claude Code to my ServiceNow personal developer instance (PDI) over the REST
Table API with Basic Auth, following the steps below in order. Stop at every step marked WAIT
until I reply.

Rules for this whole session:
- Never ask me to paste a password, token or key into this chat, and never print one. If one
  ever appears in the chat, stop and tell me to change that password on the instance.
- Never run `security find-generic-password` with `-w` or `-g` yourself. Only the helper
  functions read the password.
- Every call to the instance goes through the helper functions `pdi` and `pdi_write`. Never
  write a raw curl command to the instance (Step 1's unauthenticated check is the only exception).
- Reads with `pdi` need no approval. Before any `pdi_write`, show me the method, path and body
  and wait for my yes.
- The integration user is admin. Never change roles, ACLs or security settings on my instance
  unless I ask.

STEP 1 — Instance name.
Ask me for my PDI instance name: the part before `.service-now.com`, e.g. `dev12345`. Ask it as a
plain question I type the answer to: no menu, no suggested or recommended name, even if other
context names a PDI. WAIT.
Then run, with no credentials:
  curl -sS -o /dev/null -w '%{http_code}\n' "https://<name>.service-now.com/api/now/table/sys_user?sysparm_limit=1"
401 means the instance is awake and REST answers. Anything else (200, 302, a timeout) usually
means the PDI is asleep: tell me to wake it from developer.servicenow.com, then run it again.

STEP 2 — The integration user (I do this in the browser).
Ask me whether I want the optional MCP roles, the optional AI roles, both or neither. In the
question, list every role name in each group (from the lists below), never just a count. WAIT.
Then give me these steps to follow:
  In the PDI as admin: All > User Administration > Users > New.
  User ID `claude.integration`, First name `Claude`, Last name `Integration`.
    If the form has an Identity type field, set it to Machine (the instance then sets Web
    service access only when you submit). Otherwise tick Web service access only. Submit.
    Reopen the record and use Set Password to give it a long random password. Copy it somewhere
    temporary, never into this chat.
    In the Roles related list, select Edit and add these core roles:
      admin, itil_admin, asset, discovery_admin, snc_internal, acc_admin_for_global,
      agent_client_collector_admin, mid_server, cmdb_inst_admin
    plus, if I chose them,
      MCP: sn_mcp_server.admin, sn_mcp_server.tools_admin, sn_mcp_client.admin,
           sn_mcp_client.viewer, sn_mcp_registry.mcp_registry_read,
           sn_mcp_registry.mcp_registry_write, sn_fd_genai.mcp_fd_admin,
           sn_sm_gen_ai.sm_mcp_admin
      AI:  ai_agent_resource_admin, ai_native_experience_analytics_admin, ai_security_admin,
           ai_user_admin
    and save.
  If a role isn't offered in the list, the app that provides it isn't installed on my PDI. Tell
  me which ones were missing so I can install that app or skip the role, and carry on.
  (`snc_internal` comes from the Explicit Roles plugin; if it isn't offered, skip it.)
  If saving the admin role is refused, tell me to elevate to the security_admin role in the
  browser and try again.
WAIT until I say the user exists with its roles.

STEP 3 — Store the password in the macOS Keychain (I do this in a separate Terminal window).
Tell me to open a NEW Terminal window, not this chat, and run this command. It asks for the
password without showing it:
  security add-generic-password -a claude.integration -s servicenow-pdi-<name> -w
If it says the item already exists, add -U to the command and run it again to replace it.
Tell me to clear the temporary copy of the password afterwards.
WAIT. Then confirm the item exists without reading the password:
  security find-generic-password -a claude.integration -s servicenow-pdi-<name> >/dev/null && echo "claude.integration found"

STEP 4 — Write the helper files.
Create ~/pdi-claude/ if it doesn't exist and write the two files below exactly as given. The
only change allowed: replace <your-instance> in pdi-curl.sh with my instance name. Show me the
one changed line afterwards.

File 1: ~/pdi-claude/pdi-redact.py
```python
#!/usr/bin/env python3
"""Scrub credential values out of ServiceNow Table API responses.

ServiceNow returns password2 fields (api_key, password, ssh_passphrase, ...) in
CLEARTEXT to an admin-authenticated caller on both read and insert. This filter
sits between curl and stdout so those values can never reach a terminal, a log,
or a chat transcript, regardless of who wrote the calling command.

Reads stdin, writes stdout. Fails closed: anything it cannot parse is scrubbed
by regex rather than passed through.
"""
import json
import re
import sys

SECRET_FIELDS = {
    "api_key", "password", "password2", "ssh_passphrase", "ssh_private_key",
    "privacy_key", "authentication_key", "secret", "client_secret",
    "token", "access_token", "refresh_token", "private_key", "passphrase",
}
MASK = "<REDACTED>"


def is_secret(key):
    # suffix match catches dot-walked (credential.password) and custom (u_api_key) fields
    k = key.lower()
    return any(k == f or k.endswith("." + f) or k.endswith("_" + f) for f in SECRET_FIELDS)


def scrub(obj):
    if isinstance(obj, dict):
        return {
            k: (MASK if is_secret(k) and v not in ("", None) else scrub(v))
            for k, v in obj.items()
        }
    if isinstance(obj, list):
        return [scrub(x) for x in obj]
    return obj


def regex_fallback(text):
    for f in SECRET_FIELDS:
        text = re.sub(
            rf'("{re.escape(f)}"\s*:\s*)"[^"]*"',
            rf'\1"{MASK}"',
            text,
            flags=re.IGNORECASE,
        )
    return text


def main():
    raw = sys.stdin.read()
    if not raw.strip():
        return
    try:
        sys.stdout.write(json.dumps(scrub(json.loads(raw))))
    except (ValueError, TypeError):
        # Not JSON (HTML error page, truncated body, auth challenge) — scrub anyway.
        sys.stdout.write(regex_fallback(raw))


if __name__ == "__main__":
    main()
```

File 2: ~/pdi-claude/pdi-curl.sh
```bash
# Claude Code helper for a ServiceNow PDI: REST Table API over Basic Auth.
#   source ~/pdi-claude/pdi-curl.sh
#   pdi '/api/now/table/incident?sysparm_limit=5'
#   echo '{"short_description":"x"}' | pdi_write POST /api/now/table/incident
#   pdi_write DELETE /api/now/table/incident/<sys_id>
PDI_INSTANCE="<your-instance>"
PDI_USER="claude.integration"
PDI_KC_SERVICE="servicenow-pdi-${PDI_INSTANCE}"
PDI_DIR="$HOME/pdi-claude"

# The password reaches curl as a config file on a pipe, so it never appears in argv (ps) or history.
# Every response passes through pdi-redact.py. There is deliberately no bypass.
_pdi_call() {
  local user="$1" method="$2" path="$3" pw
  local -a body
  body=()
  [[ "$path" != /* ]] && path="/$path"
  pw=$(/usr/bin/security find-generic-password -a "$user" -s "$PDI_KC_SERVICE" -w 2>/dev/null) \
    || { echo "pdi: no keychain item for account $user, service $PDI_KC_SERVICE" >&2; return 1; }
  pw=${pw//\\/\\\\}; pw=${pw//\"/\\\"}
  case "$method" in POST|PUT|PATCH) body=(-H 'Content-Type: application/json' --data-binary @-) ;; esac
  /usr/bin/curl -sS -K <(printf 'user = "%s:%s"\n' "$user" "$pw") \
    -X "$method" -H 'Accept: application/json' "${body[@]}" \
    -w '%{stderr}HTTP %{http_code}\n' \
    "https://${PDI_INSTANCE}.service-now.com${path}" | /usr/bin/python3 "$PDI_DIR/pdi-redact.py"
}

# Reads.
pdi() { _pdi_call "$PDI_USER" GET "$1"; }

# Writes. Claude runs this only after you approve the exact call.
pdi_write() {
  case "$1" in
    POST|PUT|PATCH|DELETE) _pdi_call "$PDI_USER" "$1" "$2" ;;
    *) echo "pdi_write: method must be POST, PUT, PATCH or DELETE" >&2; return 2 ;;
  esac
}
```
If macOS offers to install the command line developer tools when python3 first runs, tell me to
accept, then try again.

STEP 5 — Prove it works. Run each test and show me the output. Every call prints `HTTP <code>`.
5a. Read (no approval needed):
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/incident?sysparm_limit=1&sysparm_fields=number,short_description'
  Expect HTTP 200. An empty `{"result": []}` still counts as success.
5b. Roles. List the roles given directly to the integration user:
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/sys_user_has_role?sysparm_query=user.user_name%3Dclaude.integration%5Einherited%3Dfalse&sysparm_fields=role.name&sysparm_limit=100'
  Expect HTTP 200. Compare the list against the roles from Step 2 and tell me any that are
  missing.
5c. Write path. Ask me first, then create a test incident with pdi_write POST, show me its
  number and sys_id, and delete it again with pdi_write DELETE (expect HTTP 204).
A 401 on any test means the Keychain password doesn't match the one set on the instance, or the
account is locked out: have me check the user record and redo Step 3 with -U.

STEP 6 — Keep the rules for future sessions.
Show me this text and ask whether to add it to ~/.claude/CLAUDE.md. WAIT for my yes:
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

STEP 7 — Start the runbook.
Download the runbook template:
  curl -fsSL https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/docs/pdi-starter-kit/pdi_runbook_template.md -o ~/pdi-claude/pdi_runbook.md
Fill in section 1.1 (Access) from this session: instance name, integration user, Keychain
service name, helper path, the direct roles from Step 5b, and today's date as the verified date.
Leave every other placeholder as it is. Show me the filled section.

STEP 8 — Report.
Summarise what now exists: the user and its roles, the three files, the Keychain item, and
whether CLAUDE.md was changed. Then tell me how to remove everything:
  1. In the PDI: All > User Administration > Users, open claude.integration, and clear Active
     (or delete the record).
  2. In Terminal:
       security delete-generic-password -a claude.integration -s servicenow-pdi-<name>
  3. Delete the ~/pdi-claude folder, and the "ServiceNow PDI access" section from
     ~/.claude/CLAUDE.md if it was added.
~~~~

---

## What The Prompt creates

- **On your instance:** one user, `claude.integration`, web-service-only (it can't log in to the
  UI), holding the roles below. No other changes.
- **On your Mac:** `~/pdi-claude/pdi-curl.sh`, `~/pdi-claude/pdi-redact.py`,
  `~/pdi-claude/pdi_runbook.md`, one Keychain item, and (if you agree) a short rules section in
  `~/.claude/CLAUDE.md`.

**Roles for `claude.integration`:**

| | Roles |
|---|---|
| Core (always) | `admin`, `itil_admin`, `asset`, `discovery_admin`, `snc_internal` (if offered), `acc_admin_for_global`, `agent_client_collector_admin`, `mid_server`, `cmdb_inst_admin` |
| Optional — MCP | `sn_mcp_server.admin`, `sn_mcp_server.tools_admin`, `sn_mcp_client.admin`, `sn_mcp_client.viewer`, `sn_mcp_registry.mcp_registry_read`, `sn_mcp_registry.mcp_registry_write`, `sn_fd_genai.mcp_fd_admin`, `sn_sm_gen_ai.sm_mcp_admin` |
| Optional — AI | `ai_agent_resource_admin`, `ai_native_experience_analytics_admin`, `ai_security_admin`, `ai_user_admin` |

Add the optional roles only if you'll use Claude for MCP or AI agent work on the instance.

---

## Everyday use

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
3. Delete the `~/pdi-claude` folder, and the "ServiceNow PDI access" section from
   `~/.claude/CLAUDE.md` if you added it.

## How this compares to the native MCP guide

| | This guide (REST, Basic Auth) | [Native MCP guide](pdi_native_mcp_install_guide.md) |
|---|---|---|
| What Claude can reach | Any table, through the Table API | 36 purpose-built tools across five servers |
| How it signs in | Basic Auth as one admin integration user | OAuth; you approve in a browser |
| Actions recorded as | The integration user | Whoever approved in the browser |
| Credentials stored where? | macOS Keychain only | macOS Keychain only |
| On your laptop | Two small files Claude writes from this guide | Nothing beyond Claude Code |
| Instance requirement | Any release | Australia / Zurich Patch 9+ with Now Assist |

The two complement each other: MCP for the guided tools, REST for any table they don't cover.

## Status

> **Status — 2026-10-07.** The full prompt was run end to end on a second Australia PDI in a fresh
> Claude Code session: every step passed, including the Step 5c write (create HTTP 201, delete 204).
> In that run the user record and role grants were made over REST as admin rather than in the
> browser; the password was set with Set Password in the browser. Identity type Machine sets Web
> service access only on save (checked in the instance's business rule). On that PDI, 5 of the 21
> roles didn't exist (`snc_internal` and 4 MCP roles); the prompt handles that.

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
