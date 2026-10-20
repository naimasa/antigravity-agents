#!/usr/bin/env bash
# 使い方: compare.sh [task]   tag ごとに平均を表示（check 成功率・verify失敗・USD・tokens）
here="$(cd "$(dirname "$0")" && pwd)"; f="$here/results.tsv"; [ -f "$f" ] || { echo "results.tsv なし"; exit 1; }
{ printf "%-28s %3s %6s %8s %7s %10s %6s\n" 'task tag' n 'pass%' vfail usd tokens calls
awk -F'\t' -v t="${1:-}" 'NR>1 && (t=="" || $3==t){k=$3" "$2; n[k]++; p[k]+=($4=="PASS"); vf[k]+=$6; u[k]+=$8; tk[k]+=$9; cc[k]+=$7}
 END{for(k in n) printf "%-28s %3d %5.0f%% %8.1f %7.2f %10.0f %6.1f\n",k,n[k],100*p[k]/n[k],vf[k]/n[k],u[k]/n[k],tk[k]/n[k],cc[k]/n[k]}' "$f" | sort; }
