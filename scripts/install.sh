#!/usr/bin/env bash
# 親プロジェクトのルートで実行: .agents/scripts/install.sh [--local]   （冪等）
#   既定   : チーム共有向け。生成物（.claude/skills・AGENTS.md・.gitignore）はコミット対象になる
#   --local: 個人利用向け。生成物を .git/info/exclude で除外し、git の差分に出さない
#            （追跡済みの AGENTS.md は変更せず、管理ブロックの手動追記を案内する）
# - Antigravity / Codex: <root>/.agents/skills/<name>/SKILL.md をネイティブ探索するため追加作業なし
# - Claude Code: .claude/skills/<name> へシンボリックリンクを作成
# - AGENTS.md に管理ブロックを追記（Codex・Antigravity・CLAUDE.md 不在の Claude Code が読む）
# - docs/ 配下の雛形と .gitignore を整備
set -euo pipefail
local_mode=0; [ "${1:-}" = "--local" ] && local_mode=1
here="$(cd "$(dirname "$0")/.." && pwd)"
[ "$(basename "$here")" = ".agents" ] || { echo "このリポジトリは親プロジェクトの .agents/ として配置してください (現在: $here)" >&2; exit 2; }
root="$(dirname "$here")"; cd "$root"
git rev-parse --git-dir >/dev/null 2>&1 || { echo "親プロジェクトが Git リポジトリではありません。git init を実施してください" >&2; exit 3; }

mkdir -p .claude/skills docs/specs docs/runs
for d in .agents/skills/*/; do
  n=$(basename "$d"); ln -sfn "../../.agents/skills/$n" ".claude/skills/$n"
done
echo "Claude Code: .claude/skills に $(ls .agents/skills | wc -l) 件リンク"

begin='<!-- antigravity-agents:begin -->'; end='<!-- antigravity-agents:end -->'
block="$begin
## Autonomous developer pipeline
開発要望は \`/startcycle <要望>\`（skill: \`.agents/skills/startcycle\`）で進める。ペルソナ・ルーティング・原則は \`.agents/agents.md\`。
完了の定義は \`.agents/scripts/verify.sh\` の通過。記録・CLI 呼出は \`.agents/scripts/\` を使う。
$(cat "$here/scripts/precedence.txt")
$end"
exclude="$(git rev-parse --git-path info/exclude)"; mkdir -p "$(dirname "$exclude")"; touch "$exclude"
add_exclude() { grep -qxF "$1" "$exclude" || echo "$1" >> "$exclude"; }
if [ $local_mode -eq 1 ]; then
  for d in .agents/skills/*/; do add_exclude "/.claude/skills/$(basename "$d")"; done
  if [ -f AGENTS.md ] && git ls-files --error-unmatch AGENTS.md >/dev/null 2>&1; then
    echo "AGENTS.md は追跡済みのため変更しません（--local）。必要なら以下を手動で追記してください:"; printf '%s\n' "$block"
    skip_agents=1
  else add_exclude "/AGENTS.md"; fi
  add_exclude "/.agents/quota.local.yml"
  # サブモジュールでなく単なる clone で置いた場合は、.agents/ 自体も差分に出さない
  git ls-files -s .agents 2>/dev/null | grep -q '^160000' || add_exclude "/.agents/"
fi
if [ "${skip_agents:-0}" -eq 1 ]; then :; else
touch AGENTS.md
if grep -qF "$begin" AGENTS.md; then
  awk -v b="$begin" -v e="$end" -v blk="$block" '$0==b{print blk; skip=1; next} $0==e{skip=0; next} !skip' AGENTS.md > AGENTS.md.tmp && mv AGENTS.md.tmp AGENTS.md
else printf '\n%s\n' "$block" >> AGENTS.md; fi
echo "AGENTS.md: 管理ブロックを更新"
fi
if [ -f CLAUDE.md ] && ! grep -q '@AGENTS.md' CLAUDE.md; then
  echo "注意: CLAUDE.md があると Claude Code は AGENTS.md を読みません。CLAUDE.md に '@AGENTS.md' を1行追加してください"
fi

if [ $local_mode -eq 0 ]; then
  grep -qxF '.agents/quota.local.yml' .gitignore 2>/dev/null || echo '.agents/quota.local.yml' >> .gitignore
  echo "共有モード: .claude/skills・AGENTS.md・.gitignore の変更をコミットしてください（個人利用だけなら --local）"
else echo "--local: 生成物は $exclude で除外済み（git status に出ません）"; fi
echo "完了。次: .agents/scripts/verify.sh --detect でテスト実行手段を確認 → /startcycle \"<要望>\""
