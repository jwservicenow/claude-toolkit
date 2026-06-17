# Connecting Claude Code your PDI — Platform-Native MCP Path

**What you'll end up with:** Claude Code connected to your ServiceNow instance using the
platform's own built-in connector — no Python script on your laptop, no passwords in plain-text
files. You can search the CMDB, manage incidents, investigate alerts, and check MID Server health
by typing in plain English.

**Who this is for:** This guide has two parts: a ServiceNow administrator sets up the instance
side (Part 2), and the Claude Code user wires up their machine (Part 3). Both steps can be done
by the same person.

**How this compares to the DIY Table-API guide:**

| | DIY guide (Python/Table-API) | This guide (native MCP) |
|---|---|---|
| Something to install on your laptop? | Yes — a Python script | No — runs inside ServiceNow |
| Credentials stored where? | Plain-text `.env` file | macOS Keychain only |
| How it logs in | Shared OAuth secret | You approve in a browser — no secret |
| Actions recorded as | One fixed service account | Your own ServiceNow login |
| Tools available | 2 generic table-read tools | 17 purpose-built tools (CMDB, ITSM, ITOM) |
| Instance requirement | Any instance, any release | Australia / Zurich Patch 9+ with Now Assist |

**How long it takes:** 15–25 minutes if the ServiceNow apps are already installed. Add 20–30
minutes if a ServiceNow admin needs to install them first.

**Platform requirement:** ServiceNow Australia release (Zurich Patch 9 or newer). The tool
suites below are edition-gated — see Part 2, Step 1 for details. If your instance doesn't meet
these requirements, the DIY Table-API guide works on any release.

---

## Before You Start — What You'll Need

| You'll need | Covered in |
|---|---|
| A Claude account with a paid plan | Part 1, Step 1 |
| Claude Code installed and signed in | Part 1, Steps 2–5 |
| A ServiceNow instance on Australia / Zurich Patch 9+ | Your ServiceNow admin |
| MCP Server apps installed on the instance | Part 2, Step 1 |
| An OAuth client created on the instance | Part 2, Step 3 |
| The client ID from that OAuth record (32 characters) | Part 2, Step 3 |
| Your ServiceNow login credentials | Used during first-time browser approval (Part 3) |

---

# Part 1 — Installing Claude Code

If you already have Claude Code installed and `claude --version` prints a version number in a
terminal, skip to Part 2.

Otherwise, follow **Steps 1–5** of the [DIY ServiceNow integration guide][diy-guide]. Those
steps cover creating a Claude account, installing VS Code and Node.js, installing Claude Code,
and signing in. The installation process is identical for both guides.

Return here after completing Step 5 of that guide.

[diy-guide]: Integrating%20Claude%20Code%20with%20ServiceNow%20via%20the%20Table%20API

---

# Part 2 — Preparing Your ServiceNow Instance

> **Role:** ServiceNow administrator. These steps happen inside your ServiceNow instance, not on
> your laptop. If you are not a ServiceNow admin, ask one to complete Part 2 and hand you the
> client ID and server URLs (Step 4) before you begin Part 3.

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
| **MCP Server Console** | The base framework — install this first; all others depend on it |
| **Now Assist for CMDB** | CMDB search, CI creation, CI class guidance |
| **Alert Assist** | Alert triage, investigation, service reliability, SLO tools |
| **ITSM MCP Server** | Incident management, user lookup, assignment group lookup |

> **Source note for app names:** `MCP Server Console` (`sn_mcp_server`) is confirmed in
> official ServiceNow documentation ([Australia release][docs-mcp-client];
> [cross-instance setup community guide][cross-instance]). The domain app names — Now Assist for
> CMDB (`sn_cmdb_gen_ai`), Alert Assist (`sn_alert_gen_ai`), and ITSM MCP Server
> (`sn_itsm_mcp_server`) — are the scoped application identifiers observed on a live
> Australia-release PDI (`empjwells2.service-now.com`) as of 2026-06-05. Their exact Store
> display names were not independently confirmed in retrievable documentation at the time of
> writing. Verify the names match what appears in your instance's Store listing.

When each app installs, it automatically creates a row in the MCP server registry and registers
its tools. You do not need to define any tools manually in the MCP Server Console for these
built-in suites.

---

## Step 2 — Verify and Activate the Registry Rows

Each app creates one row in the internal server registry. These rows must be in **Active** status
before Claude Code can connect to them.

1. In the Application Navigator (the filter box, top-left), type:
   ```
   sn_mcp_server_registry.list
   ```
   Press Enter. This opens the registry table directly.

2. You should see rows like the ones below. Check the **Status** column for each:

