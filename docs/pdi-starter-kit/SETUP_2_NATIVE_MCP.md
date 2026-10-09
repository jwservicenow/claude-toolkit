# Paste-in prompt — native MCP

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
2. Copy lines 34 through 222 of this file. Line 34 starts `Set up the ServiceNow platform's own MCP servers`. Line 222 is `removal steps.`
3. Paste it into Claude Code (Cmd+V) and press Return.
4. Do what Claude asks. It stops at each step marked **WAIT** until you answer.

Background and troubleshooting: [native MCP guide](pdi_native_mcp_install_guide.md).
Part of the [PDI starter kit](README.md).

**Needs:** Setup 1 finished in `~/pdi-claude`. A PDI on Zurich or Australia where you have
`admin`, with a Now Assist application active, plus the MCP apps from the ServiceNow Store (the
prompt checks which you're missing). Patch compatibility is on each app's Store listing. Verified on Australia only.

> **Status — 2026-10-09.** Run once, Steps 1 to 9 (Sonnet 5.5, medium effort, fresh PDI). All 5
> servers signed in and answered. sn-cmdb and sn-itom returned data; sn-quickstart and sn-itsm
> answered empty (a clean PDI has no records); sn-moveworks returned `{}`, so it is not proven.
> Changes made after that run were not re-run: start-command question, the OAuth steps through
> the Machine Identity Console, restart with `--resume`, the second-call rule in Step 7, and the
> new reply format.

~~~~text
Set up the ServiceNow platform's own MCP servers on my personal developer instance (PDI) and
connect Claude Code to them, following the steps below in order. Stop at every step marked WAIT
until I reply. I do every step on the instance myself, in the browser as admin; you give me the
steps.

Rules for this whole session:
- Never ask me to paste the OAuth client secret, a password, token or key into this chat, and
  never print one. The client secret is typed only at the `mcp add` prompt in a separate
  Terminal window. If a secret ever appears in the chat, stop and tell me to regenerate it on the
  instance.
- The OAuth client ID is not a secret. I paste it here in Step 4.
- Read the instance only with Setup 1's helper: `source ~/pdi-claude/pdi-curl.sh`, then
  `pdi <path>`. Reads only; no `pdi_write` in this setup.
- The menu and button names below were last checked in 2026. If what I see differs, go by what I
  describe and note the difference for the Step 9 report.
- Before any MCP tool call that would change a record, tell me what it changes and wait for my
  yes.
- When you give me commands to run, put each on its own line and tell me to run them one at a
  time. Never join them with `&&` or commas.
- Open every reply with "STEP N of 9: <name>" and a Done line, for example "Done: 1 ✓ 2 ✓". Then
  give one line on why the step matters, the exact commands (one per line), what success looks
  like, and what comes next. Keep every reply short: no recaps.
- If I say "continue at Step N", the earlier steps are done: skip them, read what you need from
  the instance, and start at Step N. Ask for my start command again if Step 1 was skipped.

STEP 1 — Check Setup 1.
Read my instance name from ~/pdi-claude/CLAUDE.md. If that file or ~/pdi-claude/pdi-curl.sh
is missing, stop and tell me to run SETUP_1_REST_ADMIN.md first. Then run:
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/sys_user?sysparm_limit=1&sysparm_fields=user_name'
HTTP 200 means Setup 1 works. A timeout or HTML page usually means the PDI is asleep: tell me
to wake it from developer.servicenow.com, then run it again.
Then ask me once: "What command do you type to start Claude Code? Give just the command, no
options." Call my answer <start> and use it wherever a step needs me to run Claude Code. Never
guess it, and never use a bare `claude` unless that is my answer. WAIT for my answer.

STEP 2 — Update and install the apps (I do this in the browser).
Seven apps matter, all at their latest version (updates fix problems and add features):
    Model Context Protocol Server (also called MCP Server Console, sn_mcp_server). The others
      need it.
    Otto for CMDB (sn_cmdb_gen_ai), Otto for ITSM (sn_itsm_gen_ai), Otto for ITOM
      (sn_itom_gen_ai). The MCP servers below need these.
    CMDB MCP Server (sn_cmdb_mcp_server)
    ITSM MCP Server (sn_itsm_mcp_server)
    ITOM MCP Server (sn_itom_mcp_server)
Run both reads, installed versions, then versions on offer:
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/sys_scope?sysparm_query=scopeINsn_mcp_server%2Csn_cmdb_gen_ai%2Csn_itsm_gen_ai%2Csn_itom_gen_ai%2Csn_cmdb_mcp_server%2Csn_itsm_mcp_server%2Csn_itom_mcp_server&sysparm_fields=scope,name,version,active'
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/sys_app_version?sysparm_query=scopeINsn_mcp_server%2Csn_cmdb_gen_ai%2Csn_itsm_gen_ai%2Csn_itom_gen_ai%2Csn_cmdb_mcp_server%2Csn_itsm_mcp_server%2Csn_itom_mcp_server&sysparm_fields=scope,version&sysparm_limit=500'
The second list isn't sorted: compare versions number by number (1.10.0 is newer than 1.9.0).
Show me one table: app, installed version (or "missing"), latest on offer, and Update, Install
or nothing. If every app is at the latest version, go to Step 3.
Otherwise give me these steps to follow:
  In the PDI as admin: All > System Applications > All Available Applications > All.
  Search for each app marked Update or Install and bring it to the latest version, in this
  order: Model Context Protocol Server, then the Otto apps, then the MCP servers.
If an MCP server or its Otto app isn't offered, my instance can't run that server: leave it out
of every later step and carry on. If Model Context Protocol Server isn't offered, stop and tell
me Setup 2 can't run on this instance; Setup 1 is all I need.
Tell me that updating one app often updates the apps it depends on too, so I can say "recheck"
after any app. On "recheck", run both reads again and show me the table with only what's left.
WAIT until I say I'm done. Then run both reads again and show me the full table.

STEP 3 — Activate the servers (I do this in the browser).
Give me these steps to follow:
  First give my own login (the admin user I sign in with in the browser, not claude.integration)
  the roles sn_mcp_server.admin and sn_mcp_server.tools_admin: All >
  User Administration > Users, open my user, and in the Roles related list select Edit, add
  them and save. If saving is refused, elevate to the security_admin role and try again. Then
  log out and back in so the roles take effect. Activating a server can need these roles, not
  just admin.
  Then type MCP Server Console in the navigator filter and open it (All > Admin Center > MCP
  Server Console). On its Servers page each installed app has a card:
    Quickstart Server            (Model Context Protocol Server)  -> sn-quickstart
    Quickstart MoveWorks Server  (Model Context Protocol Server)  -> sn-moveworks
    CMDB MCP Server              (CMDB MCP Server)                -> sn-cmdb
    ITSM MCP Server              (ITSM MCP Server)                -> sn-itsm
    ITOM MCP Server              (ITOM MCP Server)                -> sn-itom
  Any card in Draft or Inactive: first switch my application scope to that server's own app (for
  CMDB MCP Server, scope "CMDB MCP Server"), then select the card's three-dot menu > Activate.
  Do each server in its own scope. Without the right scope the Activate option doesn't work and
  shows no error. Ignore any (Deprecated) card.
