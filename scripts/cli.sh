#!/usr/bin/env bash
# 外部 CLI 呼び出しの唯一の入口。フラグ・生出力保存・コスト記録・Usage Limit 検知を一元化する。
# 使い方: cli.sh <codex|claude-sonnet|claude-opus> <brief.md> <persona-topic>   例: cli.sh codex docs/runs/$RID/briefs/01.md engineer-cart
# 出力: 標準出力に「結果本文のパス」と先頭の要約行のみ。全文は Antigravity が読む必要があるときだけ開く。
# 終了コード: 0=成功 / 75=Usage Limit（呼び出し側は manage_quota.md に従いユーザーへ確認） / その他=失敗
. "$(dirname "$0")/_common.sh"
kind="${1:?kind}"; brief="${2:?brief}"; topic="${3:?topic}"
r="$(current_run)"; raw="docs/runs/$r/raw"; mkdir -p "$raw"
n=$(printf '%02d' $(( $(ls "$raw" 2>/dev/null | grep -c -- '-result\.md$') + 1 )))
out="$raw/$n-$kind-$topic"
prompt="次のファイルが今回のタスク指示書です。読み、その指示と完了条件に従ってください: $brief
作業後、最終メッセージには (1)変更したファイル (2)verify結果 (3)未解決事項 のみを簡潔に書くこと。"
limit_re='rate.?limit|429|quota|usage limit|insufficient|credit|overloaded'
case "$kind" in
  codex)
    # 既定は workspace-write。ネットワーク/デプロイが必要な場合のみ CODEX_SANDBOX=danger-full-access を明示
    echo "$prompt" | codex exec -o "$out-result.md" --skip-git-repo-check --ephemeral \
      -s "${CODEX_SANDBOX:-workspace-write}" >"$out-log.txt" 2>&1 || rc=$?
    echo -e "codex\t-\t$out-result.md\t0\t0\t0" >> "docs/runs/$r/usage.tsv";;
  claude-sonnet|claude-opus)
    m=${kind#claude-}; budget=2.00; [ "$m" = opus ] && budget=5.00
    # bypassPermissions は使わず、許可ツールを明示。CLAUDE_TOOLS で上書き可
    claude -p --model "$m" --output-format json --max-budget-usd "$budget" \
      --max-turns "${CLAUDE_MAX_TURNS:-30}" --permission-mode acceptEdits \
      --allowedTools "${CLAUDE_TOOLS:-Read,Grep,Glob,Edit,Write,Bash}" \
      "$prompt" </dev/null >"$out.json" 2>"$out-log.txt" || rc=$?
    if [ -s "$out.json" ] && jq -e . "$out.json" >/dev/null 2>&1; then
      jq -r '.result // ""' "$out.json" > "$out-result.md"
      echo -e "claude\t$m\t$out.json\t$(jq -r '.total_cost_usd // 0' "$out.json")\t$(jq -r '(.usage.input_tokens // 0)+(.usage.cache_read_input_tokens // 0)+(.usage.cache_creation_input_tokens // 0)' "$out.json")\t$(jq -r '.usage.output_tokens // 0' "$out.json")" >> "docs/runs/$r/usage.tsv"
    else : > "$out-result.md"; echo -e "claude\t$m\t-\t0\t0\t0" >> "docs/runs/$r/usage.tsv"; fi;;
  *) echo "unknown kind: $kind" >&2; exit 2;;
esac
if [ "${rc:-0}" -ne 0 ] && grep -qiE "$limit_re" "$out-log.txt" "$out-result.md" 2>/dev/null; then
  echo "USAGE_LIMIT: $kind が利用制限に到達。manage_quota.md に従いユーザーへ選択肢を提示すること ($out-log.txt)"; exit 75
fi
[ "${rc:-0}" -eq 0 ] || { echo "FAILED rc=$rc: tail of $out-log.txt"; tail -n 15 "$out-log.txt"; exit "$rc"; }
echo "RESULT: $out-result.md"; head -n 5 "$out-result.md"
