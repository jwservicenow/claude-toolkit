Look at what has actually happened in this conversation (not memory, not prior sessions — this conversation only). If $ARGUMENTS is provided and resolves to a readable file, read it as the runbook for the next session and let its content shape the transition prompt.

Usage: /newsession [optional path to a runbook or planning file]

If $ARGUMENTS is a bare filename (no slash in it), locate it by running:
`find ~/ClaudeOS -name "<filename>" -type f 2>/dev/null | head -5`
If exactly one match, use it as the runbook. If multiple matches, list the candidates and ask which one. If none, ask for the full path.

Generate a transition prompt the user can paste into a new Claude Code session.

Output format:
- One short intro line OUTSIDE the code block: Paste this into a new Claude Code session to resume:
- Then a single fenced code block containing the transition prompt.
- No other commentary.

Inside the code block, use plain-text section labels (no markdown bold or asterisks). Each label sits on its own line, ending with a colon. Content follows on the next line(s). Omit any section with nothing real to say:

Goal:
One sentence — what this work is trying to accomplish.

This session:
3–5 bullets, past tense, this conversation only. What actually happened. Skip anything already done before this session started.

Next action:
The single most immediate thing to do. Enough context to execute without re-reading history.

Awaiting:
Use only when the session ends blocked on user input. One sentence — what's blocked and what input is needed.

Key artifacts:
Only what's needed for the next action — file paths, IPs, sys_ids, commands, URLs.

If a runbook was provided, add a footer line: "Read [path] first." If the runbook describes infrastructure or operational targets (hosts, customer instances, production systems), also add: "Change control: state the action and wait for acknowledgement before proceeding."

Cap at 250 words inside the code block.
