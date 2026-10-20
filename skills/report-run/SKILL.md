---
name: report-run
description: /startcycle の Step 5 で使う。report.sh の実測集計から report.md と index.md を作る。
---
# Skill: Report Run（最終レポート）

Step 5。集計は `scripts/report.sh` が実測から出す。LLM は文章部分のみ書く。

## Rules
- **入力**: `.agents/scripts/report.sh <mode> <Gemini自前件数> <ブラウザ操作数>` の出力、`journal.md`。
- **捏造禁止**: journal・git・`verify` の実測に無い成果・URL・テスト結果を書かない。未確認は「未検証」。
- **手順**: `report.sh` 実行（usage.md 追記は自動）→ `report.md` 作成 → `docs/runs/index.md` の表に先頭行として追記 → `git add docs/runs && git commit -m "docs(run): add report for <RUN_ID>"` → チャットに要約（Status / 変更ファイル数 / URL / 残課題 / report リンク）。

## `docs/runs/<RUN_ID>/report.md`
```markdown
# Run Report — <RUN_ID>
| 実行日時 | ユーザー要望 | 起点→最終コミット | 総合 |
|:---|:---|:---|:---|

## 1. 各ペルソナの結果（Status / 主な成果 / 変更ファイル数 / CLI）
## 2. 仕様の変更点（As-Is → To-Be）と AC の充足状況（AC ごとに verify 結果へ対応付け。手動確認・未検証は明記）
## 3. 変更ファイル（report.sh の diff --stat）
## 4. QA 結果（audit-code の検出表。未対応も含む）
## 5. CLI 委譲サマリ（report.sh の委譲率・USD・tokens。50% 未満や自前処理は理由を明記）
## 6. 稼働確認（起動コマンド / URL / verify 結果 / 対話ブラウザ操作ステップ数。未実施は「未検証」）
## 7. 残課題・次アクション
## 8. 参照: journal.md / raw/
```

## `docs/runs/index.md`（初回のみ作成）
| Run ID | 日付 | 要望（要約） | Status | 変更 | Report | Spec |
|:---|:---|:---|:--:|:--:|:---|:---|
