# claude-toolkit

Tools that make Claude smarter for ServiceNow work — built by a ServiceNow ITOM practitioner, shared for peers.

Everything here works inside **Claude Code** (the command-line app). Some tools also have a **Claude Desktop** version — noted where applicable.

| Tool | What it does |
|------|-------------|
| [/newsession](#newsession) | Long chat getting slow or pricey? Turn it into a dense handoff you paste into a fresh session — after a quick check for loose ends worth finishing first |
| [/newplan](#newplan) | Turn a goal into an approved, written plan — clarifying questions, 3–4 ranked approaches with trade-offs, saved as a plan file |
| [/servicenow_rag](#servicenow_rag) | Questions about ServiceNow are grounded in the our docsite — citable URLs, no guessing or hallucinations |
| [Desktop guide](https://jwservicenow.github.io/claude-toolkit/docs/servicenow-mirror-desktop-guide.html) | Ground Claude Desktop knowledge replies to ServiceNow docsite (via Project Instructions) |
| [Status bar](#status-bar) | Show model, context size, and usage at the bottom of Claude Code session UI |
| [Native MCP install guide](docs/native_mcp_install_guide.md) | Connect Claude Code to ServiceNow using the platform's ootb MCP — no scripts needed, OAuth 2.1 security profile with PKCE, 17 purpose-built tools |

---

### `/newsession`

Long conversations get slow, lose the thread, and burn tokens. Type `/newsession` and it does two things: first it scans the session for loose ends and asks whether any are better finished *now* than handed off; then it writes a dense, structured handoff — goal, decisions, constraints, next action — and saves it as a resume file right in your project folder. Paste it into a new chat and pick up exactly where you left off, no replaying history.

Optionally pass a filename and the next session will be shaped around that file:
```
/newsession my-runbook.md
```

**Install**

```bash
mkdir -p ~/.claude/skills/newsession
curl -o ~/.claude/skills/newsession/SKILL.md \
  https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/skills/newsession/SKILL.md
```

Restart Claude Code. Then type `/newsession`.

---

### `/newplan`

Type `/newplan` followed by what you want to do. Claude explores your project for context, asks up to four clarifying questions, then lays out three to four approaches ranked by trade-offs. It self-reviews, presents the plan for your approval, and on your OK writes a complete, self-contained plan file into your project folder — ready to hand to a fresh session or a teammate.

```
/newplan migrate our CMDB to CSDM
/newplan set up Discovery for Azure
```

**Install**

```bash
mkdir -p ~/.claude/skills/newplan
curl -o ~/.claude/skills/newplan/SKILL.md \
  https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/skills/newplan/SKILL.md
```

Restart Claude Code. Then type `/newplan`.

---

### `/servicenow_rag`

Claude normally can't read the ServiceNow documentation site because of javascript. Many sites block AI tools. This solution routes your questions through ServiceNow's official GitHub docs mirror instead, so every answer comes with a real, citable URL — not something Claude made up from memory or found in a stale Google index.

*Claude Code only. On Claude Desktop? Use the [Desktop setup guide](#similar-setup-for-claude-desktop) — different setup, same result.*

<details>
<summary>How it works under the hood</summary>

ServiceNow publishes a copy of their documentation as plain text files on GitHub at `ServiceNow/ServiceNowDocs`, specifically so AI tools can read it. This command goes straight to that source:

1. Looks up the right documentation bundle from ServiceNow's published index.
2. Finds the specific topic file in that bundle.
3. Reads the file and answers your question from it — citing the exact URL it pulled from.
4. Checks the ServiceNow Community for real-world context the official docs don't cover.
5. Falls back to Now Support KBs or Community posts if the mirror doesn't have it — flagged clearly so you know the source.
6. Stops and tells you if it can't find anything retrievable. No guessing.

</details>

**Install**

```bash
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/servicenow_rag.md \
  https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/commands/servicenow_rag.md
```

Restart Claude Code. Then type `/servicenow_rag` followed by your question.

**Check it's working** — ask something too specific for Claude to know from memory:
```
/servicenow_rag what sys_property controls Discovery IP range exclusions?
```
If Claude fetches from GitHub before answering, it's working. If it answers immediately with no fetch step, something went wrong during install.

---

### Similar setup for Claude Desktop

This is a separate setup for people using Claude Desktop. **[View the guide →](https://jwservicenow.github.io/claude-toolkit/docs/servicenow-mirror-desktop-guide.html)**

```bash
curl -o ~/Downloads/servicenow-mirror-desktop-guide.html \
  https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/docs/servicenow-mirror-desktop-guide.html
open ~/Downloads/servicenow-mirror-desktop-guide.html
```

Downloads a setup guide and opens it in your browser. Follow the steps inside — about 10 minutes total.

---

### Status bar customization

<img src="docs/statusline-preview.png" width="500" alt="Statusline preview">

Shows your working folder, which model you're on, context window size, and a live usage bar. Useful for knowing when a conversation is getting too long.

**Install**

**Requires `jq`.** Check if you have it: run `jq --version` in your terminal. If not:
```bash
brew install jq
```

**Step 1** — Download the script:
```bash
curl -o ~/.claude/statusline-command.sh \
  https://raw.githubusercontent.com/jwservicenow/claude-toolkit/main/scripts/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

**Step 2** — Open `~/.claude/settings.json` in a text editor and add this block inside the outermost `{ }`:
```json
"statusLine": {
  "type": "command",
  "command": "sh ~/.claude/statusline-command.sh"
}
```

**Step 3** — Restart Claude Code.

> **Running two Claude accounts?** If you followed the dual-account setup guide, add the `statusLine` block to `~/.claude-work/settings.json` and/or `~/.claude-personal/settings.json` instead of `~/.claude/settings.json`.

---

### Connect Claude to PDI: Native MCP install guide

Connects Claude Code to your ServiceNow instance using the platform's own built-in connector instead of a local Python script. No passwords in plain-text files — credentials stay in your macOS Keychain. Gives you 17 purpose-built tools for CMDB, ITSM, and ITOM work.

**Requires:** ServiceNow Australia release (Zurich Patch 9+) with Now Assist. If your instance doesn't meet that, use the DIY Table-API guide instead.

[Open the guide](docs/native_mcp_install_guide.md)

---

## Docs

- **[setup.md](docs/setup.md)** — How to run a personal and a work Claude account on the same Mac without them mixing. About 15 minutes start to finish.

---

## Keeping up to date

Re-run any `curl` command above to get the latest version. It overwrites your local copy automatically.

---

## Questions or requests

Found a bug or want to request something new? [Open an issue](https://github.com/jwservicenow/claude-toolkit/issues) — it's the best way to reach me.

## License

MIT — see [LICENSE](LICENSE).
