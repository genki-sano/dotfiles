#!/bin/bash

# 標準入力からJSON形式のデータを読み込む
input=$(cat)

# 各種情報を取得
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // "0"')
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // "0"')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_api_duration_ms // "0"')

# 各種色情報を定義
ESC=$(printf '\033')
CYAN="${ESC}[36m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
RESET="${ESC}[0m"

# プロセスバーの色を定義
if [ "$PCT" -ge 90 ]; then
  BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
  BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# プロセスバーを作成
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | tr ' ' '▓')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | tr ' ' '░')"

# レイテンシを秒に変換（小数点1桁）
LATENCY=$(echo "scale=1; $DURATION_MS / 1000" | bc)

# ステータスライン表示
echo -e "${CYAN}[${MODEL}]${RESET} ${INPUT_TOKENS}/${OUTPUT_TOKENS} tokens | ${BAR_COLOR}${BAR}${RESET} ${PCT}% context | ⏱️${LATENCY}s"
