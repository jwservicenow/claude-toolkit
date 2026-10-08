# Connecting Claude Code to your PDI — Platform-Native MCP Path

**What you'll end up with:** Claude Code connected to your ServiceNow instance using the
platform's own built-in connector — no Python script on your laptop, no passwords in plain-text
files. You can search the CMDB, manage incidents and investigate alerts by typing in plain English.
(MID Servers, Discovery and agents are not covered by the native servers — see Known issues.)

**Who this is for:** This guide has two parts: a ServiceNow administrator sets up the instance
side (Part 2), and the Claude Code user wires up their machine (Part 3). Both steps can be done
by the same person.

> **Status — 2026-10-06.** The OAuth client settings, server list, URLs and tool counts in this
> guide were re-read from a live Australia-release instance on 2026-10-06. Earlier versions
> described a public PKCE client with no secret, and three servers with 17 tools; that is not
> what the working setup looks like today. The click-paths and button names in Part 2 date from
> June 2026 and have not been re-walked since — confirm them on screen.

Part of the [PDI starter kit](README.md) — optional.

**How this compares to the [REST Basic Auth guide](pdi_rest_basic_auth_guide.md):**

| | REST guide (Table API, Basic Auth) | This guide (native MCP) |
|---|---|---|
| Something to install on your laptop? | Two small files Claude writes from the guide | No — runs inside ServiceNow |
| Credentials stored where? | macOS Keychain only | macOS Keychain only |
| How it logs in | Basic Auth as one admin integration user; Claude asks before every write | You approve in a browser; the OAuth client secret is kept in the macOS Keychain |
| Actions recorded as | The integration user | Your own ServiceNow login |
| Tools available | Any table, through the Table API | 36 purpose-built tools across five servers (CMDB, ITSM, ITOM and two general ones) |
| Instance requirement | Any release | Australia / Zurich Patch 9+ with Now Assist |

**How long it takes:** 15–25 minutes if the ServiceNow apps are already installed. Add 20–30
minutes if a ServiceNow admin needs to install them first.

**Platform requirement:** ServiceNow Australia release (Zurich Patch 9 or newer). The tool
suites below are edition-gated — see Part 2, Step 1 for details. If your instance doesn't meet
these requirements, the [REST Basic Auth guide](pdi_rest_basic_auth_guide.md) works on any release.

---

## Before You Start — What You'll Need

| You'll need | Covered in |
|---|---|
| A Claude account with a paid plan | Part 1 |
| Claude Code installed and signed in | Part 1 |
| A ServiceNow instance on Australia / Zurich Patch 9+ | Your ServiceNow admin |
| MCP Server apps installed on the instance | Part 2, Step 1 |
| An OAuth client created on the instance | Part 2, Step 3 |
| The client ID (32 characters) and client secret from that OAuth record | Part 2, Step 3 |
| Your ServiceNow login credentials | Used during first-time browser approval (Part 3) |

---

# Part 1 — Installing Claude Code

If you already have Claude Code installed and `claude --version` prints a version number in a
terminal, skip to Part 2.

