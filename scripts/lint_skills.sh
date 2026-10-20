#!/usr/bin/env bash
# このリポジトリ自身の整合性チェック（CI/手元用）。frontmatter・名前=フォルダ名・参照先skillの存在・サイズ。
set -uo pipefail
cd "$(dirname "$0")/.."; fail=0
names=$(ls skills)
for d in skills/*/; do
  n=$(basename "$d"); f="$d/SKILL.md"
  [ -f "$f" ] || { echo "NG $n: SKILL.md なし"; fail=1; continue; }
  [ "$(sed -n 1p "$f")" = "---" ] || { echo "NG $n: frontmatter なし"; fail=1; }
  [ "$(sed -n 's/^name: //p' "$f" | head -1)" = "$n" ] || { echo "NG $n: name がフォルダ名と不一致"; fail=1; }
  sed -n 's/^description: //p' "$f" | head -1 | grep -q . || { echo "NG $n: description なし"; fail=1; }
  [ "$(wc -c < "$f")" -le 8000 ] || { echo "WARN $n: 8KB 超 (段階的開示のため分割を検討)"; }
done
# 旧形式の参照が残っていないか
if grep -rnE '[a-z]+_[a-z]+\.md' skills agents.md workflows 2>/dev/null | grep -v 'quota\.'; then echo "NG: 旧 skill ファイル名の参照"; fail=1; fi
# バッククォート内 skill 参照の存在確認
for r in $(grep -rhoE '`(write|generate|audit|deploy|track|manage|verify|report)-[a-z-]+`' skills agents.md | tr -d '`' | sort -u); do
  echo "$names" | grep -qx "$r" || { echo "NG: 存在しない skill 参照 $r"; fail=1; }
done
bash -n scripts/*.sh 2>/dev/null; for s in scripts/*.sh; do bash -n "$s" || fail=1; done
[ $fail -eq 0 ] && echo "OK" ; exit $fail