| Registry row name | Expected status |
|---|---|
| `sn_cmdb_gen_ai.now_assist_cmdb_mcp_server` | Active |
| `sn_alert_gen_ai.aiops_mcp_server` | Active |
| `sn_itsm_mcp_server.itsm_default` | Active |

3. If a row shows **Draft** or **Inactive**, open it and click **Activate**.

> **Known issue — "Activate" button fails in some patch levels:** The Activate button calls an
> internal method (`McpServerUtils.publishTools()`) that may not exist in certain versions.
> If you see a script error, activate the row using the REST API instead. Open a terminal and run:
>
> ```bash
> curl -u "YOUR-ADMIN-USER:YOUR-PASSWORD" -X PATCH \
>   "https://YOUR-INSTANCE.service-now.com/api/now/table/sn_mcp_server_registry/SYS-ID-HERE" \
>   -H "Content-Type: application/json" \
>   -d '{"status":"active"}'
> ```
>
> Replace `SYS-ID-HERE` with the `sys_id` of the registry row — it appears in the URL when you
> open the record (the value after `sys_id=`).
>
> Also check the tool association rows. Open the registry record, find the **Tool Definitions**
> related list, and confirm each tool shows **Enabled = true**. If not, select all rows → right-
> click → Update → set `Enabled` to `true`.
>
> *This REST workaround was confirmed on `empjwells2` (Australia release); UI button behavior
> may vary on your instance.*

---

## Step 3 — Create the OAuth Client

Claude Code authenticates using **OAuth 2.0 with PKCE** (Proof Key for Code Exchange). This
means: instead of storing a password or shared secret on your laptop, Claude Code opens a
browser window and you personally approve the connection — just like "Log in with Google." No
secret is ever stored in a file.

You create one OAuth client in ServiceNow, and all four MCP servers share it.

### Create the Application Registry record

1. Go to: **All** → filter for **Application Registry** → open **System OAuth → Application Registry**
2. Click **New** → choose **"Create an OAuth API endpoint for external clients"**
3. Fill in the form with the values below:

| Field | Value | Notes |
|---|---|---|
| Name | `Claude Code MCP Client` | Any descriptive name |
| Client ID | *(auto-generated — copy after saving)* | 32-character hex string |
| **Public client** | ✅ checked | Means no client secret is required or stored |
| **Use PKCE** | ✅ checked | Enables the proof-key flow |
| Code challenge method | `S256` | The only option; SHA-256 hash |
| Default grant type | `authorization_code` | See note below — not client_credentials |
| Redirect URL | `http://localhost:33418/callback,http://127.0.0.1:33418/callback` | Both entries, comma-separated, no spaces |
| Access token lifespan | `1800` | 30 minutes |
| Refresh token lifespan | `8640000` | 100 days |
| Token format | `JWT` | |

> **Why `authorization_code`, not `client_credentials`?** The DIY guide uses `client_credentials`
> because that flow is designed for background scripts that hold a stored secret. This guide uses
> `authorization_code` + PKCE because Claude Code is a desktop app — it opens a browser window
> and you personally approve the connection. There is no shared secret to store or leak.
> Client Credentials grant is not currently available for the MCP Server Console.
> *Source: [MCP Server Console FAQ][faq]*

> **Why port 33418?** Claude Code listens on localhost port 33418 for the OAuth callback.
> ServiceNow redirects your browser to that address after you approve access. The redirect URL
> must match exactly — if you change the port here, the OAuth flow will fail.

4. Click **Submit**. ServiceNow generates the Client ID.
5. Open the record that was just created and **copy the Client ID** (the 32-character string). You
   will need this in Part 3.

> **Field verification:** Every field in the table above — `public_client`, `use_pkce`,
> `code_challenge_method`, `default_grant_type`, `redirect_url`, token lifespans, `token_format`
> — was read live from a verified Application Registry record on `empjwells2.service-now.com`
> (Australia release, `sys_id: 4956b5e2c37c0f1035252dceb0013145`, verified 2026-06-05). The
> `public_client` checkbox in the Application Registry form UI is confirmed by a
> [community forum post][pkce-community].

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
| `sn-cmdb` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_gen_ai_now_assist_cmdb_mcp_server` |
| `sn-itom` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_alert_gen_ai_aiops_mcp_server` |
| `sn-itsm` | `https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_itsm_mcp_server_itsm_default` |

Replace `YOUR-INSTANCE` with your instance's subdomain (e.g. `yourcompany` for
`yourcompany.service-now.com`).

