#!/bin/sh
input=$(cat)
GREEN="\033[38;2;104;168;102m"  # same green as the cache-keeper mod
AMBER="\033[38;2;255;153;0m"
RED="\033[38;2;204;0;0m"
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(echo "$cwd" | awk -F/ '{print $(NF-2)"/"$(NF-1)"/"$NF}')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // "0"')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Format context window size as e.g. "200k"
if [ -n "$ctx_size" ]; then
  ctx_k=$(( ctx_size / 1000 ))
  model_label="${model} (${ctx_k}k)"
else
  model_label="$model"
fi

# Tokens/sec — from the last two tokenSamples of the most recent task.
# tokenSamples entries are expected to be {time: <ms epoch>, tokens: <cumulative>}.
# Silently omitted if samples are unavailable or the task is idle.
tok_label=$(echo "$input" | jq -r '
  ( .tasks // [] )
  | map(select(.tokenSamples and ((.tokenSamples | length) >= 2)))
  | last
  | if . == null then empty else
      .tokenSamples as $s |
      ($s[-1].tokens - $s[-2].tokens) as $dt |
      (($s[-1].time  - $s[-2].time) / 1000.0) as $ds |
      if $ds > 0 and $dt > 0 then
        (($dt / $ds) | round | tostring) + "t/s"
      else empty end
    end
' 2>/dev/null)

if [ -n "$used" ]; then
  ctx=$(printf "%.0f%%" "$used")
  filled=$(echo "$used" | awk '{printf "%.0f", $1 / 10}')
  bar=""
  i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}▓"
    else
      bar="${bar}░"
    fi
    i=$(( i + 1 ))
  done
  # ctx colour and thresholds match the cache-keeper mod: <16 green, 16-20 amber, 21+ red
  pct=$(echo "$used" | awk '{printf "%.0f", $1}')
  if [ "$pct" -ge 21 ]; then ctx_col="$RED"; elif [ "$pct" -ge 16 ]; then ctx_col="$AMBER"; else ctx_col="$GREEN"; fi
  base=$(printf "\033[34m%s\033[0m  ${GREEN}%s\033[0m  ctx:${ctx_col}%s %s\033[0m" "$dir" "$model_label" "$bar" "$ctx")
else
  base=$(printf "\033[34m%s\033[0m  ${GREEN}%s\033[0m" "$dir" "$model_label")
fi

# Append t/s only when present
extras=""
if [ -n "$tok_label" ]; then
  extras="${extras}  \033[36m${tok_label}\033[0m"
fi

printf "%b%b" "$base" "$extras"
