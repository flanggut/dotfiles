#!/bin/bash

# Read JSON input
input=$(cat)

echo "$input" >/tmp/claude_status.json

# Get OS icon
os_icon=$(if [[ "$(uname)" == "Darwin" ]]; then printf ' '; else printf ' '; fi)

# Get model name and current directory
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')

# Function to shorten path if longer than 40 characters
shorten_path() {
  local path="$1"
  local max_length=40

  # If path is already short enough, return it
  if [ ${#path} -le $max_length ]; then
    echo "$path"
    return
  fi

  # Split path into components
  IFS='/' read -ra parts <<<"$path"

  # Start with the full path
  local result="$path"
  local i=0

  # Shorten from left to right until under max_length
  while [ ${#result} -gt $max_length ] && [ $i -lt ${#parts[@]} ]; do
    # Skip empty parts (from leading /)
    if [ -n "${parts[$i]}" ] && [ ${#parts[$i]} -gt 1 ]; then
      # Replace component with first character
      local old_part="${parts[$i]}"
      local new_part="${old_part:0:1}"
      parts[$i]="$new_part"

      # Reconstruct path
      result=""
      for ((j = 0; j < ${#parts[@]}; j++)); do
        if [ $j -eq 0 ] && [ -z "${parts[$j]}" ]; then
          result="/"
        elif [ -n "${parts[$j]}" ]; then
          if [ -n "$result" ] && [ "$result" != "/" ]; then
            result="$result/"
          fi
          result="$result${parts[$j]}"
        fi
      done
    fi
    ((i++))
  done

  echo "$result"
}

# Shorten the path if needed
current_dir=$(shorten_path "$current_dir")

# Calculate context usage (use pre-calculated percentage from JSON)
usage=$(echo "$input" | jq '.context_window.current_usage')
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

if [ "$usage" != "null" ]; then
  # Create progress bar
  bar_width=10
  filled=$((context_pct * bar_width / 100))
  empty=$((bar_width - filled))

  # Build the bar with filled and empty segments
  bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done

  context_display="${bar} ${context_pct}%"

  # Token counts
  input_tokens=$(echo "$usage" | jq '.input_tokens')
  output_tokens=$(echo "$usage" | jq '.output_tokens')
  input_k=$(awk "BEGIN {printf \"%.1f\", $input_tokens/1000}")
  output_k=$(awk "BEGIN {printf \"%.1f\", $output_tokens/1000}")
  token_count="${input_k}k ↓ / ${output_k}k ↑"
else
  context_display="░░░░░░░░░░ 0%"
  token_count="0.0k ↓ / 0.0k ↑"
fi

# Get cost tracking
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
cost_display=$(awk "BEGIN {printf \"$%.2f\", $cost_usd}")

# Get code change metrics
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
changes_display="+${lines_added}/-${lines_removed}"

# Extract state for neovim lualine indicator
# Try to get explicit state field, otherwise infer from context
state=$(echo "$input" | jq -r '.state // empty')
if [ -z "$state" ]; then
  # No explicit state field - check if there are pending tokens (might indicate activity)
  # For now, write "unknown" and we'll refine based on observed JSON
  state="unknown"
fi
echo "$state" >~/.claude/claude-state

# Output the status line
printf "%s | %s | %s | %s | %s | %s" "$os_icon" "$model_name" "$context_display" "$cost_display" "$changes_display" "$current_dir"
