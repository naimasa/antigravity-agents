# Skill: Track Progress（全ペルソナ共通・記録規約）

各ペルソナの成果を 1 か所に集約し、「誰が・何を・どの CLI で・どのファイルに・どうなったか」を後から追える状態にする。**Run 中に一度読めば足りる。**

## RUN_ID
`/startcycle` の 1 実行 = 1 Run。`RUN_ID = $(date +%Y%m%d-%H%M%S)-<kebab-slug>`（slug は要望の英語要約 3〜5 語）。
Step 0 で採番し、**全ペルソナが同一 RUN_ID を使う**（ペルソナ切替時に再採番しない）。

## レイアウト（親プロジェクト側）
```
docs/spec.md                    # 生きた仕様書（常に最新の To-Be）
docs/specs/<RUN_ID>.md          # 承認時点のスナップショット（不変）
docs/runs/index.md              # 全 Run 一覧
docs/runs/<RUN_ID>/journal.md   # 逐次作業ログ（追記のみ）
docs/runs/<RUN_ID>/report.md    # 最終レポート（report_run.md が生成）
docs/runs/<RUN_ID>/raw/<NN>-<cli>-<persona>-<topic>.md   # CLI 生出力。NN は Run 内通番
```

## Rules
- **追記のみ**: 既存エントリを書き換えない。訂正は新エントリで行う。
- **即時記録**: 各ステップ完了直後に書く（末尾一括は禁止。中断時に記録が残らないため）。
- **CLI 生出力を残す**: `codex exec -o docs/runs/$RUN_ID/raw/<NN>-...` / `claude -p ... | tee docs/runs/$RUN_ID/raw/<NN>-...`
- **実測値**: Changed Files は `git diff --stat` の出力から転記する（記憶で書かない）。
- **正直に**: 失敗・未完了・スキップも `❌ Blocked` / `⚠️ Warning` として残す。
- **委譲理由**: `agents.md` のルーティング規約で CLI 指定のタスクを Antigravity が自前処理した場合、Findings に理由を必ず書く。
- **秘匿情報**: 環境変数名は書いてよいが値（APIキー・トークン等）は書かない。

## Journal 書式
冒頭ヘッダに Run ID / 開始時刻 / ユーザー要望の原文 / 起点コミット（`git rev-parse --short HEAD`）。以降この形式で追記する。

```markdown
## [YYYY-MM-DD HH:MM:SS] @<persona> — <一行要約>
- **Status**: ✅ Done / ⚠️ Warning / ❌ Blocked / ⏸ Awaiting Approval
- **Input**: 参照した仕様・指示
- **Actions**: 実施内容（箇条書き）
- **Changed Files**: `path` (+N / -M) ／ なし
- **CLI Calls**: `<cli>` — 目的 → [raw/NN-....md](raw/NN-....md) ／ なし
- **Cost**: Claude=`total_cost_usd` 実測値 ／ Codex=呼出回数 ／ Gemini自前=件数
- **Findings / Issues**: 検出した問題・残課題
- **Next**: 次ペルソナへの申し送り
```
