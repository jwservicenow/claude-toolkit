#!/usr/bin/env bash
# Resume read of a plan: prints it whole except settled F/D rows and superseded rows in ## Record.
# Those stay searchable by keyword: grep -n '<term>' <plan>
set -euo pipefail
[ $# -eq 1 ] && [ -f "$1" ] || { echo "usage: plan-read.sh <plan.md>" >&2; exit 2; }
awk '
  /^## /                 { r = ($0 ~ /^## Record/); s = 0 }
  r && /^[FDTK] /        { s = ($0 ~ /^[FD] +SETTLED/ || $0 ~ /^[FDTK] +SUPERSEDED/); n += s }
  r && /^Tools:/         { s = 0 }
  !s                     { print }
  END { printf "[%d settled/superseded Record rows hidden: grep the plan by keyword for them]\n", n }
' "$1"
