# Optional — Table API over OAuth

Part of the [PDI starter kit](README.md). **You don't need this to use the kit.** The helper in
the [REST guide](pdi_rest_basic_auth_guide.md) signs in with Basic Auth, and that's the setup
the kit is built and tested on.

Read this if you want Claude's REST calls to use OAuth tokens instead of sending the password on
every call. Tokens expire on their own, and you can revoke them on the instance without changing
the password.

> **Status — 2026-10-07.** All three grant types below returned a token and then HTTP 200 on
> Table API reads (`alm_hardware`, `sys_user`, `incident`) on the reference PDI (Australia),
> using requests built by hand. Writes over OAuth have not been tested. The kit's helper has no
> OAuth function. If you want one, ask Claude to add it to `pdi-curl.sh`, with the same rules:
> client secret and token read from the Keychain on each call and kept off the command line,
> and every response through `pdi-redact.py`.

## The three grant types

| Grant | Signs in as | What it needs | Notes |
|---|---|---|---|
| Password | The user whose name and password you send to get the token | An OAuth client, plus the user's password | Still sends the password, but only to get a token, not on every call |
| Client credentials | The user set on the OAuth client record (`oauth_entity.user`) | An OAuth client with a user set; property `glide.oauth.inbound.client.credential.grant_type.enabled` = `true` | No user password involved at all. Worked for an admin integration user |
| JWT bearer | The user named in the signed assertion's `sub` claim | An OAuth client, a JWT verifier (`jwt_verifier_map`) and a shared or signing key | **Refused for an admin user** ("Grant access to admin is not allowed"). Needs a separate non-admin user, so it can't run as `claude.integration` |

For the kit's admin integration user, **client credentials** is the simplest fit.

## Setting it up, in outline

1. **Create the OAuth client** in the Application Registry. Choose **"Create an OAuth API
   endpoint for external clients"** (the same starting point as Step 3 of the
   [native MCP guide](pdi_native_mcp_install_guide.md#step-3--create-the-oauth-client)). Keep it
   confidential, so it has a client secret.
2. For client credentials, set the record's user to `claude.integration`, and check the
   property above.
3. **Store the client ID and secret in the Keychain**, from a separate Terminal window, the same
   way as setup Step 3 (`security add-generic-password ... -w`). Never paste them into the chat.
4. **Get a token** with a POST to `https://<instance>.service-now.com/oauth_token.do` (form
   fields `grant_type`, `client_id`, `client_secret`, plus `username` and `password` for the
   password grant). The response holds `access_token` and `refresh_token`.
5. **Call the Table API** with the header `Authorization: Bearer <access_token>`.

Token lifespans seen on the reference PDI: access 1,800 seconds (30 minutes), refresh 8,640,000
seconds (100 days).

## Trouble you might hit

- **`403 "Missing required api access scope: <scope>"`**: someone has bound the Table API to an
  auth scope (a `sys_api_access_scope` record). This usually happens while setting up API keys.
  A fresh PDI shouldn't have one. The OAuth client then needs a matching
  `oauth_entity_auth_scope_mapping` record for that scope. Basic Auth and the native MCP servers
  aren't affected.

## Turning it off

Set **Active** to false on the OAuth client record (`oauth_entity.active`).