WAIT until I say I'm done. Then run:
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/sn_mcp_server_registry?sysparm_fields=name,status'
and show me each row's status. A row that won't go Active is left out of every later step.
Then check the MCP path, with no credentials:
  curl -sS -o /dev/null -w '%{http_code}\n' -X POST "https://<name>.service-now.com/sncapps/mcp-server/mcp/sn_mcp_server_default"
401 is good. 404 means the /sncapps/mcp-server path isn't enabled on my instance: stop and tell
me to ask ServiceNow Support to enable it.

STEP 4 — Create the OAuth client (I do this in the browser).
Give me these steps to follow:
  1. In the MCP Server Console, click "Set up OAuth" on the blue banner. (Or: All > Machine
     Identity Console > Inbound integrations > New integration.)
  2. Choose "OAuth - Authorization code grant".
  3. Set:
       Name: Claude Code
       Provider name: Claude Code
       Redirect URLs: http://localhost:33418/callback
       This is a public client: leave unchecked
       Token Format: JWT
       Auth scope: leave empty
     Leave every other field at its default. Click Save.
  4. A box asks about an auth scope: click "Skip for now".
  5. Open the saved Claude Code record again (Inbound integrations, the page the banner opened:
     click the Claude Code row). Uncheck "Allow access only to APIs in selected
     scope", then Save.
Ask me to paste the Client ID (32 characters) here. Tell me to leave the Client Secret on the
record until Step 5. WAIT.
Then read the record live and show me each value:
  source ~/pdi-claude/pdi-curl.sh && pdi '/api/now/table/oauth_entity?sysparm_query=client_id%3D<client-id>&sysparm_fields=name,inbound_grant_type,public_client,use_pkce,token_format,redirect_url,scope_restriction_status'
Every value must match: inbound_grant_type authz_code, public_client false, use_pkce false,
token_format jwt, redirect_url http://localhost:33418/callback, scope_restriction_status
unrestricted. If scope_restriction_status says restricted, send me back to item 5 above.

