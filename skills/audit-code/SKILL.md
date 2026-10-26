---
name: audit-code
description: /startcycle の Step 3（@qa）で使う。verify.sh で拾えないデグレード・spec逸脱・セキュリティを Claude Code に監査させ修正する。
---
# Skill: Audit Code（@qa）

`verify.sh` の機械検査では拾えない欠陥（**デグレード**、spec/AC からの逸脱、設計・インターフェース不整合、セキュリティ、未処理エラー）を判定・修正する。

## Rules
- **前提**: @engineer の `verify.sh` が通っていること。構文・型・lint・既存テストの再点検は LLM にやらせない（`verify.sh` の責務）。
- **対象**: `git diff <起点コミット>..HEAD` の変更範囲と、その影響先。基準は `docs/spec.md` の AC。
- **デグレード防止を最優先**: 既存要件・公開インターフェースが保たれているか。
- **委譲（既定）**: 監査は Claude Code へ。`cli.sh claude-sonnet <brief> qa-<topic>`（複雑な不具合調査・深層原因は `claude-opus`）。`local-only` を除き自前監査で済ませない。
- **brief**: 起点コミット、変更ファイルの一覧、見るべき AC、**出力形式**（下表の JSON 配列を `docs/runs/$RUN_ID/raw/` 配下に保存する、または最終メッセージを表形式にする）を指定。diff 全文は貼らず、`git diff` を自分で見るよう指示する。
- **書き換えの確認**: `docs/runs/$RUN_ID/scope-warnings.md` と `verify/baseline.txt` を brief に含め、「文書に合わせて既存コードを書き換えていないか」「着手前から通っていたテストを壊していないか」を必ず見させる。`[DOC-DRIFT]` は検出表に「文書の誤り」として載せる。
- **直接修正**: 必要な修正は `src/` に直接反映し、**修正後に `verify.sh` を再実行して通過を確認**する。
- **利用制限**: 終了コード 75 は停止し `manage-quota` に従う。

## 検出表（未対応分も全件。そのまま report の QA セクションになる）
| 検出項目 | 深刻度 (High/Med/Low) | 対応 (修正済み/未対応) | 備考 |
|:---|:---|:---|:---|

## 記録
`log.sh qa … findings="<検出表 or raw へのパス>"` → `state.sh` → `git add -A && git commit -m "fix(qa): <概要> (<RUN_ID>)"`。