Otherwise, follow **Part 1** of the [REST Basic Auth guide](pdi_rest_basic_auth_guide.md#part-1--install-claude-code).
It covers the plan you need, installing Claude Code and signing in. The installation is the same
for both guides.

Return here after completing that Part 1.

---

# Part 2 — Preparing Your ServiceNow Instance

> **Role:** ServiceNow administrator. These steps happen inside your ServiceNow instance, not on
> your laptop. If you are not a ServiceNow admin, ask one to complete Part 2 and hand you the
> client ID, client secret and server URLs (Steps 3–4) before you begin Part 3.

---

## Step 1 — Install the Required Apps

The native MCP connector runs entirely inside ServiceNow. The tools come from Store apps that
must be installed on your instance.

**Edition and licensing note:** The CMDB and ITSM tool suites require Now Assist licensing.
The ITOM alert and reliability tools require ITOM Advanced or AIOps licensing. If your instance
doesn't have these licenses, the apps may install but their tools won't be accessible. Check with
your ServiceNow account team before proceeding.
*Source: [MCP Server Console FAQ][faq]*

### Install from the ServiceNow Store

In your ServiceNow instance:

1. Click **All** in the left navigation bar
2. In the filter box, type **System Applications** and click it when it appears
3. Click **All Available Applications → All**
4. Search for each app in the table below and install it:

| App | What it provides |
|---|---|
| **MCP Server Console** (`sn_mcp_server`; the instance lists it as "Model Context Protocol Server") | The base framework — install this first; all others depend on it. Also supplies two general-purpose servers |
| **CMDB MCP Server** (`sn_cmdb_mcp_server`) | CMDB search, CI creation, application-service lookups |
| **ITOM MCP Server** (`sn_itom_mcp_server`) | Alert triage, investigation, service reliability, SLO tools |
| **ITSM MCP Server** (`sn_itsm_mcp_server`) | Incident and request management, user lookup, assignment group lookup |

> **Source note for app names:** `MCP Server Console` (`sn_mcp_server`) is confirmed in
> official ServiceNow documentation ([Australia release][docs-mcp-client];
> [cross-instance setup community guide][cross-instance]). The three domain apps are the
> application names recorded against each registry row on a live Australia-release PDI
> (the reference PDI), read 2026-10-06 — CMDB MCP Server 1.0.1, ITOM MCP Server 1.0.1,
> ITSM MCP Server 3.2.3. Their Store listing names were not independently confirmed; verify them
> against your instance's Store.
>
> **An older CMDB server may also be in the registry** —
> `sn_cmdb_gen_ai.now_assist_cmdb_mcp_server`, which ships with the Now Assist (Otto) for CMDB
> plugin. A Store update marked it deprecated in September 2026. Use the CMDB MCP Server app.

When each app installs, it automatically creates a row in the MCP server registry and registers
its tools. You do not need to define any tools manually in the MCP Server Console for these
built-in suites.

---

## Step 2 — Verify and Activate the Registry Rows

Each app creates one or more rows in the internal server registry. These rows must be in **Active** status
before Claude Code can connect to them.

1. In the Application Navigator (the filter box, top-left), type:
   ```
   sn_mcp_server_registry.list
   ```
   Press Enter. This opens the registry table directly.

2. You should see rows like the ones below. Check the **Status** column for each:

| Registry row name | Expected status |
|---|---|
| `sn_cmdb_mcp_server.cmdb_mcp_server` | Active |
| `sn_genai.itom_mcp_server` | Active |
| `sn_itsm_mcp_server.itsm_default` | Active |
| `sn_mcp_server.default` | Active |
| `sn_mcp_server.moveworks_default` | Active |

3. If a row shows **Draft** or **Inactive**, open it and click **Activate**. A server installed
   from the Store arrives as Draft. On the reference instance the CMDB MCP Server was activated
   from the MCP Server Console's server list, with the application scope set to that server's
   own app (September 2026).

> **Known issue — "Activate" button fails in some patch levels:** The Activate button calls an
> internal method (`McpServerUtils.publishTools()`) that may not exist in certain versions.
> If you see a script error, activate the row using the REST API instead. Open a terminal and run:
>
> ```bash
> curl -u "YOUR-ADMIN-USER" -X PATCH \
>   "https://YOUR-INSTANCE.service-now.com/api/now/table/sn_mcp_server_registry/SYS-ID-HERE" \
>   -H "Content-Type: application/json" \
>   -d '{"status":"active"}'
> ```
>
> curl asks for the password, so it never lands in your shell history. Replace `SYS-ID-HERE` with the `sys_id` of the registry row — it appears in the URL when you
> open the record (the value after `sys_id=`).
>
> Also check the tool association rows. Open the registry record, find the **Tool Definitions**
> related list, and confirm each tool shows **Enabled = true**. If not, select all rows → right-
> click → Update → set `Enabled` to `true`.
>
> *This REST workaround was used on the reference PDI in June 2026, before that instance was rebuilt.
> It has not been re-tested since — treat it as a fallback. Writing registry or tool rows may
> need the `sn_mcp_server.admin` and `sn_mcp_server.tools_admin` roles, not just `admin`.*

---

## Step 3 — Create the OAuth Client

Claude Code authenticates using the **OAuth 2.0 authorization code flow with a confidential
client**. Claude Code opens a browser window and you personally approve the connection — just
like "Log in with Google." The client also has a **client secret**: Claude Code asks for it once
when you add a server and keeps it in the macOS Keychain, never in a file.

> **Changed from earlier versions of this guide.** They described a public client with PKCE and
> no secret. The setup verified working on 2026-10-06 is a confidential client with PKCE off. A
> server added without the secret appears to sign in — the browser says the authentication
> succeeded — and then fails at the token exchange.

You create one OAuth client in ServiceNow, and all five MCP servers share it.

### Create the Application Registry record

1. Go to: **All** → filter for **Application Registry** → open **System OAuth → Application Registry**
2. Click **New** → choose **"Create an OAuth API endpoint for external clients"**
3. Fill in the form with the values below:

| Field | Value | Notes |
|---|---|---|
| Name | `Claude Code` | Any descriptive name |
| Client ID | *(auto-generated — copy after saving)* | 32-character hex string |
| Client Secret | *(auto-generated — copy after saving)* | Required. Hand it over securely — never by chat or email |
| **Public client** | ☐ unchecked | This is a confidential client — the secret is required |
| **Use PKCE** | ☐ unchecked | Off on the verified record |
| Code challenge method | *(ignore)* | `S256` may be shown; it does nothing while Use PKCE is off |
| Inbound grant type | Authorization Code | See note below — not client_credentials |
| Redirect URL | `http://localhost:33418/callback` | Must match the callback port used in Part 3 exactly |
| Access token lifespan | `1800` | 30 minutes |
| Refresh token lifespan | `8640000` | 100 days |
| Token format | `JWT` | |

> **Why `authorization_code`, not `client_credentials`?** `client_credentials` is designed for
> background scripts that hold a stored secret. This guide uses
> `authorization_code` because Claude Code is a desktop app — it opens a browser window and you
> personally approve the connection, so every action runs as you. The client secret identifies
> the app, not the user, and stays in the Keychain.
> Client Credentials grant is not currently available for the MCP Server Console.
> *Source: [MCP Server Console FAQ][faq]*

> **Why port 33418?** Claude Code listens on localhost port 33418 for the OAuth callback.
> ServiceNow redirects your browser to that address after you approve access. The redirect URL
> must match exactly — if you change the port here, the OAuth flow will fail.

4. Click **Submit**. ServiceNow generates the Client ID and the Client Secret.
5. Open the record that was just created and copy the **Client ID** (the 32-character string) and
   the **Client Secret** (the field is masked on the record). You will need both in Part 3. Treat
   the secret like a password: do not paste it into chat, email or a file.

> **Field verification:** The values above — `public_client`, `use_pkce`, the inbound grant type,
> redirect URL, token lifespans and token format — were read live from the working Application
> Registry record on the reference PDI (Australia release) on 2026-10-06.

> **Scope restriction:** Leave scope restriction at its default (broadly scoped) during initial
> setup. Narrowing OAuth scopes requires additional configuration (`oauth_entity_scope` records);
> if those aren't in place first, the token will fail to retrieve tools from some servers. See
> [KB2820840][kb2820840] for scope configuration details (requires Now Support login).

---

## Step 4 — Note Your Server URLs

Each tool suite has its own MCP server URL. Copy these — you will paste them into terminal
commands in Part 3. The pattern is:

```
https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/<registry-row-name-with-dots-as-underscores>
```

| Claude Code server name | URL |
|---|---|
| `sn-cmdb` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_mcp_server_cmdb_mcp_server` |
| `sn-itom` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_genai_itom_mcp_server` |
| `sn-itsm` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_itsm_mcp_server_itsm_default` |
| `sn-quickstart` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_mcp_server_default` |
| `sn-moveworks` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_mcp_server_moveworks_default` |

Replace `YOUR-INSTANCE` with your instance's subdomain (e.g. `yourcompany` for
`yourcompany.service-now.com`).

**To confirm your exact URLs:** Open each registry row in `sn_mcp_server_registry` and look at
the **Name** field. The URL is that name with dots converted to underscores, appended to the base
path above.

### Pre-flight check (recommended)

Before leaving the instance, confirm the `/sncapps/mcp-server` routing path is enabled. Run the
following in a terminal — you should get **HTTP 401** (unauthorized), not 404:

```bash
curl -s -o /dev/null -D - -X POST "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_mcp_server_cmdb_mcp_server"
```

A `404` means the routing path isn't enabled on your instance. If that happens, contact
ServiceNow Support and ask them to enable the `/sncapps/mcp-server` path forwarding.
*Source: [Cross-instance MCP setup][cross-instance]*

---

Part 2 is complete. Hand the **client ID** and **client secret** (from Step 3) and the five
**server URLs** (from Step 4) to whoever will do the Claude Code setup — the secret by a secure
channel, not chat or email.

---

# Part 3 — Connecting Claude Code

> **Role:** The person using Claude Code on their laptop. You'll need the client ID, client secret
> and server URLs from Part 2.

---

## Step 5 — Add the MCP Servers

Open a terminal. Run one command per server, replacing `YOUR-CLIENT-ID` and `YOUR-INSTANCE` with
your actual values. Each command stops and prompts for the client secret — paste it at the prompt.

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID --client-secret \
  --callback-port 33418 \
  sn-cmdb \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_mcp_server_cmdb_mcp_server"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID --client-secret \
  --callback-port 33418 \
  sn-itom \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_genai_itom_mcp_server"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID --client-secret \
  --callback-port 33418 \
  sn-itsm \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_itsm_mcp_server_itsm_default"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID --client-secret \
  --callback-port 33418 \
  sn-quickstart \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_mcp_server_default"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID --client-secret \
  --callback-port 33418 \
  sn-moveworks \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_mcp_server_moveworks_default"
```

Each command writes an entry into Claude Code's configuration file (`~/.claude.json` or your
profile's config file) and hands the client secret to Claude Code to keep in the macOS Keychain.
No Python, no scripts, no `.env` file.

> **Multiple profiles (personal vs. work Claude accounts):** If you have separate personal and
> work Claude Code profiles, add a scope flag to control which config gets the entry (`-s user`
> is the form verified for this guide). Run `claude mcp add --help` to see the scope options.

> **Don't hand-edit the config file instead.** An entry typed straight into `~/.claude.json` has
> no client secret behind it. The browser still reports a successful sign-in, but the token
> exchange fails and the instance's system log records `Exception on token flow - client_secret`.
> Add servers with `claude mcp add … --client-secret`.

---

## Step 6 — Approve Access (First Run)

The first time Claude Code tries to connect to the MCP servers, it opens a browser and asks you
to approve access.

Start Claude Code:

```bash
claude
```

When Claude Code starts, your browser will automatically open to your ServiceNow instance's login
page (the URL looks like `https://YOUR-INSTANCE.service-now.com/oauth_auth.do?...`).

1. **Log in** to your ServiceNow instance with your normal username and password
2. ServiceNow shows a consent screen asking if Claude Code can act on your behalf — click **Allow**
3. Your browser redirects to `localhost:33418/callback` and shows a success message
4. Return to your terminal — Claude Code is now authenticated

**This only happens once.** Claude Code stores the resulting tokens in your macOS Keychain (not
in any file on disk). For the next 100 days it silently refreshes access every 30 minutes — you
won't be prompted again unless the refresh window expires.

> **What just happened:** ServiceNow issued a short-lived access token (30 minutes) and a
> long-lived refresh token (100 days). The tokens are tied to the account you logged in as —
> every action Claude takes in ServiceNow is recorded against your user, not a shared service
> account. If you want to revoke Claude's access at any time, go to ServiceNow's Application
> Registry record and click **Revoke tokens**.
> *Source: [OAuth refresh-token expiration patterns][oauth-patterns]*

> **Browser doesn't open automatically?** Copy the authorization URL printed in the terminal and
> paste it into your browser manually.

> **This happens once per server.** Expect to approve each of the five servers. Inside Claude
> Code, `/mcp` starts the sign-in for a server that has not prompted yet.

---

## Step 7 — Verify the Connection

Check that all servers connected:

```bash
claude mcp list
```

All five servers — `sn-cmdb`, `sn-itom`, `sn-itsm`, `sn-quickstart` and `sn-moveworks` — should
be listed as connected. If one is not, see the Troubleshooting section.

**Connected only proves the handshake** — not that sign-in worked or that the tools return data.
Make one real call.

Now test it end-to-end in a Claude Code session. Open Claude Code and ask:

```
List the application services in the CMDB
```

Claude will call the `get_all_application_service_names` tool and return the service names. If
results come back, the setup is working.

---

## Verification Tests

One call per server, each made on the reference PDI (Australia release) on 2026-10-06.
The prompts are examples; what was verified is the tool call and that it returned data.

| Server | Example prompt | Tool it should call | Result that day |
|---|---|---|---|
| `sn-cmdb` | `List the application services in the CMDB` | `get_all_application_service_names` | 55 services |
| `sn-itom` | `List the 5 most recent alerts` | `list_alert_records` | 5 alerts |
| `sn-itsm` | `Look up assignment groups matching Network` | `lookup_assignment_groups` | 3 groups |
| `sn-quickstart` | `Look up 5 incident records` | `look_up_incident_records` | 5 incidents |
| `sn-moveworks` | `How many incidents are there?` | `enterprise_graph` | a count |

### More prompts — last run 2026-06-05, not re-run since the instance was rebuilt

#### Alerts — sn-itom

| Prompt | Expected result |
|---|---|
| `Analyze alert [number]` | AI-generated analysis with brief and recommended steps — check specifics such as drive letters and percentages against the alert data; the analysis can invent them |
| `What is the impact of alert [number]?` | Count and names of impacted service instances |
| `What are the alert investigation findings for [number]?` | Historical incident context; an empty result when the alert has no linked incidents is expected, not an error |

#### Incidents — sn-itsm

| Prompt | Expected result |
|---|---|
| `Get details on incident INC0000015` | Full incident record — state, priority, assignment, CI, work notes |
| `Look up user Fred Luddy` | User record |
| `Add a work note to INC0000015 saying "MCP test"` | Confirmation that work_notes field was updated |

### Known issues (as of 2026-10-06)

| Tool | Status | Notes |
|---|---|---|
| `get_all_application_service_names` (sn-cmdb), `list_alert_records` (sn-itom) | HTTP 500 on an empty request body | Pass at least one argument — `{"include_inactive": false}` or `{"limit": 5}`. Seen 2026-10-06 |
| `cmdb_search` (sn-cmdb) | Errored on "find all windows servers" (`encoded_query` undefined) | Seen 2026-09-22, not re-tested |
| `create_incident_or_request` (sn-itsm) | HTTP 403 "Missing required api access scope: a2aauthscope" | Seen 2026-09-22; open, no documented fix found |
| `alert_hypothesizer` (sn-itom) | Errors unless the alert is a Log Analytics, non-group alert with a resource set | Seen 2026-09-22 |
| `search_similar_records` (sn-itsm) | Returned HTTP 500 on every call in June 2026 | Not confirmed either way since |
| MID Servers, Discovery, Agent Client Collector | No native MCP server covers them | Use the Table API |

---

## What You Can Ask Claude

The 36 tools span five servers. Claude picks the right one automatically — you describe what you
want in plain English. The tables below are examples, not the full tool list. Besides the three
domain servers, `sn-quickstart` (4 tools, including `look_up_incident_records`) and
`sn-moveworks` (1 tool, `enterprise_graph`) are general-purpose servers that come with the MCP
Server Console.

### CMDB — `sn-cmdb` (9 tools)

| What you want | What to ask |
|---|---|
| Find servers, apps, or any CI | "Search the CMDB for Windows servers in the Production class" |
| Add a new CI | "Create a new server CI named app-prod-07, OS Windows Server 2022" |
| Find the right CI class before creating | "What's the correct CMDB class for a network switch?" |

### Incidents and requests — `sn-itsm` (13 tools)

| What you want | What to ask |
|---|---|
| Look up an incident | "Get details on incident INC0012345" |
| Find similar past incidents | "Are there any past incidents similar to this one about database timeouts?" |
| Find a user | "Look up Jim Wells in ServiceNow — what's his user ID?" |
| Find who handles a queue | "Which assignment group handles Windows server alerts?" |
| Update an incident | "Set INC0012345 to In Progress and assign it to the Linux team" |

### Alerts and reliability — `sn-itom` (9 tools)

| What you want | What to ask |
|---|---|
| Understand an alert | "Analyze alert ALT0001234 — what's likely causing it?" |
| Investigate an alert | "Walk me through what to check for alert ALT0001234" |
| Find what an alert might affect | "What services or CIs does alert ALT0001234 impact?" |
| Generate alert hypotheses | "What are the possible root causes for this memory alert?" |
| Check a CI's health | "What's the reliability status of the CI named db-cluster-prod?" |
| See reliability topology | "Show me the reliability topology around db-cluster-prod" |
| Find incident-to-CI links | "Which CIs are associated with incident INC0099876?" |
| Create an SLO | "Create a 99.9% availability SLO for the CI named web-tier-01" |
| List recent alerts | "Show me the 10 most recent critical alerts from the last hour" |

---

## Troubleshooting

### "Server not found or inactive" when a tool is called
The registry row for that server is in Draft status. A ServiceNow admin needs to activate it
(Part 2, Step 2). If the Activate button fails, use the REST PATCH workaround described there.

### Browser doesn't open for OAuth consent
Copy the authorization URL from the terminal output and paste it into your browser manually.

### "OAuth authentication failed — invalid_client"
The client ID in your `claude mcp add` command doesn't match the one in ServiceNow's Application
Registry. Re-check the record, then remove and re-add the server:
```bash
claude mcp remove sn-cmdb
claude mcp add --transport http --client-id CORRECT-ID --client-secret --callback-port 33418 \
  sn-cmdb "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_mcp_server_cmdb_mcp_server"
```

### Browser says the sign-in succeeded, but the server still fails
The server was added without the client secret, or with the wrong one. The token exchange fails
after the browser step, and the instance's system log shows
`Exception on token flow - client_secret`. Remove the server and add it again with
`--client-secret` (Step 5).

### "HTTP 403" when a tool runs
The ServiceNow account you approved during OAuth consent doesn't have the roles those tools need.
- CMDB tools: `itil` or CMDB-specific roles
- ITSM tools: `itil`
- ITOM tools: ITOM or AIOps roles

Have a ServiceNow admin add the missing roles to your account, then revoke and re-approve the
OAuth tokens.

### Tool count is lower than expected (e.g. sn-itom shows 2 tools instead of 9)
Some tool association rows have `Enabled = false`. A ServiceNow admin needs to open the registry
record, find the Tool Definitions related list, select all rows, right-click → Update → set
`Enabled = true`.

### Claude says it has no ServiceNow tools
Run `claude mcp list`. If any server shows `✗ Disconnected`:
1. Check that the server URL is correct (no typo, correct instance subdomain)
2. Run the pre-flight `curl` check from Part 2, Step 4 — a `404` means routing isn't enabled
3. Try `claude mcp remove <name>` then re-add with the correct values

### "HTTP 400 — redirect_uri_mismatch"
The redirect URL in the Application Registry record doesn't match the callback Claude Code uses.
Open the record in ServiceNow and set:
```
http://localhost:33418/callback
```

### Re-authenticating after tokens expire (after 100 days)
Run `claude mcp remove sn-cmdb` (and repeat for each of the other servers), then re-add them
with `claude mcp add` as in Step 5 — have the client secret to hand. The OAuth approval flow will run again and issue new tokens.

---

## Quick Reference

| What | Where |
|---|---|
| MCP server URLs | `sn_mcp_server_registry.list` on your instance |
| OAuth client record | System OAuth → Application Registry |
| Tool list per server | `sn_mcp_tool_definition.list` on your instance |
| Claude Code config file | `~/.claude.json` (or your profile's config) |
| OAuth tokens | macOS Keychain (`Claude Code-credentials-*`) |
| Revoke Claude's access | Application Registry record → Revoke tokens |
| Audit log | System OAuth → OAuth Usage Dashboard |

---

## What You Installed and Why

| Component | What it is | Why you need it |
|---|---|---|
| Claude account | Your subscription at claude.ai | Required to use Claude Code |
| VS Code | The editor Claude Code lives inside | |
| Node.js | The engine that runs Claude Code | |
| Claude Code CLI | The core tool (`@anthropic-ai/claude-code`) | |
| MCP Server Console (`sn_mcp_server`) | The base MCP framework on your instance | Required by all domain apps; also supplies the two general-purpose servers (5 tools) |
| CMDB MCP Server (`sn_cmdb_mcp_server`) | CMDB tool suite | Provides the 9 CMDB tools |
| ITOM MCP Server (`sn_itom_mcp_server`) | ITOM tool suite | Provides the 9 alert/reliability tools |
| ITSM MCP Server (`sn_itsm_mcp_server`) | ITSM tool suite | Provides the 13 incident and request tools |
| OAuth Application Registry record | One confidential OAuth client on your instance | Identifies Claude Code as an approved app; its secret lives in the macOS Keychain |

Nothing runs on your laptop except Claude Code itself. The ServiceNow connector — the tools, the
data, the logic — is hosted on your instance.

---

## Sources

- [ServiceNow MCP Client — official docs (Australia)][docs-mcp-client]
- [MCP Reference — official docs (Australia)][docs-mcp-ref]
- [Add an MCP server with OAuth 2.1 — official docs (Australia)][docs-mcp-oauth]
- [Implementing MCP in ServiceNow — cross-instance setup guide][cross-instance] (Community)
- [Enable MCP and A2A for your agentic workflows — FAQs][faq-a2a] (Community)
- [MCP Server Console FAQ][faq] (Community)
- [Understanding OAuth refresh-token expiration patterns][oauth-patterns] (Community blog)
- Live instance verification: the reference PDI, Australia release — OAuth client, registry rows, URLs, tool counts and one call per server on 2026-10-06; Part 2 click-paths on 2026-06-05

[docs-mcp-client]: https://www.servicenow.com/docs/r/intelligent-experiences/install-mcp-client.html
[docs-mcp-ref]: https://www.servicenow.com/docs/r/intelligent-experiences/mcp-reference.html
[docs-mcp-oauth]: https://www.servicenow.com/docs/r/intelligent-experiences/add-an-oauth-2-1-mcp-server.html
[cross-instance]: https://www.servicenow.com/community/ceg-ai-coe-articles/implementing-the-model-context-protocol-in-servicenow-a/ta-p/3541020
[faq-a2a]: https://www.servicenow.com/community/now-assist-articles/enable-mcp-and-a2a-for-your-agentic-workflows-with-faqs-updated/ta-p/3373907
[faq]: https://www.servicenow.com/community/now-assist-articles/mcp-server-console-faq/ta-p/3550125
[oauth-patterns]: https://www.servicenow.com/community/platform-privacy-security-blog/understanding-oauth-refresh-token-expiration-patterns-for/ba-p/3481290
[kb2820840]: https://support.servicenow.com/kb?id=kb_article_view&sysparm_article=KB2820840
