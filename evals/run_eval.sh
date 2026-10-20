#!/usr/bin/env bash
# ハーネス評価ランナー。使い方:
#   run_eval.sh <task> <tag> --selftest   … reference 解答で check が通ることを確認（課題の健全性検証）
#   run_eval.sh <task> <tag> --prepare    … 作業ツリーを用意して手順を表示（Antigravity 等で手動実行→ score.sh）
#   run_eval.sh <task> <tag> --exec       … claude -p で /startcycle を非対話実行→ score.sh（要 claude CLI。USD 上限あり）
# tag はハーネスの版名（例: baseline, after-x）。結果は evals/results.tsv に追記される。
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"; repo="$(dirname "$here")"
task="${1:?task}"; tag="${2:?tag}"; mode="${3:---prepare}"; t="$here/tasks/$task"
[ -d "$t" ] || { echo "no such task: $task (有効: $(ls "$here/tasks" | tr '\n' ' '))" >&2; exit 2; }
ws="$here/.work/$task-$tag-$(date +%H%M%S)"; mkdir -p "$ws"; cd "$ws"
[ -d "$t/fixture" ] && cp -r "$t/fixture/." .
git init -q && git add -A && git -c user.name=eval -c user.email=e@e commit -q --allow-empty -m "fixture"
if [ "$mode" = "--selftest" ]; then
  cp -r "$t/reference/." .; python3 "$t/check.py" "$ws"; exit $?
fi
mkdir .agents && (cd "$repo" && tar c --exclude=.git --exclude=evals .) | tar x -C .agents
git config user.name eval; git config user.email e@e
.agents/scripts/install.sh >/dev/null && git add -A && git commit -q -m "install harness"
request="$(cat "$t/task.md")"
if [ "$mode" = "--prepare" ]; then
  echo "作業ツリー: $ws"; echo "1) ここを開き /startcycle \"<task.md の内容>\" を実行（task.md: $t/task.md）"
  echo "2) 完了後: $here/score.sh $task $tag $ws"; exit 0
fi
[ "$mode" = "--exec" ] || { echo "unknown mode" >&2; exit 2; }
# 評価モード: 承認ゲートは自動化のためここでのみユーザー事前承認として扱う（本番の /startcycle では禁止）
start=$(date +%s)
claude -p --model sonnet --permission-mode acceptEdits --output-format json --max-turns 200 \
  --max-budget-usd "${EVAL_BUDGET_USD:-10}" --allowedTools "Read,Grep,Glob,Edit,Write,Bash" \
  "【評価モード】ユーザーは以下の要望の仕様を事前に承認済みとする。Step 1 の承認待ちでは、AC を自己点検して APPROVED を作成し先へ進んでよい（評価目的に限る）。/startcycle skill に従い Step 5 まで完走すること。
要望: $request" </dev/null > "$ws/eval-orchestrator.json" 2> "$ws/eval-orchestrator.err" || true
"$here/score.sh" "$task" "$tag" "$ws" "$(( $(date +%s) - start ))"