**To confirm your exact URLs:** Open each registry row in `sn_mcp_server_registry` and look at
the **Name** field. The URL is that name with dots converted to underscores, appended to the base
path above.

### Pre-flight check (recommended)

Before leaving the instance, confirm the `/sncapps/mcp-server` routing path is enabled. Run the
following in a terminal — you should get **HTTP 401** (unauthorized), not 404:

```bash
curl -I "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_gen_ai_now_assist_cmdb_mcp_server"
```

A `404` means the routing path isn't enabled on your instance. If that happens, contact
ServiceNow Support and ask them to enable the `/sncapps/mcp-server` path forwarding.
*Source: [Cross-instance MCP setup][cross-instance]*

---

Part 2 is complete. Hand the **client ID** (from Step 3) and the three **server URLs** (from
Step 4) to whoever will do the Claude Code setup.

---

# Part 3 — Connecting Claude Code

> **Role:** The person using Claude Code on their laptop. You'll need the client ID and server
> URLs from Part 2.

---

## Step 5 — Add the MCP Servers

Open a terminal. Run one command per server, replacing `YOUR-CLIENT-ID` and `YOUR-INSTANCE` with
your actual values:

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID \
  --callback-port 33418 \
  sn-cmdb \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_gen_ai_now_assist_cmdb_mcp_server"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID \
  --callback-port 33418 \
  sn-itom \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_alert_gen_ai_aiops_mcp_server"
```

```bash
claude mcp add --transport http \
  --client-id YOUR-CLIENT-ID \
  --callback-port 33418 \
  sn-itsm \
  "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_itsm_mcp_server_itsm_default"
```

Each command writes an entry into Claude Code's configuration file (`~/.claude.json` or your
profile's config file). No Python, no scripts, no `.env` file.

> **Multiple profiles (personal vs. work Claude accounts):** If you have separate personal and
> work Claude Code profiles, add a `--scope` flag to control which config gets the entry. Run
> `claude mcp add --help` to see available scope options. The three servers above should go in
> whichever profile you use for work.

> **What if I want to edit the config file directly instead?** Open `~/.claude.json` (or your
> profile's equivalent) in a text editor and add entries like this inside the `mcpServers` block:
>
> ```json
> "sn-cmdb": {
>   "type": "http",
>   "url": "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_gen_ai_now_assist_cmdb_mcp_server",
>   "oauth": {
>     "clientId": "YOUR-CLIENT-ID",
>     "callbackPort": 33418
>   }
> }
> ```
>
> Repeat for `sn-itom` and `sn-itsm` with their respective URLs.

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

> **This happens once per server.** You may be prompted up to three times — once for each of
> `sn-cmdb`, `sn-itom`, and `sn-itsm` — but usually all three share the same session and only
> one browser window appears.

---

## Step 7 — Verify the Connection

Check that all servers connected:

```bash
claude mcp list
```

You should see:

```
✓ Connected  sn-cmdb   (3 tools)
✓ Connected  sn-itom   (9 tools)
✓ Connected  sn-itsm   (5 tools)
```

If any server shows `✗` instead of `✓ Connected`, see the Troubleshooting section.

Now test it end-to-end in a Claude Code session. Open Claude Code and ask:

```
Can you search the CMDB for Linux servers?
```

Claude will call the `cmdb_search` tool and return matching configuration items. If results come
back, the setup is working.

---

## Verification Tests

Paste these prompts into Claude after setup to confirm each tool is working. All were verified on `empjwells2.service-now.com` (Australia release, 2026-06-05).

### CMDB — sn-cmdb

| Prompt | Expected result |
|---|---|
| `Search the CMDB for Linux servers` | Count and list of Linux server CIs |
| `What CMDB class should I use to create a Linux server CI?` | Class options with required fields |

### ITOM Visibility — sn-itom-visibility

| Prompt | Expected result |
|---|---|
| `Show me the status of all MID servers` | Name, status (Up/Down), version, and last check-in for each MID |

### Alerts — sn-itom

| Prompt | Expected result |
|---|---|
| `List the 5 most recent open alerts` | Alert numbers, severities, and states |
| `Analyze alert [number from above]` | Full AI-generated analysis with brief and recommended steps |
| `What is the impact of alert [number from above]?` | Count and names of impacted service instances |
| `What are the alert investigation findings for [number]?` | Historical incident context; returns a "no related incidents" message if none exist — that is expected, not an error |

### Incidents — sn-itsm

| Prompt | Expected result |
|---|---|
| `Get details on incident INC0000015` | Full incident record — state, priority, assignment, CI, work notes |
| `Look up assignment groups matching Service Desk` | Matching group names and their IDs |
| `Look up user Fred Luddy` | User record |
| `Add a work note to INC0000015 saying "MCP test"` | Confirmation that work_notes field was updated |

### Known issues (as of 2026-06-05)

| Tool | Status | Notes |
|---|---|---|
| `search_similar_records` | Broken | Returns HTTP 500 from ServiceNow on every call |
| `acc_policy_redeploy` | Broken | Schema bug — policy sys_id is not forwarded to ServiceNow; returns HTTP 400. Use the manual UI workaround: switch scope to **Agent Client Collector for Visibility Content** → Edit in Sandbox → Save → Republish |

---

## What You Can Ask Claude

The 17 tools span four areas. Claude picks the right one automatically — you describe what you
want in plain English.

### CMDB (3 tools)

| What you want | What to ask |
|---|---|
| Find servers, apps, or any CI | "Search the CMDB for Windows servers in the Production class" |
| Add a new CI | "Create a new server CI named app-prod-07, OS Windows Server 2022" |
| Find the right CI class before creating | "What's the correct CMDB class for a network switch?" |

### Incidents (5 tools)

| What you want | What to ask |
|---|---|
| Look up an incident | "Get details on incident INC0012345" |
| Find similar past incidents | "Are there any past incidents similar to this one about database timeouts?" |
| Find a user | "Look up Jim Wells in ServiceNow — what's his user ID?" |
| Find who handles a queue | "Which assignment group handles Windows server alerts?" |
| Update an incident | "Set INC0012345 to In Progress and assign it to the Linux team" |

### Alerts and reliability (9 tools)

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
claude mcp add --transport http --client-id CORRECT-ID --callback-port 33418 \
  sn-cmdb "https://YOUR-INSTANCE.service-now.com/sncapps/mcp-server/mcp/sn_cmdb_gen_ai_now_assist_cmdb_mcp_server"
```

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
2. Run the pre-flight `curl -I` check from Part 2, Step 4 — a `404` means routing isn't enabled
3. Try `claude mcp remove <name>` then re-add with the correct values

