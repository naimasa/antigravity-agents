#!/usr/bin/env bash
# 文書（ARCHITECTURE.md）の陳腐化検査。警告のみで常に exit 0。Step 0 で実行する。
# 使い方: doc_drift.sh           … 検査   /   doc_drift.sh --stamp … 現在のコミットを "as of" として記録
set -uo pipefail
f=docs/ARCHITECTURE.md
if [ "${1:-}" = "--stamp" ]; then
  [ -f "$f" ] || { echo "$f なし" >&2; exit 0; }
  sha=$(git rev-parse --short HEAD); sed -i '/^<!-- as of: /d' "$f"; sed -i "1i <!-- as of: $sha -->" "$f"; echo "stamped: $sha"; exit 0
fi
[ -f "$f" ] || { echo "ℹ️ DRIFT: $f が無い（新規なら Step 1 で作成）"; exit 0; }
warn=0
sha=$(sed -n 's/^<!-- as of: \(.*\) -->$/\1/p' "$f" | head -1)
if [ -z "$sha" ]; then echo "⚠️ DRIFT: $f に 'as of' が無い。@pm が見直して doc_drift.sh --stamp を実行"; warn=1
elif git cat-file -e "$sha^{commit}" 2>/dev/null; then
  n=$(git diff --name-only "$sha"..HEAD -- . ':!docs' 2>/dev/null | wc -l)
  [ "$n" -gt 20 ] && { echo "⚠️ DRIFT: $f 作成($sha)以降にソース $n ファイルが変更されている"; warn=1; }
else echo "⚠️ DRIFT: as of $sha が履歴に無い"; warn=1; fi
for p in $(grep -oE '`[A-Za-z0-9_./-]+(/[A-Za-z0-9_.-]+|\.[a-z]{1,5})`' "$f" | tr -d '`' | sort -u); do
  case "$p" in http*|*://*|docs/runs/*|*'<'*) continue;; esac
  [ -e "$p" ] || { echo "⚠️ DRIFT: $f が参照する $p が存在しない"; warn=1; }
done
# 過去 Run の未対応 [DOC-DRIFT] 報告
rep=$(grep -h '\[DOC-DRIFT\]' docs/runs/*/journal.md 2>/dev/null | tail -n 5)
[ -n "$rep" ] && { echo "ℹ️ 過去 Run が報告した文書とコードの不一致（@pm が文書を修正すること）:"; echo "$rep"; }
[ $warn -eq 0 ] && echo "OK: $f は大きなずれなし"
exit 0