STEP 5 — Add the servers to Claude Code (I do this in a separate Terminal window).
Write out one command per Active server, with my instance name and client ID filled in, in this
form:
  <start> mcp add --transport http -s local --client-id <client-id> --client-secret --callback-port 33418 <server> "https://<name>.service-now.com/sncapps/mcp-server/mcp/<url-ending>"
Servers and URL endings:
  sn-quickstart  sn_mcp_server_default
  sn-moveworks   sn_mcp_server_moveworks_default
  sn-cmdb        sn_cmdb_mcp_server_cmdb_mcp_server
  sn-itsm        sn_itsm_mcp_server_itsm_default
  sn-itom        sn_genai_itom_mcp_server
Then tell me: open a NEW Terminal window, not this chat. Show me what to run there, one command
per line: `cd ~/pdi-claude` first (the servers are saved for that folder and that account only),
then each add command, starting with my <start> command. Copy the Client Secret from the OAuth
record (the copy icon next to it) and run them one at a time. Each one asks for the client
secret: paste it at that prompt, never in this chat. Afterwards copy something else, so the
secret leaves the clipboard. If a command says the name already exists, run
`<start> mcp remove -s local <server>` and run the add again.
WAIT until I say the commands ran. Then run `<start> mcp list` from ~/pdi-claude and show me the
sn-* lines. All five must be listed, each saying it needs sign-in. If they are missing, I added
them under a different command or folder: have me remove them there and add them again.

STEP 6 — Restart and sign in.
Tell me why: Claude Code reads its server list only when it starts, so it must restart. Then give
me these lines, one at a time:
  /exit
  <start> --resume
Tell me to run the second line in Terminal from ~/pdi-claude, adding any options I started this
session with (for example --model), and to pick this conversation at the top of the list. Do not
use -c: it can start a fresh session that doesn't have these steps. Tell me this before I
restart: if the restarted session doesn't know these steps, paste this prompt again and type
"continue at Step 7" (after the sign-ins) or "continue at Step 6" (before them).
Then, in the restarted session, tell me to type /mcp and sign in to each sn-* server in turn,
five times: the browser opens my instance's login page; I log in as my admin user; on the consent
screen I click Allow; the browser shows a success message at localhost:33418/callback; I go back
to Terminal. Success: /mcp shows all five servers as connected. If the browser says success but a
server still needs sign-in, the client secret was missed in Step 5: I tell you which server.
WAIT until I say every server is signed in. When I say done, start your reply with
"Congratulations!" and go straight to Step 7.

STEP 7 — Prove each server works.
Make one real read-only call per signed-in server and show me what came back:
  sn-quickstart: look_up_incident_records, limit 5
  sn-moveworks:  enterprise_graph, asking "How many incidents are there?"
  sn-cmdb:       get_all_application_service_names with include_inactive false
  sn-itsm:       lookup_assignment_groups for "Service Desk"
  sn-itom:       list_alert_records with limit 5
Always pass the arguments shown: an empty request returns HTTP 500 on the sn-cmdb and sn-itom
calls. Sort each call into one of three: returned data; answered but empty (a PDI may have no
demo data); or unclear (for example {}). For every server that did not return data, make one more
read-only call with a different tool from that server's tool list, and show me both results.
Never call a server proven unless a call returned data. "Connected" in /mcp doesn't count.
For a 403, the user I signed in as lacks a role for that server's tools: tell me which server.
For "Server not found or inactive", that registry row isn't Active: back to Step 3 for it.

STEP 8 — Keep the rules for future sessions.
Add the lines between BEGIN and END to ~/pdi-claude/CLAUDE.md, creating the file if needed. If
it already has a "## ServiceNow MCP servers" section, replace that section and keep the rest.
Don't ask first; show me the file afterwards.
BEGIN
## ServiceNow MCP servers
- The sn-* MCP servers run as whoever signed in to them in the browser, with that user's roles.
- "Connected" doesn't prove a server works; make one real tool call.
- Before any MCP tool call that changes a record, tell me what it changes and wait for my yes.
- Never ask for, paste or print the OAuth client secret, a password, token or key in chat.
END

STEP 9 — Report.
Start with "Congratulations!". Summarise: which apps are installed, which servers are Active,
which Step 7 calls passed, any menu or button that didn't match, and what's in
~/pdi-claude/CLAUDE.md. Tell me how to start future sessions, as two separate commands:
  cd ~/pdi-claude
  <start>
and that a sign-in lasts 100 days before /mcp asks again. For each server, say whether its
Step 7 call returned data, answered empty, or was unclear. End by saying: to undo this setup
later, see "Removing it" in pdi_native_mcp_install_guide.md in the starter kit. Do not list the
removal steps.
~~~~
