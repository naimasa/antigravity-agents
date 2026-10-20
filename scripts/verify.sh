#!/usr/bin/env bash
# 機械的な合否判定（lint/型/テスト/E2E）。LLM 推論を使わない。
# 使い方: verify.sh            … docs/verify.json の steps を順に実行。全通過で exit 0
#         verify.sh --detect   … スタックを検出して docs/verify.json の雛形を生成（要レビュー）
# 失敗時は失敗ステップ末尾のログだけを標準出力に出す（修正ループにはこれだけ渡す）。
. "$(dirname "$0")/_common.sh"
cfg=docs/verify.json
if [ "${1:-}" = "--detect" ]; then
  steps='[]'; add(){ steps=$(jq -c --arg n "$1" --arg c "$2" '. + [{name:$n,cmd:$c}]' <<<"$steps"); }
  for d in . src; do
    if [ -f "$d/package.json" ]; then
      for s in lint typecheck test test:e2e; do
        jq -e --arg s "$s" '.scripts[$s]' "$d/package.json" >/dev/null 2>&1 && add "$s" "(cd $d && npm run -s $s)"
      done
    fi
    [ -f "$d/pyproject.toml" -o -f "$d/pytest.ini" -o -d "$d/tests" ] && command -v pytest >/dev/null && add pytest "(cd $d && pytest -q)"
    [ -f "$d/go.mod" ] && add go-test "(cd $d && go test ./...)"
  done
  mkdir -p docs; jq -n --argjson s "$steps" '{steps:$s}' > "$cfg"
  echo "生成: $cfg（内容を確認・調整すること。steps が空なら検証手段が無い=テスト整備が先）"; cat "$cfg"; exit 0
fi
[ -f "$cfg" ] || { echo "docs/verify.json 無し。verify.sh --detect を実行" >&2; exit 2; }
r="$(current_run)"; vd="docs/runs/$r/verify"; mkdir -p "$vd"
n=$(jq '.steps|length' "$cfg")
[ "$n" -gt 0 ] || { echo "steps が空: 検証不能（=未検証として扱う）" | tee "$vd/latest.txt"; exit 4; }
fail=0; summary=""
for i in $(seq 0 $((n-1))); do
  name=$(jq -r ".steps[$i].name" "$cfg"); cmd=$(jq -r ".steps[$i].cmd" "$cfg")
  if bash -c "$cmd" >"$vd/$name.log" 2>&1; then summary+="$name:PASS "
  else summary+="$name:FAIL "; fail=1; echo "--- FAIL: $name ($cmd) 末尾40行 ---"; tail -n 40 "$vd/$name.log"; break; fi
done
echo "$summary" | tee "$vd/latest.txt"
exit $fail
