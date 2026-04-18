#!/bin/bash
#
# To enable, add to ~/.claude/settings.json
# "statusLine": {
#    "type": "command",
#    "command": "~/.claude/statusline.sh"
#  }
#

input=$(cat)

echo "$input" > ~/claude_debug.json

# Parse data from your JSON
MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
TOTAL_TOKENS=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Tokens: count everything that occupies space in the context window
USED_TOKENS=$(echo "$input" | jq -r '(.context_window.total_input_tokens + .context_window.total_output_tokens) // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')

# API limits (your new feature)
RATE_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // 0')

DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Colors
CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; PURPLE='\033[35m'; RESET='\033[0m'

# Context color
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# API limits color
if [ "$RATE_PCT" -ge 80 ]; then RATE_COLOR="$RED"
else RATE_COLOR="$CYAN"; fi

# Draw progress bar
FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🛠️ $(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")

# Build cache block: if reading - purple lightning, if only creating - yellow
if [ "$CACHE_READ" -gt 100000 ]; then
    CACHE_INFO="${PURPLE}💎 MAX SAVINGS${RESET}"
elif [ "$CACHE_READ" -gt 0 ]; then
    CACHE_INFO="${PURPLE}⚡ CACHE IN USE${RESET}"
elif [ "$CACHE_CREATE" -gt 0 ]; then
    CACHE_INFO="${YELLOW}💰 WARMING CACHE ($)${RESET}"
else
    CACHE_INFO="🔘 EMPTY"
fi

if [ "$USED_TOKENS" -ge 1000 ]; then
    # Divide by 1000. Bash uses integer division (1500 -> 1)
    # For better precision, you could add a 'k' suffix
    USED_DISPLAY="$((USED_TOKENS / 1000))k"
else
    USED_DISPLAY="$USED_TOKENS"
fi

# Same logic for TOTAL_TOKENS
if [ "$TOTAL_TOKENS" -ge 1000 ]; then
    TOTAL_DISPLAY="$((TOTAL_TOKENS / 1000))k"
else
    TOTAL_DISPLAY="$TOTAL_TOKENS"
fi

# Final output string
echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH | ${BAR_COLOR}${BAR}${RESET} ${PCT}% | ${YELLOW}${COST_FMT}${RESET} | ${USED_DISPLAY}/${TOTAL_DISPLAY} | ${CACHE_INFO} | ⏳ API: ${RATE_COLOR}${RATE_PCT}%${RESET} | ⏱️ ${MINS}m ${SECS}s"