#!/bin/bash

# 標準入力からJSON形式のデータを読み込む
input=$(cat)

# 各種情報を取得
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // "0"')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // "0"')

# 各種色情報を定義
ESC=$(printf '\033')
CYAN="${ESC}[36m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
GRAY="${ESC}[90m"
RESET="${ESC}[0m"

# プロセスバーの色を取得
get_bar_color() {
  local pct=$1
  local base=${2:-$GREEN}
  if [ "$pct" -ge 80 ]; then
    echo "$RED"
  elif [ "$pct" -ge 50 ]; then
    echo "$YELLOW"
  else
    echo "$base"
  fi
}

# プロセスバーを作成
make_progress_bar() {
  local pct=$1
  local width=${2:-10}
  local filled=$((pct * width / 100))
  local empty=$((width - filled))
  local bar=""
  for ((i = 0; i < filled; i++)); do bar+="█"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  echo "$bar"
}

# コンテキスト使用率
ctx_str=""
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
ctx_bar=$(make_progress_bar $ctx_pct 10)
ctx_bar_color=$(get_bar_color $ctx_pct "$GREEN")
ctx_str="📊 context ${ctx_bar_color}${ctx_bar}${RESET} ${ctx_pct}%"

# レート制限（5時間）
five_hour_str=""
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five_hour_pct" ]; then
  five_hour_int=$(printf "%.0f" "$five_hour_pct")
  hour_color=$(get_bar_color $five_hour_int "$RESET")
  hour_bar=$(make_progress_bar $five_hour_int 10)

  time_left=""
  reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  if [ -n "$reset_epoch" ]; then
    diff=$((reset_epoch - $(date +%s)))
    if [ "$diff" -gt 0 ]; then
      time_left=" ${GRAY}($((diff / 3600))h$(((diff % 3600) / 60))m)${RESET}"
    fi
  fi

  five_hour_str="⏱️ 5h [${hour_color}${hour_bar}${RESET}] ${hour_color}${five_hour_int}%${RESET}${time_left}"
fi

# レート制限（7日間）
seven_day_str=""
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$seven_day_pct" ]; then
  seven_day_int=$(printf "%.0f" "$seven_day_pct")
  week_color=$(get_bar_color $seven_day_int "$RESET")
  week_bar=$(make_progress_bar $seven_day_int 10)
  seven_day_str="📅 7d [${week_color}${week_bar}${RESET}] ${week_color}${seven_day_int}%${RESET}"
fi

# ステータスライン表示
echo -n "${CYAN}[${MODEL}]${RESET} ${INPUT_TOKENS}/${OUTPUT_TOKENS} tokens | ${ctx_str}"
[ -n "$five_hour_str" ] && echo -n " | $five_hour_str"
[ -n "$seven_day_str" ] && echo -n " | $seven_day_str"
echo
