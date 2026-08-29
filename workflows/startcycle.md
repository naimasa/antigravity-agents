---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

When the user triggers `/startcycle <idea>`, orchestrate the end-to-end development process strictly using `.agents/agents.md` and `.agents/skills/`.

**全ステップ共通の必須ルール**: `.agents/skills/track_progress.md` に従い、各ステップ完了直後に `docs/runs/<RUN_ID>/journal.md` へ作業結果を追記すること。記録なしに次のステップへ進んではならない。

### Execution Pipeline Sequence:

0. **Step 0: Run 初期化**
   - 親プロジェクトが Git リポジトリであることを確認する（`git rev-parse --git-dir`）。リポジトリでなければ **パイプラインを開始せず**、`git init` をユーザーに促す（仕様書・成果物の履歴保全が前提のため）。
   - `track_progress.md` に従い `RUN_ID = YYYYMMDD-HHMMSS-<kebab-slug>` を採番する。
   - `docs/runs/<RUN_ID>/raw/` を作成し、`journal.md` にヘッダ（Run ID / 開始時刻 / ユーザー要望の原文 / 起点コミット `git rev-parse --short HEAD`）を書き出す。
   - 作業ツリーに未コミットの変更がある場合は `git add -A && git commit -m "chore: baseline before <RUN_ID>"` で起点を確定させる。

1. **Step 1: Product Manager (@pm) — 仕様策定 & 承認ゲート**
   - Execute the `write_specs.md` skill using the `<idea>`.
   - Formulate architecture, tech stack, and deployment strategy into `docs/spec.md`.
   - **`docs/spec.md` を上書きする前に、前版を必ずコミットして保全する**（`write_specs.md` の「上書き前の保全」に従う）。
   - **Halt and wait for explicit user approval.**
   - *If the user provides feedback or inline comments, act as @pm again to revise the specification and ask for approval again. Loop until the user approves.* 往復のたびに前版をコミットし、journal に `⏸ Awaiting Approval` を追記する。
   - 承認後: `docs/specs/<RUN_ID>.md` へスナップショットを保存し、`docs/spec.md` の Revision History に 1 行追記してコミットする。

2. **Step 2: Full-Stack Engineer (@engineer) — 実装**
   - Shift context to @engineer.
   - Execute the `generate_code.md` skill based on `docs/spec.md`.
   - For complex algorithms, data structures, or optimization, invoke **Codex CLI**（生出力は `docs/runs/<RUN_ID>/raw/` へ保存）.
   - Output all code to `src/`.
   - 完了後: journal に `@engineer` エントリを追記し、`feat: <概要> (<RUN_ID>)` としてコミットする。

3. **Step 3: QA Engineer (@qa) — コード監査 & バグ修正**
   - Shift context to @qa.
   - Execute the `audit_code.md` skill on `src/`.
   - Invoke **Claude Code CLI** for security audit and type consistency checks（生出力は `docs/runs/<RUN_ID>/raw/` へ保存）.
   - Commit any necessary fixes directly to `src/`.
   - 完了後: 検出項目表を含む `@qa` エントリを journal に追記し、`fix(qa): <概要> (<RUN_ID>)` としてコミットする。

4. **Step 4: DevOps Master (@devops) — 起動 & デプロイ**
   - Shift context to @devops.
   - Follow the Deployment & Hosting Strategy in `docs/spec.md`:
     - If local execution is specified: Execute `deploy_app.md`.
     - If cloud/production deployment is specified: Execute `deploy_production.md`.
   - Report the live localhost/production URL to the user.
   - 完了後: journal に `@devops` エントリ（起動コマンド・URL・確認結果）を追記する。

5. **Step 5: 統合レポート（サイクル総括）**
   - Execute the `report_run.md` skill.
   - `journal.md` と `git diff --stat <起点コミット>..HEAD` を集約して `docs/runs/<RUN_ID>/report.md` を生成する。
   - `docs/runs/index.md` に当該 Run の行を追記する。
   - `docs(run): add report for <RUN_ID>` としてコミットする。
   - **チャットに要約を提示して終了する**: 各ペルソナの Status 表 / 変更ファイル数 / アクセス URL / 残課題 / `report.md` へのリンク。
