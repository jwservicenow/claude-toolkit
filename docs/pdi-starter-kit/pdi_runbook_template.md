# PDI runbook — <instance>.service-now.com

> **What this file is.** Claude's operating notes for your PDI: how to reach it, what's on it,
> and the traps already hit. Claude reads the section it needs before acting, and adds what it
> verifies. Part of the [PDI starter kit](https://github.com/jwservicenow/claude-toolkit/tree/main/docs/pdi-starter-kit).
>
> **Conventions.**
> - Every fact carries the date it was last checked live: `Verified YYYY-MM-DD`.
> - A fact copied from somewhere else and not checked on this instance is tagged
>   `UNVERIFIED (YYYY-MM-DD)`.
> - Keep the numbered headings. Claude finds sections by searching for them.
> - A fact read straight off the instance beats this file. When they disagree, fix this file.
> - Never put a password, token or key in this file.

---

## 0. How to use this runbook

- **Instance:** `<instance>.service-now.com`. Release: `<release>`. Verified `<date>`.
- Sections 3 and 4 are optional; delete them if you don't use MCP or AI agents.
- Put anything that bit you once in §10 Traps, with the section it belongs to.

---

## 1. Access

### 1.1 REST — always through `pdi-curl.sh`

```bash
source ~/pdi-claude/pdi-curl.sh
pdi '/api/now/table/<table>?sysparm_query=<encoded-query>&sysparm_fields=<f1,f2>'   # read
echo '{"field":"value"}' | pdi_write PATCH /api/now/table/<table>/<sys_id>          # write, body on stdin
```

| Item | Value |
|---|---|
| Integration user | `claude.integration` — admin, web-service-only |
| Direct roles | `<list from setup Step 5b>` |
| Keychain item | account `claude.integration`, service `servicenow-pdi-<instance>` |
| Helper | `~/pdi-claude/pdi-curl.sh` + `pdi-redact.py` |
| Verified | `<date>` |

- Never hand-build a curl to the instance. The helper strips password-type fields, which the
  Table API returns in clear text to an admin.
- Before any `pdi_write`: get approval, and check the user's current scope (§2).
- 401 → Keychain password and instance password don't match, or the user is locked out.

### 1.2 Key tables and queries

| What | Table | Query that works |
|---|---|---|
| `<e.g. servers>` | `<cmdb_ci_server>` | `<sys_class_name=cmdb_ci_linux_server^...>` |

### 1.3 UI and `.do` pages

- `<anything Claude can't do over REST and you do in the browser>`

---

## 2. Scope, update sets, check-in

- `claude.integration`'s current application scope: Global, the default — keep it there
  (`sys_user_preference` `name=apps.current_app`). Verified `<date>`.
- A REST insert lands in that scope, even when the body names another `sys_scope`. To create a
  record in a scoped app, switch the preference to it first and back to Global after.
- Update sets: `<which update set REST changes land in, if you track them>`.

---

## 3. MCP — optional

### 3.1 Servers

| Server name in Claude | URL | Tool count | Verified |
|---|---|---|---|
| `<sn-cmdb>` | `<https://<instance>.service-now.com/...>` | `<n>` | `<date>` |

### 3.2 OAuth client

| Field | Value |
|---|---|
| Application Registry record | `<name>` (`oauth_entity` sys_id `<sys_id>`) |
| Client type | confidential (client secret in the Keychain, never in a file) |
| Redirect | `http://localhost:33418/callback` |
| Token lifespans | access `<s>` · refresh `<s>` |
| Approving user | `<who signs in at the consent screen — every tool call runs as them>` |

### 3.3 Known gaps

- `<tool>` — `<what fails and the workaround>`

---

## 4. AI capabilities — optional

- Now Assist / AI agents active on this instance: `<list>`. Verified `<date>`.
- `<anything learned about AI Agent Studio, MCP Server Console, skills>`

---

## 5. ACC (Agent Client Collector)

### 5.1 Instance side — policies and checks

- Active policies: `<list>`. Verified `<date>`.
- Edits go to the policy's **draft**, then you republish in the UI. See §10.

### 5.2 Host side

| Host | OS | Agent status | Verified |
|---|---|---|---|
| `<host>` | `<os>` | `<Up/Down>` | `<date>` |

---

## 6. MID Servers

| MID | Host / OS | Status | Verified |
|---|---|---|---|
| `<name>` | `<host>` | `<Up/Down>` | `<date>` |

- How to reach the MID host: `<ssh / console / none>`.

---

## 7. Discovery

### 7.1 Credentials

| Credential record | Type | Used for |
|---|---|---|
| `<name>` | `<SSH / Windows / SNMP>` | `<which hosts>` |

(Names and types only. Never the secret.)

### 7.2 Schedules and ranges

| Schedule | Range / IPs | MID | Verified |
|---|---|---|---|
| `<name>` | `<range>` | `<mid>` | `<date>` |

### 7.3 Hosts that never produce a CI, by design

- `<ip>` — `<why>`

---

## 8. Event Management, AIOps, Health Log Analytics

- What's live: `<list>`. Verified `<date>`.

---

## 9. CMDB and asset data

### 9.1 Running a script on the instance

- `<how you run background scripts: you paste them, Claude writes them>`

### 9.2 Classes and counts

| Class | Count | Verified |
|---|---|---|
| `<cmdb_ci_linux_server>` | `<n>` | `<date>` |

---

## 10. Traps index

Seeded with traps seen on the reference PDI. Check each on yours, then keep or delete it.

| Trap | Detail | Verified |
|---|---|---|
| REST write returns 200 but nothing happens | A 200 means the row changed, not that the platform acted. Look for a draft/publish workflow or a gating business rule (§1, §5) | reference PDI, 2026-10-05 |
| REST insert lands in the wrong scope | It goes to the user's current application scope, whatever `sys_scope` the body names (§2) | reference PDI, 2026-10-06 |
| Table API returns `password2` fields in clear text | To an admin, on read and insert. The helper masks them; never bypass it (§1.1) | guard is code |
| A query on a parent class returns child classes | e.g. `cmdb_ci_computer` returns servers too. Pin `sys_class_name` in the query (§9) | reference PDI, 2026-10-06 |
| ACC: REST write to a *published* policy does nothing | Edit the policy's draft, then republish in the UI (§5.1) | reference PDI, 2026-10-05 |
| Removing a role from an ACL changes nothing | The role may still arrive by nesting, and Allow If ACLs never subtract. Use a Deny Unless ACL | reference PDI, 2026-10-06 |
| Bulk asset write with business rules turned off | The asset→CI sync is a business rule, so every CI is left stale (§9) | reference PDI, 2026-09-17 |
| MCP shows "Connected" / "Authentication successful" | Neither proves the server works. Make one real tool call (§3) | reference PDI, 2026-10-06 |
| MCP server added without the client secret | Sign-in looks successful, then the token exchange fails. Re-add it with the secret (§3.2) | reference PDI, 2026-09-22 |
| `<your trap>` | `<detail> (§n)` | `<date>` |

---

## 11. Linked docs

- `<other notes, scripts or exports Claude should know about>`
