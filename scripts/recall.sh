#!/usr/bin/env bash
# recall.sh — search a project's record set before investigating a symptom.
# Implements CANONICAL:record-controls §10. Prints the entry HEADERS that match,
# so the caller reads prior work instead of re-deriving it.
#
#   recall.sh cross-reference xref
#   recall.sh --all video          # include archive/ and .bak files
#
# Exit 0 with matches, 0 with none (prints NO PRIOR WORK), 2 on usage error.

set -uo pipefail

ALL=0
if [ "${1:-}" = "--all" ]; then ALL=1; shift; fi
if [ $# -eq 0 ]; then
  echo "usage: recall.sh [--all] <term> [term...]" >&2
  exit 2
fi

# `grep` in the Claude Code shell is a ugrep wrapper carrying --ignore-files, so it
# silently skips gitignored paths. Record artifacts are gitignored by design, which
# means the wrapper returns zero hits for every one of them. Always `command grep`.
G="command grep"

shopt -s nullglob
FILES=(*findings*.md *defects*.md *runbook*.md *plan*.md *acceptance*.md)
if [ "$ALL" = "1" ]; then
  FILES+=(archive/*.md *.md.bak-* )
fi
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
  echo "no record artifacts in $(pwd)"
  echo "  looked for: *findings*.md *defects*.md *runbook*.md *plan*.md *acceptance*.md"
  exit 0
fi

PAT=$(printf '%s|' "$@"); PAT=${PAT%|}

total=0
for f in "${FILES[@]}"; do
  [ -r "$f" ] || continue
  # For each matching line, walk back to the nearest '## ' or '### ' header and emit it.
  out=$(awk -v pat="$PAT" '
    BEGIN{ IGNORECASE=1 }
    /^#{2,3} /{ hdr=$0; hline=NR }
    $0 ~ pat {
      if (hdr != "" && hdr != last) { printf "%6d  %s\n", hline, hdr; last=hdr }
      else if (hdr == "") { printf "%6d  (before first header)\n", NR }
      n++
    }
    END{ if (n>0) printf "@@COUNT@@%d\n", n }
  ' "$f")
  [ -z "$out" ] && continue
  cnt=$(printf '%s\n' "$out" | $G -o '@@COUNT@@[0-9]*' | $G -o '[0-9]*$')
  body=$(printf '%s\n' "$out" | $G -v '@@COUNT@@')
  total=$((total + ${cnt:-0}))
  echo "=== $f  (${cnt:-0} matching lines)"
  printf '%s\n' "$body"
  echo
done

if [ "$total" -eq 0 ]; then
  echo "NO PRIOR WORK found for: $*"
  echo "Searched ${#FILES[@]} artifact(s). Widen with --all, or try the symptom rather than the diagnosis."
else
  echo "$total matching lines across the record set."
  echo "READ these entries before measuring anything. §10 exists because re-deriving produces a"
  echo "contradictory answer, not a duplicate one."
fi
