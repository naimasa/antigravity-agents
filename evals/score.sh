#!/usr/bin/env bash
# 使い方: score.sh <task> <tag> <workspace> [所要秒]   結果を evals/results.tsv に追記し 1 行表示
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; task="$1"; tag="$2"; ws="$3"; dur="${4:-NA}"
ws="$(cd "$ws" && pwd)" || exit 2; cd "$ws"
chk=$(python3 "$here/tasks/$task/check.py" "$ws" 2>&1 | tail -1 | cut -c1-80); [[ "$chk" == PASS ]] && ok=PASS || ok=FAIL
r=$(cat docs/runs/.current 2>/dev/null || true); d="docs/runs/$r"
[ -n "$r" ] && [ -f "$d/usage.tsv" ] || { echo "Run の記録が無い（/startcycle が走っていない）" >&2; r=NA; d=/nonexistent; }
calls=$(awk -F'\t' 'NR>1' "$d/usage.tsv" 2>/dev/null | wc -l)
usd=$(awk -F'\t' 'NR>1 && $1=="claude"{s+=$4} END{printf "%.2f", s+0}' "$d/usage.tsv" 2>/dev/null || echo 0)
tok=$(awk -F'\t' 'NR>1{s+=$5+$6} END{print s+0}' "$d/usage.tsv" 2>/dev/null || echo 0)
vruns=$(wc -l < "$d/verify/history.tsv" 2>/dev/null || echo 0)
vfail=$(grep -c FAIL "$d/verify/history.tsv" 2>/dev/null || true)
blocked=$(grep -c 'Blocked' "$d/journal.md" 2>/dev/null || true)
approved=$([ -f "$d/APPROVED" ] && echo Y || echo N)
[ -f "$here/results.tsv" ] || printf 'date\ttag\ttask\tcheck\tverify_runs\tverify_fails\tcli_calls\tclaude_usd\tcli_tokens\tblocked\tapproved\tsec\n' > "$here/results.tsv"
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$(date +%F)" "$tag" "$task" "$ok" "$vruns" "${vfail:-0}" "$calls" "$usd" "$tok" "${blocked:-0}" "$approved" "$dur" | tee -a "$here/results.tsv"
