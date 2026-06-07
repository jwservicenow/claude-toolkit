# claude-code-toolkit

Tools that make Claude smarter for ServiceNow work — built by a ServiceNow practitioner, shared for peers.

Everything here works inside **Claude Code** (the command-line app). Some tools also have a Claude Desktop version — noted where applicable.

| Tool | What it does |
|------|-------------|
| [/newsession](#newsession) | Compress a long chat into a short summary, paste it into a fresh session, and pick up right where you were |
| [/newplan](#newplan) | Turn a goal into a structured written plan with trade-offs |
| [/servicenow_rag](#servicenow_rag) | Answer ServiceNow questions from the official docs mirror — citable URLs, no guessing |
| [Desktop guide](#similar-setup-for-claude-desktop) | Ground Claude Desktop knowledge replies to ServiceNow docsite (via Project Instructions) |
| [Status bar](#status-bar) | Show model, context size, and usage at the bottom of Claude Code |

---

### `/newsession`

Long conversations slow Claude down. Type `/newsession` and it writes a short summary of everything that happened — paste it into a new chat and you pick up right where you were, without replaying the whole history.

Optionally pass a filename and the next session will be shaped around that file:
```
/newsession my-runbook.md
```

**Install**

```bash
mkdir -p ~/.claude/skills/newsession
curl -o ~/.claude/skills/newsession/SKILL.md \
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/skills/newsession/SKILL.md
```

Restart Claude Code. Then type `/newsession`.

---

### `/newplan`

Type `/newplan` followed by what you want to do. Claude asks a few clarifying questions, lays out your options with trade-offs, then presents the plan for review and approval. After giving the OK, writes a complete plan file into your project folder.

```
/newplan migrate our CMDB to CSDM
/newplan set up Discovery for Azure
```

**Install**

```bash
mkdir -p ~/.claude/skills/newplan
curl -o ~/.claude/skills/newplan/SKILL.md \
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/skills/newplan/SKILL.md
```

Restart Claude Code. Then type `/newplan`.

---

### `/servicenow_rag`

Claude normally can't read the ServiceNow documentation site — it's blocked from AI tools. This command routes your question through ServiceNow's official GitHub docs mirror instead, so every answer comes with a real, citable URL — not something Claude made up from memory.

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
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/commands/servicenow_rag.md
```

Restart Claude Code. Then type `/servicenow_rag` followed by your question.

**Check it's working** — ask something too specific for Claude to know from memory:
```
/servicenow_rag what sys_property controls Discovery IP range exclusions?
```
If Claude fetches from GitHub before answering, it's working. If it answers immediately with no fetch step, something went wrong during install.

---

### Similar setup for Claude Desktop

This is a separate setup for people using Claude Desktop.

```bash
curl -o ~/Downloads/servicenow-mirror-desktop-guide.html \
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/docs/servicenow-mirror-desktop-guide.html
open ~/Downloads/servicenow-mirror-desktop-guide.html
```

Downloads a setup guide and opens it in your browser. Follow the steps inside — about 10 minutes total.

---

### Status bar

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
  https://raw.githubusercontent.com/jwservicenow/claude-code-toolkit/main/scripts/statusline-command.sh
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

## Docs

- **[setup.md](docs/setup.md)** — How to run a personal and a work Claude account on the same Mac without them mixing. About 15 minutes start to finish.

---

## Keeping up to date

Re-run any `curl` command above to get the latest version. It overwrites your local copy automatically.

---

## Questions or requests

Found a bug or want to request something new? [Open an issue](https://github.com/jwservicenow/claude-code-toolkit/issues) — it's the best way to reach me.

## License

MIT — see [LICENSE](LICENSE).
