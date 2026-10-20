#!/usr/bin/env bash
# 親プロジェクトのルートで実行: .agents/scripts/install.sh   （冪等）
# - Antigravity / Codex: <root>/.agents/skills/<name>/SKILL.md をネイティブ探索するため追加作業なし
# - Claude Code: .claude/skills/<name> へシンボリックリンクを作成
# - AGENTS.md に管理ブロックを追記（Codex・Antigravity・CLAUDE.md 不在の Claude Code が読む）
# - docs/ 配下の雛形と .gitignore を整備
set -euo pipefail
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
$end"
touch AGENTS.md
if grep -qF "$begin" AGENTS.md; then
  awk -v b="$begin" -v e="$end" -v blk="$block" '$0==b{print blk; skip=1; next} $0==e{skip=0; next} !skip' AGENTS.md > AGENTS.md.tmp && mv AGENTS.md.tmp AGENTS.md
else printf '\n%s\n' "$block" >> AGENTS.md; fi
echo "AGENTS.md: 管理ブロックを更新"
if [ -f CLAUDE.md ] && ! grep -q '@AGENTS.md' CLAUDE.md; then
  echo "注意: CLAUDE.md があると Claude Code は AGENTS.md を読みません。CLAUDE.md に '@AGENTS.md' を1行追加してください"
fi

grep -qxF '.agents/quota.local.yml' .gitignore 2>/dev/null || echo '.agents/quota.local.yml' >> .gitignore
echo "完了。次: .agents/scripts/verify.sh --detect でテスト実行手段を確認 → /startcycle \"<要望>\""
