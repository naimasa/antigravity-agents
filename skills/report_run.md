# Skill: Report Run（サイクル最終レポート）

1 Run で各ペルソナが行った作業を 1 枚に集約し、全 Run 横断の一覧も更新する。`/startcycle` Step 5 で実行。

## Rules
- **入力**: `docs/runs/$RUN_ID/journal.md`、`git diff --stat <起点コミット>..HEAD`
- **捏造禁止**: journal と git の実測に無い成果・URL・テスト結果を書かない。未確認は「未検証」と明記する。
- **手順**: `report.md` 生成 → `docs/runs/index.md` と `docs/runs/usage.md`（`manage_quota.md` 参照）の表に**先頭行として**追記 → `git add docs/runs && git commit -m "docs(run): add report for <RUN_ID>"` → チャットに要約（Status 表 / 変更ファイル数 / URL / 残課題 / report へのリンク）を提示。

## `docs/runs/<RUN_ID>/report.md`
```markdown
# Run Report — <RUN_ID>

| 実行日時 | ユーザー要望 | 起点→最終コミット | 総合 |
|:---|:---|:---|:---|
| <開始>〜<終了> | <原文> | `<hash>`→`<hash>` | ✅完了 / ⚠️一部未完 / ❌中断 |

## 1. 各エージェントの結果
| ペルソナ | Status | 主な成果 | 変更 | CLI |
|:---|:--:|:---|:--:|:---|
| @pm / @engineer / @qa / @devops | | | N files | |

## 2. 仕様の変更点（As-Is → To-Be）
主な決定事項。スナップショット: [docs/specs/<RUN_ID>.md](../../specs/<RUN_ID>.md)

## 3. 変更ファイル一覧
`git diff --stat` の出力を転記。

## 4. QA 結果
| 検出項目 | 深刻度 | 対応 |
|:---|:---|:---|
（audit_code.md の検出表をそのまま転記。未対応分も含める）

## 5. CLI 委譲サマリ
| | Gemini自前 | Codex | Claude | 委譲率 |
|:---|--:|--:|--:|--:|
| 呼出数 | N | N | N | NN% |
| 実測コスト | — | — | $N.NN | |

委譲率が 50% 未満、または CLI 指定タスクの自前処理があれば理由をここに明記する。

## 6. 稼働確認
起動コマンド / URL / 実行した spec と passed・failed 件数 / **対話的ブラウザ操作のステップ数**（未実施なら「未検証」）。

## 7. 残課題・次アクション
- [ ] …

## 8. 参照
[journal.md](journal.md) ／ [raw/](raw/)
```

## `docs/runs/index.md`（初回のみ作成）
```markdown
# Run Index — 開発サイクル一覧

| Run ID | 日付 | 要望（要約） | Status | 変更 | Report | Spec |
|:---|:---|:---|:--:|:--:|:---|:---|
| <RUN_ID> | 2026-08-29 | オセロにAI難易度設定を追加 | ✅ | 8 files | [report](<RUN_ID>/report.md) | [spec](../specs/<RUN_ID>.md) |
```
