#!/usr/bin/env bash
# CLI が既存コードを文書に合わせて書き換える事故（stale instruction による書き換え）の検出。警告のみで常に exit 0。
# 使い方: scope_check.sh snapshot <出力ファイル>      … CLI 呼出の前に作業ツリーのハッシュを記録
#         scope_check.sh check <brief.md> <snapshot>  … 呼出後、brief の「## 触るファイル」の外の変更と既存ファイルの大幅削除を警告
set -uo pipefail
mode="${1:?mode}"
snap() { git ls-files -m -o --exclude-standard -z | xargs -0 -r sha1sum 2>/dev/null | LC_ALL=C sort; }
case "$mode" in
snapshot) snap > "${2:?out}";;
check)
  brief="${2:?brief}"; before="${3:?snapshot}"
  changed=$(LC_ALL=C comm -13 "$before" <(snap) | awk '{print $2}'; git ls-files -d | sed 's/$//')
  changed=$(printf '%s\n' "$changed" | sort -u | grep -v '^$' | grep -v '^docs/' || true)
  [ -n "$changed" ] || exit 0
  allow=$(awk '/^##[[:space:]]*触るファイル/{f=1;next} /^##/{f=0} f && /^[-*][[:space:]]/{sub(/^[-*][[:space:]]+/,""); gsub(/`/,""); print}' "$brief")
  warn=0
  if [ -n "$allow" ]; then
    while IFS= read -r f; do
      ok=0; while IFS= read -r p; do [[ "$f" == $p || "$f" == $p/* ]] && ok=1 && break; done <<<"$allow"
      [ $ok -eq 1 ] || { echo "⚠️ SCOPE: brief の範囲外を変更: $f"; warn=1; }
    done <<<"$changed"
  else echo "ℹ️ SCOPE: brief に「## 触るファイル」が無いため範囲検査をスキップ"; fi
  while IFS= read -r f; do
    git ls-files --error-unmatch "$f" >/dev/null 2>&1 || continue
    del=$(git diff --numstat HEAD -- "$f" | awk '{print $2+0}')
    [ "${del:-0}" -ge 20 ] && { echo "⚠️ SCOPE: 既存ファイルで ${del} 行削除: $f（文書に合わせた書き換えでないか確認）"; warn=1; }
  done <<<"$changed"
  [ $warn -eq 1 ] && echo "→ 意図した変更か diff を確認すること。意図外なら brief に従って差し戻す" ;;
*) echo "usage: scope_check.sh snapshot|check" >&2;;
esac
exit 0
