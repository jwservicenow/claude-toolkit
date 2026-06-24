Goal:
Test updated statusline script — added session cost and tokens/sec; push to GitHub once verified.

State & decisions:
Repo: /Users/jim.wells/ClaudeOS/work/repos/claude-toolkit
Statusline script (modified, NOT pushed): scripts/statusline-command.sh
GitHub hold is intentional — user said do not push until requested.
Cost field: .cost.total_cost_usd → magenta, format $0.xxx, hidden when zero.
Tokens/sec field: computed from last two tokenSamples entries on most recent task → cyan, hidden when idle.
tokenSamples assumed structure: {time: <ms epoch>, tokens: <cumulative>} — may need adjustment after testing.

Constraints:
Do not push statusline script to GitHub until user explicitly requests it.
Ask before destructive ops.

Previous session:
- Pulled and reconciled multiple rounds of user's direct GitHub edits via rebase
- Reordered README tool table and detail sections: Desktop Guide, /servicenow_rag, /newsession, /newplan, PDI MCP, Status bar
- Added "Using Multiple Claude Subscriptions on Mac" row to table
- Demoted footer sections (Keeping up to date, Questions, License) to single small-text line
- Rewrote Claude Desktop guide table description (option B)
- Rewrote /servicenow_rag table description and intro paragraph (user-authored final text)
- Rewrote Claude Desktop section intro text
- Removed cross-reference lines from both Desktop and servicenow_rag sections
- Added session cost + tokens/sec to statusline-command.sh — local only, not pushed

Next action:
Deploy updated script and test it:
  cp /Users/jim.wells/ClaudeOS/work/repos/claude-toolkit/scripts/statusline-command.sh ~/.claude/statusline-command.sh
Restart Claude Code. Check status bar for:
  - Cost label in magenta ($0.xxx) — appears after first response
  - t/s label in cyan — appears during/after active generation
If t/s never appears, tokenSamples field names likely differ from assumed structure. Dump raw JSON to diagnose:
  echo '{}' | sh ~/.claude/statusline-command.sh   (won't show live data — need real session)
Best debug: add `echo "$input" > /tmp/statusline-debug.json` as first line of script, trigger a response, inspect /tmp/statusline-debug.json for actual tokenSamples shape.

Deferred:
- Pushing statusline script to GitHub (after test passes)
- Investigating ccstatusline third-party tool for powerline/themes
- Rate limit bar (five_hour.used_percentage) — discussed, not implemented

Key artifacts:
Repo: /Users/jim.wells/ClaudeOS/work/repos/claude-toolkit
Script in repo: scripts/statusline-command.sh
Deployed script: ~/.claude/statusline-command.sh
Debug dump line: echo "$input" > /tmp/statusline-debug.json

Resume instruction:
Read this file. Ask user if testing passed. If yes, commit and push scripts/statusline-command.sh to GitHub. If tokenSamples shape was wrong, read /tmp/statusline-debug.json and fix the jq path in the script before pushing.
