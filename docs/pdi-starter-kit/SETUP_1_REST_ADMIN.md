# Paste-in prompt — REST with admin

How to use this file:

1. Open Terminal and run these one at a time:
   ```
   mkdir -p ~/pdi-claude
   ```
   ```
   cd ~/pdi-claude
   ```
   ```
   claude
   ```
2. Copy lines 27 through 249 of this file. Line 27 starts `Set up access from Claude Code`. Line 249 is `  Try this next: "Which CI classes in my CMDB have the most records?"`
3. Paste it into Claude Code (Cmd+V) and press Return.
4. Do what Claude asks. It stops at each step marked **WAIT** until you answer.

Background, roles and troubleshooting: [Claude REST (with admin) guide](claude_rest_admin_guide.md).
Part of the [PDI starter kit](README.md).

> **Status — 2026-10-09.** Run end to end on 2026-10-08, every step passed (Sonnet 5.5, medium
> effort, fresh PDI). Wording fixes made after that run (Steps 2, 3, 5c, 6 and 8, and a helper
> newline) were not re-run.

~~~~copy next line to the end
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
- When you give me commands to run, put each on its own line and tell me to run them one at a
  time. Never join them with `&&` or commas.

STEP 1 — Instance name.
Ask me for my PDI instance name: the part before `.service-now.com`, e.g. `dev12345`. Ask it as a
plain question I type the answer to: no menu, no suggested or recommended name, even if other
context names a PDI. WAIT.
Then run, with no credentials:
  curl -sS -o /dev/null -w '%{http_code}\n' "https://<name>.service-now.com/api/now/table/sys_user?sysparm_limit=1"
401 means the instance is awake and REST answers. Anything else (200, 302, a timeout) usually
means the PDI is asleep: tell me to wake it from developer.servicenow.com, then run it again.

STEP 2 — The integration user (I do this in the browser).
Give me these steps to follow:
  In the PDI as admin: All > User Administration > Users > New.
  User ID `claude.integration`, First name `Claude`, Last name `Integration`.
    If the form has an Identity type field, set it to Machine; if it has none, leave it. Submit.
    Reopen the record and check that Web service access only is ticked; if it isn't, tell me.
    Reopen the record and use Set Password to give it a long random password. Copy it somewhere
    temporary, never into this chat.
    In the Roles related list, select Edit, add these roles and save:
      admin, itil_admin, asset, discovery_admin, snc_internal, acc_admin_for_global,
      agent_client_collector_admin, mid_server, cmdb_inst_admin
  If a role isn't offered in the list, the app that provides it isn't installed on my PDI. Skip
  it, note it for the Step 8 report, and carry on.
  (`snc_internal` comes from the Explicit Roles plugin; if it isn't offered, skip it.)
  If saving the admin role is refused, tell me to elevate to the security_admin role in the
  browser and try again.
WAIT until I say the user exists with its roles.

STEP 3 — Store the password in the macOS Keychain (I do this in a separate Terminal window).
Tell me to have the password from Step 2 copied, ready to paste, then to open a NEW Terminal
window, not this chat, and run this command. Nothing shows on screen as I paste the password:
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
        sys.stdout.write(json.dumps(scrub(json.loads(raw))) + "\n")
    except (ValueError, TypeError):
        # Not JSON (HTML error page, truncated body, auth challenge) — scrub anyway.
        sys.stdout.write(regex_fallback(raw).rstrip("\n") + "\n")


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
5c. Write path. Ask me first, then create a test incident with pdi_write POST, show me only
  its number and sys_id, and delete it again with pdi_write DELETE (expect HTTP 204).
A 401 on any test means the Keychain password doesn't match the one set on the instance, or the
account is locked out: have me check the user record and redo Step 3 with -U.

STEP 6 — Keep the rules for future sessions.
Write the lines between BEGIN and END to ~/pdi-claude/CLAUDE.md, with <name> replaced by my
instance name and nothing else changed. If the file already has a "## ServiceNow PDI access"
section, replace that section and keep the rest. Don't ask first. Afterwards, print the file
with cat so I can see it.
BEGIN
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
END

STEP 7 — Start the runbook.
Download the runbook template:
  curl -fsSL https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/docs/pdi-starter-kit/pdi_runbook_template.md -o ~/pdi-claude/pdi_runbook.md
Fill in section 1.1 (Access) from this session: instance name, integration user, Keychain
service name, helper path, the direct roles from Step 5b, and today's date as the verified date.
Leave every other placeholder as it is. Show me the filled section.

STEP 8 — Report.
Open with: "Congratulations — Claude Code is now connected to your PDI."
Summarise what now exists: the user and its roles (and any role that wasn't offered), the four
files in ~/pdi-claude, and the Keychain item.
Tell me how to start next time, as two separate commands:
  cd ~/pdi-claude
  claude
Starting there loads the rules in ~/pdi-claude/CLAUDE.md.
Mention once: to undo this setup later, see "Removing it" in claude_rest_admin_guide.md.
Finish with this line, word for word:
  Try this next: "Which CI classes in my CMDB have the most records?"
~~~~
