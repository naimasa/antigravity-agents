#!/usr/bin/env bash
# 共通ヘルパ。親プロジェクトのルートで実行する前提（docs/ は親側）。
set -euo pipefail
current_run() {
  if [ -n "${RUN_ID:-}" ]; then echo "$RUN_ID"; return; fi
  [ -f docs/runs/.current ] || { echo "RUN_ID 未設定: scripts/run_init.sh を先に実行" >&2; exit 2; }
  cat docs/runs/.current
}
