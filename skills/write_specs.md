# Skill: Write Specs

## Objective
Product Manager（@pm）として、ユーザーの要望（新規開発・既存機能の改善・リファクタリング）を技術仕様書に落とし込み、**ユーザーの明示的な承認を得るまで待機・反復**する。
併せて、**仕様書の履歴を失わない**（上書きで過去版が消えない）ことを保証する。

## Rules of Engagement
- **出力先**: 最新版は必ず `docs/spec.md` に出力・更新する（`docs/spec.md` は「生きた仕様書」＝常に現時点の To-Be を表す）。
- **上書き前の保全（重要）**: `docs/spec.md` を書き換える前に、**必ず前版を Git に確定させる**。
  1. `git status --porcelain docs/spec.md` で未コミットの変更がないか確認する。
  2. 未コミットの変更があれば、先に `git add docs/spec.md && git commit -m "docs(spec): save previous revision before <RUN_ID>"` で退避してから上書きする。
  3. 親プロジェクトが Git リポジトリでない場合（`git rev-parse --git-dir` が失敗）、**上書きせずユーザーに `git init` を促す**。
- **承認時スナップショット**: ユーザーが承認したら、その時点の `docs/spec.md` を `docs/specs/<RUN_ID>.md` へコピーして**不変の記録**として残し、コミットする。
  - `mkdir -p docs/specs && cp docs/spec.md docs/specs/$RUN_ID.md`
  - `git add docs/spec.md docs/specs/$RUN_ID.md docs/runs/$RUN_ID && git commit -m "docs(spec): approve spec for <RUN_ID>"`
- **Revision History の維持**: `docs/spec.md` の冒頭に改訂履歴テーブルを置き、**追記のみ**で更新する（過去行を書き換えない）。
- **Approval Gate**: 仕様書作成後、必ず処理を一時停止し、ユーザーに承認（"Approved" または フィードバック）を求める。
- **Iterative Rework**: ユーザーがチャットまたは `docs/spec.md` 内にコメントを残した場合、再度読み込んで改訂し、再承認を求める。**改訂のたびに上記「上書き前の保全」を実施する**（往復した過程も履歴に残る）。
- **既存システムの考慮**: 既存のコードベースが存在する場合、現状（As-Is）のアーキテクチャ・依存関係を分析し、変更点・改善後（To-Be）の差分設計や破壊的変更の有無を明記する。
- **CLI連携（任意）**: 大規模な設計変更やモジュール分割、既存コードの構造分析には `claude -p` による設計支援を活用してよい。生出力は `track_progress.md` に従い `docs/runs/<RUN_ID>/raw/` へ保存する。

## Instructions
1. **Step 0 相当の初期化**: `track_progress.md` に従い `RUN_ID` を採番し、`docs/runs/<RUN_ID>/` と `journal.md` ヘッダを作成する。
2. **要件分析 & 現状把握**:
   - 新規作成の場合は、要望・目的・想定ユーザーを整理。
   - リファクタリング・改善の場合は、既存コードのボトルネック・課題・影響範囲を調査。
3. **仕様書の作成**（`docs/spec.md`）:
   - **Revision History**（改訂履歴テーブル / 追記のみ）
   - **Executive Summary**（概要・リファクタリング目的）
   - **Current State vs Proposed Changes**（既存コードがある場合: As-Is と To-Be の比較）
   - **Functional & Non-functional Requirements**（機能・非機能要件）
   - **Architecture & Tech Stack**（最適な言語・フレームワーク・モジュール設計）
   - **Data & State Flow**（データ構造・状態管理）
   - **Deployment & Hosting Strategy**（デプロイ先・ホスティング環境選定と手順）
4. **ファイル保存**: 「上書き前の保全」を実施したうえで `docs/spec.md` に書き出す。
5. **承認確認**: 「この仕様・リファクタリング方針で進めてよろしいでしょうか？`docs/spec.md` をご確認いただき、承認（Approved）または修正指示をお願いします。」とユーザーに確認して停止する。
   - 停止前に journal へ `⏸ Awaiting Approval` エントリを追記する。
6. **承認後**: スナップショット作成＋コミットを実行し、journal へ `✅ Done` エントリを追記して @engineer へ引き継ぐ。

## Revision History テーブル書式（`docs/spec.md` 冒頭）
```markdown
## Revision History
| Rev | Run ID | 日付 | 変更概要 | 承認 |
|:---:|:---|:---|:---|:---:|
| 1 | 20260829-101500-othello-init | 2026-08-29 | 初版（オセロ基本実装） | ✅ |
| 2 | 20260829-143000-othello-ai-level | 2026-08-29 | AI難易度設定を追加、状態管理をステートマシン化 | ✅ |
```
