# Skill: Write Specs（@pm）

ユーザーの要望（新規開発・改善・リファクタリング）を技術仕様書に落とし込み、**明示的な承認を得るまで待機・反復**する。併せて仕様書の過去版を失わないことを保証する。

## Rules
- **出力先**: 最新版は必ず `docs/spec.md`（＝常に現時点の To-Be を表す「生きた仕様書」）。
- **上書き前の保全（重要）**: Git 管理下でも**未コミットの版は上書きで消える**。書き換え前に必ず:
  1. `git rev-parse --git-dir` — 失敗したら**上書きせず** `git init` をユーザーに促す。
  2. `git status --porcelain docs/spec.md` に変更があれば `git commit -m "docs(spec): save previous revision before <RUN_ID>"` で退避してから上書きする。
- **承認時スナップショット**: 承認後 `mkdir -p docs/specs && cp docs/spec.md docs/specs/$RUN_ID.md` を実行し、`docs/spec.md` `docs/specs/$RUN_ID.md` `docs/runs/$RUN_ID` を `docs(spec): approve spec for <RUN_ID>` としてコミットする。
- **Approval Gate**: 仕様書作成後は必ず停止し、承認（"Approved"）またはフィードバックを求める。チャットまたは `docs/spec.md` 内のコメントで修正指示が来たら改訂して再承認を求め、**往復のたびに上記の保全を実施する**（過程も履歴に残る）。
- **既存システム**: 既存コードや外部移行元（WordPress等）があれば、As-Is のアーキテクチャ・依存関係・実データ（API/Sitemap等の抽出結果）を Antigravity が事前に収集して CLI へ渡し、To-Be との差分と破壊的変更の有無を明記する。
- **記録**: `track_progress.md` に従う。停止前に `⏸ Awaiting Approval`、承認後に `✅ Done` を journal へ追記する。既存コードベースの構造把握・アーキテクチャ設計は **Claude Code CLI へ委譲する**（`agents.md` のルーティング規約）。生出力を `raw/` へ保存し、`total_cost_usd` を Cost に記録する。

## Instructions
1. **初期化**: `track_progress.md` に従い `RUN_ID` を採番、`docs/runs/$RUN_ID/` と journal ヘッダを作成する。
2. **分析**: 新規なら要望・目的・想定ユーザー。改修なら既存コードのボトルネック・課題・影響範囲。
3. **`docs/spec.md` を作成**（保全手順の実施後に書き出す）。構成:
   - Revision History（下記書式・追記のみ）
   - Executive Summary（概要・目的）
   - Current State vs Proposed Changes（As-Is / To-Be。既存コードがある場合）
   - Functional & Non-functional Requirements
   - Architecture & Tech Stack
   - Data & State Flow
   - Deployment & Hosting Strategy（デプロイ先の選定と手順）
4. **承認確認**: 「この仕様で進めてよろしいでしょうか？`docs/spec.md` をご確認のうえ承認（Approved）または修正指示をお願いします。」と伝えて停止する。

## Revision History 書式（`docs/spec.md` 冒頭 / 追記のみ）
```markdown
## Revision History
| Rev | Run ID | 日付 | 変更概要 | 承認 |
|:---:|:---|:---|:---|:--:|
| 1 | 20260829-101500-othello-init | 2026-08-29 | 初版（オセロ基本実装） | ✅ |
```
