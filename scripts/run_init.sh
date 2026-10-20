#!/usr/bin/env bash
# 使い方: run_init.sh <kebab-slug> "<ユーザー要望の原文>"
# RUN_ID 採番・ディレクトリ・journal ヘッダ・STATE.md を作成し、RUN_ID を標準出力へ。
. "$(dirname "$0")/_common.sh"
slug="${1:?slug}"; request="${2:?request}"
git rev-parse --git-dir >/dev/null 2>&1 || { echo "Git リポジトリではありません。git init を実施してください" >&2; exit 3; }
RUN_ID="$(date +%Y%m%d-%H%M%S)-$slug"
d="docs/runs/$RUN_ID"
mkdir -p "$d/raw" "$d/briefs" "$d/verify" docs/specs
echo "$RUN_ID" > docs/runs/.current
{
  echo "# Journal — $RUN_ID"
  echo
  echo "- **Run ID**: $RUN_ID"
  echo "- **開始**: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- **起点コミット**: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
  echo "- **ユーザー要望**: $request"
} > "$d/journal.md"
printf 'cli\tmodel\tfile\tusd\tin_tokens\tout_tokens\n' > "$d/usage.tsv"
"$(dirname "$0")/state.sh" "Step 0 完了" "Step 1 (@pm) 仕様作成" "なし"
echo "$RUN_ID"
