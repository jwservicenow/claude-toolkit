#!/bin/sh
input=$(cat)
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

if [ -n "$used" ]; then
  ctx=$(printf "%.0f%%" "$used")
  # Build a 10-block usage bar: filled = used, empty = remaining
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
  printf "\033[34m%s\033[0m  \033[33m%s\033[0m  ctx:\033[32m%s %s\033[0m" "$dir" "$model_label" "$bar" "$ctx"
else
  printf "\033[34m%s\033[0m  \033[33m%s\033[0m" "$dir" "$model_label"
fi
