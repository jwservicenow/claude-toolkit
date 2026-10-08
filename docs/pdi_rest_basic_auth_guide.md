# Connecting Claude Code to your PDI — REST Table API with Basic Auth

**What you'll end up with:** Claude Code reading and writing your ServiceNow personal developer
instance (PDI) through the REST Table API. Reads use an account the platform itself refuses to
let write. Writes use a second account, and Claude asks you before every one. Passwords live in
the macOS Keychain, never in a file, a command line or the chat.

**How you set it up:** install Claude Code (Part 1), then paste one prompt into it (Part 2).
The prompt walks you through the few browser steps only you can do, then writes and tests a
small helper. About 20 minutes.

**You need:** a Mac, a PDI where you have the `admin` role, and a Claude Pro, Max, Team or
Enterprise plan (the free plan doesn't include Claude Code).

> **Status — 2026-10-07.** The helper in the prompt was tested on macOS in bash and zsh against
> a local stub server. The tests covered a password with quotes, backslashes, `:` and `$`, the
> password never showing in the process list, a `password` field in a response coming back
> `<REDACTED>`, and a read method refused by `pdi_write`. The full prompt has not yet been run
> end to end against a fresh PDI.

**How this compares to the native MCP guide:**

| | This guide (REST, Basic Auth) | [Native MCP guide](pdi_native_mcp_install_guide.md) |
|---|---|---|
| What Claude can reach | Any table your accounts' roles can read, through the Table API | 36 purpose-built tools across five servers |
| How it signs in | Basic Auth as two integration users: one read-only, one for approved writes | OAuth; you approve in a browser |
| Actions recorded as | The two integration accounts | Your own ServiceNow login |
| Credentials stored where? | macOS Keychain only | macOS Keychain only |
| On your laptop | Two small files Claude writes from this guide | Nothing beyond Claude Code |
| Instance requirement | Any release | Australia / Zurich Patch 9+ with Now Assist |

The two complement each other: MCP for the guided tools, REST for any table they don't cover.

---

# Part 1 — Install Claude Code

Skip this part if `claude --version` already prints a version number in a terminal.

1. Open **Terminal** (Applications → Utilities).
2. Run Anthropic's installer:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
   If you use Homebrew, `brew install --cask claude-code` works too. Homebrew installs don't
   update themselves; run `brew upgrade claude-code` now and then.
3. Open a **new** Terminal window and run `claude --version`. A version number means it worked.
   If you get `command not found`, follow
   [Fix your PATH](https://code.claude.com/docs/en/troubleshoot-install#command-not-found-claude-after-installation).
4. Run `claude` and follow the browser prompts to sign in with your Claude account.

Requires macOS 13 or later. Full details:
[Claude Code setup](https://code.claude.com/docs/en/setup).

---

# Part 2 — Run the setup prompt

1. In Terminal, make a working folder and start Claude Code there:
   ```bash
   mkdir -p ~/pdi-claude && cd ~/pdi-claude && claude
   ```
2. Copy **everything** inside the block below and paste it into Claude Code.
3. Follow along. Claude stops and waits for you at each step marked **WAIT**.
   Keep your PDI open in a browser and logged in as admin.

What Claude will create:

- **On your instance:** two users, `claude.ro` and `claude.rw`, both web-service-only (they can't
  log in to the UI). No other changes.
- **On your Mac:** `~/pdi-claude/pdi-curl.sh` and `~/pdi-claude/pdi-redact.py`, two Keychain
  items, and (if you agree) a short rules section in `~/.claude/CLAUDE.md`.

~~~~text
Set up access from Claude Code to my ServiceNow personal developer instance (PDI) over the REST
Table API with Basic Auth, following the steps below in order. Stop at every step marked WAIT
until I reply.

Rules for this whole session:
- Never ask me to paste a password, token or key into this chat, and never print one. If one
  ever appears in the chat, stop and tell me to change that password on the instance.
- Never run `security find-generic-password` with `-w` or `-g` yourself. Only the helper
  functions read passwords.
- Every call to the instance goes through the helper functions `pdi_ro` and `pdi_write`. Never
  write a raw curl command to the instance (Step 1's unauthenticated check is the only exception).
- Use `pdi_ro` for every read. Before any `pdi_write`, show me the method, path and body and
  wait for my yes.
- Never give either account the admin role, and never change roles, ACLs or security settings on
  my instance unless I ask.

STEP 1 — Instance name.
Ask me for my PDI instance name: the part before `.service-now.com`, e.g. `dev12345`. WAIT.
Then run, with no credentials:
  curl -sS -o /dev/null -w '%{http_code}\n' "https://<name>.service-now.com/api/now/table/sys_user?sysparm_limit=1"
401 means the instance is awake and REST answers. Anything else (200, 302, a timeout) usually
means the PDI is asleep: tell me to wake it from developer.servicenow.com, then run it again.

STEP 2 — Two integration users (I do this in the browser).
Give me these steps to follow:
  In the PDI as admin: All > User Administration > Users > New.
  User 1: User ID `claude.ro`, First name `Claude`, Last name `Read only`.
    If the form has an Identity type field, set it to Machine (that ticks Web service access
    only for you). Otherwise tick Web service access only. Submit.
    Reopen the record and use Set Password to give it a long random password. Copy it somewhere
    temporary, never into this chat.
    In the Roles related list, select Edit, add `itil` and `snc_read_only`, and save.
  User 2: User ID `claude.rw`, First name `Claude`, Last name `Writer`. Same steps, but the only
    role is `itil`.
  If `snc_read_only` isn't offered in the role list, the Read-Only User Role plugin
  (com.snc.read_only.role) isn't active. Activate it from All > System Applications > All
  Available Applications > All, then add the role.
WAIT until I say both users exist.

STEP 3 — Store the passwords in the macOS Keychain (I do this in a separate Terminal window).
Tell me to open a NEW Terminal window, not this chat, and run these two commands. Each one asks
for the password without showing it:
  security add-generic-password -a claude.ro -s servicenow-pdi-<name> -w
  security add-generic-password -a claude.rw -s servicenow-pdi-<name> -w
If one says the item already exists, add -U to the command and run it again to replace it.
Tell me to clear the temporary copy of the passwords afterwards.
WAIT. Then confirm both items exist without reading the passwords:
  security find-generic-password -a claude.ro -s servicenow-pdi-<name> >/dev/null && echo "claude.ro found"
  security find-generic-password -a claude.rw -s servicenow-pdi-<name> >/dev/null && echo "claude.rw found"

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
#   pdi_ro '/api/now/table/incident?sysparm_limit=5'
#   echo '{"short_description":"x"}' | pdi_write POST /api/now/table/incident
#   pdi_write DELETE /api/now/table/incident/<sys_id>
PDI_INSTANCE="<your-instance>"
PDI_RO_USER="claude.ro"
PDI_RW_USER="claude.rw"
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

# Reads: the claude.ro account holds snc_read_only, so the platform refuses its writes.
pdi_ro() { _pdi_call "$PDI_RO_USER" GET "$1"; }

# Writes: separate account. Claude runs this only after you approve the exact call.
pdi_write() {
  case "$1" in
    POST|PUT|PATCH|DELETE) _pdi_call "$PDI_RW_USER" "$1" "$2" ;;
    *) echo "pdi_write: method must be POST, PUT, PATCH or DELETE" >&2; return 2 ;;
  esac
}
```
If macOS offers to install the command line developer tools when python3 first runs, tell me to
accept, then try again.

STEP 5 — Prove it works. Run each test and show me the output. Every call prints `HTTP <code>`.
5a. Read (no approval needed):
  source ~/pdi-claude/pdi-curl.sh && pdi_ro '/api/now/table/incident?sysparm_limit=1&sysparm_fields=number,short_description'
  Expect HTTP 200. An empty `{"result": []}` still counts as success.
5b. Read-only rail. Ask me first, then try a write as claude.ro. It must be refused:
  source ~/pdi-claude/pdi-curl.sh && echo '{"short_description":"Claude read-only test - should be refused"}' | _pdi_call "$PDI_RO_USER" POST /api/now/table/incident
  Expect HTTP 403. If it returns 201 instead, the rail is NOT working: stop, tell me, and (with
  my yes) delete the record it created using pdi_write DELETE.
5c. Write path. Ask me first, then create a test incident with pdi_write POST, show me its
  number and sys_id, and delete it again with pdi_write DELETE (expect HTTP 204).
A 401 on any test means the Keychain password doesn't match the one set on the instance: have me
redo Step 3 with -U for that account.

STEP 6 — Keep the rules for future sessions.
Show me this text and ask whether to add it to ~/.claude/CLAUDE.md. WAIT for my yes:
  ## ServiceNow PDI access
  - Instance: <name>.service-now.com. Calls go through `source ~/pdi-claude/pdi-curl.sh`, then
    `pdi_ro <path>` for reads and `pdi_write <METHOD> <path>` (JSON body on stdin) for writes.
  - Never hand-build a curl to the instance, and never read a password from the Keychain directly.
  - Never paste or print a password, token or key in chat.
  - Before any pdi_write, show me the method, path and body and wait for my yes.

STEP 7 — Report.
Summarise what now exists: the two users and their roles, the two files, the two Keychain items,
and whether CLAUDE.md was changed. Then tell me how to remove everything:
  1. In the PDI: All > User Administration > Users, open claude.ro and claude.rw, and clear
     Active (or delete the records).
  2. In Terminal:
       security delete-generic-password -a claude.ro -s servicenow-pdi-<name>
       security delete-generic-password -a claude.rw -s servicenow-pdi-<name>
  3. Delete the ~/pdi-claude folder, and the "ServiceNow PDI access" section from
     ~/.claude/CLAUDE.md if it was added.
~~~~

---

## Everyday use

Ask Claude in plain words: *"List the 10 newest incidents"*, *"Which CIs in cmdb_ci_server have
no serial number?"*, *"Set the short description of INC0010001 to …"*. Claude reads with
`pdi_ro` straight away and asks before any `pdi_write`.

When Claude Code asks permission to run a command, approve `pdi_write` calls one at a time.
Don't choose the option that stops it asking for those.

## What the safety rails are

| Rail | What it stops |
|---|---|
| `claude.ro` holds `snc_read_only` | The platform blocks creating, updating and deleting on any table for that account, whatever Claude sends. Step 5b proves it on your instance |
| Separate `claude.rw` account | Writes are a different identity, easy to spot in the audit history and easy to switch off (deactivate the user) |
| Web service access only on both | Neither account can log in to the UI or a portal |
| No `admin` on either | A wrong write can only touch what `itil` allows |
| Keychain, read per call | No password in a file, a command line, shell history or the chat |
| Redaction filter on every response | Password-type fields an account can read come back as `<REDACTED>` |
| Claude asks before every write | You see method, path and body before anything changes |

## Troubleshooting

- **`HTTP 401`**: the Keychain password and the instance password don't match, or the account
  is locked out after failed attempts. Reset the password on the user record, then re-run the
  Step 3 command with `-U`. Check that the user's **Locked out** box is clear.
- **`HTTP 403` on a read**: the account's roles don't cover that table. Add the role that
  table needs (not `admin`) to `claude.ro`.
- **HTML instead of JSON, or a timeout**: the PDI is probably asleep. Wake it from
  developer.servicenow.com.
- **`pdi: no keychain item`**: the Keychain item's account or service name doesn't match
  `pdi-curl.sh`. The service name must be `servicenow-pdi-<your-instance>`.

## Removing it

1. In the PDI: open each of `claude.ro` and `claude.rw` (All → User Administration → Users) and
   clear **Active**, or delete the records.
2. On the Mac:
   ```bash
   security delete-generic-password -a claude.ro -s servicenow-pdi-<your-instance>
   security delete-generic-password -a claude.rw -s servicenow-pdi-<your-instance>
   ```
3. Delete the `~/pdi-claude` folder, and the "ServiceNow PDI access" section from
   `~/.claude/CLAUDE.md` if you added it.

## Sources

- [Create a user](https://www.servicenow.com/docs/r/australia/platform-administration/user-administration/t_CreateAUser.html):
  Web service access only, Identity type, Set Password. Australia, updated 2026-03-12.
- [Non-interactive sessions](https://www.servicenow.com/docs/r/australia/platform-administration/user-administration/c_NonInteractiveSessions.html):
  non-interactive users can only authenticate API connections. Australia, updated 2026-03-12.
- [Read-only role](https://www.servicenow.com/docs/r/australia/platform-administration/user-administration/c_ReadOnlyRole.html):
  `snc_read_only` blocks insert, update and delete on any table; the `com.snc.read_only.role`
  plugin. Australia, updated 2026-03-12.
- [Claude Code setup](https://code.claude.com/docs/en/setup): installer, requirements, sign-in.
  Read 2026-10-07.
- macOS `security` man page: `-w` placed last prompts for the password instead of taking it on
  the command line.
