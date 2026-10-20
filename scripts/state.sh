#!/usr/bin/env bash
# 使い方: state.sh "<現在>" "<次の1手>" "<Blocker or なし>"
# docs/runs/<RUN_ID>/STATE.md を上書き（20行以内）。再開時はこれだけ読めばよい。
. "$(dirname "$0")/_common.sh"
r="$(current_run)"
{
  echo "# STATE — $r"
  echo "- 現在: $1"
  echo "- 次の1手: $2"
  echo "- Blocker: $3"
  echo "- 最新 verify: $(cat "docs/runs/$r/verify/latest.txt" 2>/dev/null || echo 未実行)"
  echo "- 更新: $(date '+%Y-%m-%d %H:%M:%S')"
} > "docs/runs/$r/STATE.md"
