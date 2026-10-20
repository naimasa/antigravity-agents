#!/usr/bin/env bash
# Step 5 用。journal/usage.tsv/git から実測値を集計し、usage.md に 1 行追記して集計を標準出力へ。
# 使い方: report.sh [mode] [gemini_self件数] [ブラウザ操作ステップ数]
. "$(dirname "$0")/_common.sh"
r="$(current_run)"; d="docs/runs/$r"; mode="${1:-balanced}"; self="${2:-0}"; browser="${3:-0}"
base=$(sed -n 's/^- \*\*起点コミット\*\*: //p' "$d/journal.md" | head -1)
cx=$(awk -F'\t' '$1=="codex"' "$d/usage.tsv" | wc -l); cl=$(awk -F'\t' '$1=="claude"' "$d/usage.tsv" | wc -l)
usd=$(awk -F'\t' 'NR>1 && $1=="claude"{s+=$4} END{printf "%.2f", s+0}' "$d/usage.tsv")
tok=$(awk -F'\t' 'NR>1{s+=$5+$6} END{print s+0}' "$d/usage.tsv")
tot=$((cx+cl+self)); rate=$([ "$tot" -gt 0 ] && echo $(( (cx+cl)*100/tot )) || echo 0)
f=docs/runs/usage.md
[ -f "$f" ] || { printf '# Usage Ledger\n\n| Run ID | 日時 | mode | Gemini自前 | ブラウザ操作 | Codex呼出 | Claude呼出 | Claude実測USD | CLI合計tokens | 委譲率 |\n|:---|:---|:---|--:|--:|--:|--:|--:|--:|--:|\n' > "$f"; }
row="| $r | $(date '+%Y-%m-%d %H:%M') | $mode | $self | $browser | $cx | $cl | $usd | $tok | ${rate}% |"
awk -v row="$row" 'BEGIN{done=0} {print} /^\|:---/ && !done {print row; done=1}' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
echo "起点: $base → 最終: $(git rev-parse --short HEAD)"; echo "委譲率 ${rate}% (Codex $cx / Claude $cl / Gemini自前 $self) USD=$usd tokens=$tok"
[ "$mode" = balanced ] && [ "$rate" -lt 50 ] && echo "⚠️ 委譲率が 50% 未満: report に理由を明記"
echo "verify: $(cat "$d/verify/latest.txt" 2>/dev/null || echo 未実行)"; echo '--- diff --stat ---'; git diff --stat "$base"..HEAD 2>/dev/null | tail -n 30