### "HTTP 400 — redirect_uri_mismatch"
The redirect URL in the Application Registry record doesn't include both localhost variants.
Open the record in ServiceNow and set:
```
http://localhost:33418/callback,http://127.0.0.1:33418/callback
```

### Re-authenticating after tokens expire (after 100 days)
Run `claude mcp remove sn-cmdb` (and repeat for sn-itom, sn-itsm), then re-add them with
`claude mcp add` as in Step 5. The OAuth approval flow will run again and issue new tokens.

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
| MCP Server Console (`sn_mcp_server`) | The base MCP framework on your instance | Required by all domain apps |
| Now Assist for CMDB (`sn_cmdb_gen_ai`) | CMDB tool suite | Provides the 3 CMDB tools |
| Alert Assist (`sn_alert_gen_ai`) | ITOM tool suite | Provides the 9 alert/reliability tools |
| ITSM MCP Server (`sn_itsm_mcp_server`) | ITSM tool suite | Provides the 5 incident tools |
| OAuth Application Registry record | One OAuth client on your instance | Identifies Claude Code as an approved app |

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
- [PKCE in Application Registry][pkce-community] (Community forum)
- [Understanding OAuth refresh-token expiration patterns][oauth-patterns] (Community blog)
- Live instance verification: `empjwells2.service-now.com`, Australia release, 2026-06-05

[docs-mcp-client]: https://www.servicenow.com/docs/r/intelligent-experiences/install-mcp-client.html
[docs-mcp-ref]: https://www.servicenow.com/docs/r/intelligent-experiences/mcp-reference.html
[docs-mcp-oauth]: https://www.servicenow.com/docs/r/intelligent-experiences/add-an-oauth-2-1-mcp-server.html
[cross-instance]: https://www.servicenow.com/community/ceg-ai-coe-articles/implementing-the-model-context-protocol-in-servicenow-a/ta-p/3541020
[faq-a2a]: https://www.servicenow.com/community/now-assist-articles/enable-mcp-and-a2a-for-your-agentic-workflows-with-faqs-updated/ta-p/3373907
[faq]: https://www.servicenow.com/community/now-assist-articles/mcp-server-console-faq/ta-p/3550125
[pkce-community]: https://www.servicenow.com/community/hrsd-forum/how-to-use-pkce-in-application-registrie/m-p/2640690
[oauth-patterns]: https://www.servicenow.com/community/platform-privacy-security-blog/understanding-oauth-refresh-token-expiration-patterns-for/ba-p/3481290
[kb2820840]: https://support.servicenow.com/kb?id=kb_article_view&sysparm_article=KB2820840
