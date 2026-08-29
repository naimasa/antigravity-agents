# Skill: Report Run（サイクル最終レポート）

## Objective
1 サイクル（1 Run）で各ペルソナが行った作業を **1 枚のレポートに集約**し、
さらに全 Run を横断する一覧ダッシュボード（`docs/runs/index.md`）を更新する。
「各エージェントの仕事の結果がまとまって見えない」問題を解消する最終ゲート。

## Rules of Engagement
- **実行タイミング**: `/startcycle` の Step 5（最終ステップ）。DevOps の起動報告が終わった直後。
- **入力**: `docs/runs/<RUN_ID>/journal.md`、`docs/specs/<RUN_ID>.md`、`git diff --stat <起点コミット>..HEAD`
- **捏造禁止**: journal と git の実測値に存在しない成果・URL・テスト結果を書かない。未確認の項目は「未検証」と明記する。
- **チャット出力**: レポート生成後、要約（Status 表 + 変更ファイル数 + URL + 残課題）をチャットにも提示し、`docs/runs/<RUN_ID>/report.md` へのリンクを添える。

## Instructions
1. **集約**: `journal.md` の全エントリと `git diff --stat <起点コミット>..HEAD` を読み込む。
2. **レポート生成**: `docs/runs/<RUN_ID>/report.md` を以下の構成で作成する。
3. **一覧更新**: `docs/runs/index.md` の表に 1 行追記する（新しい Run が上に来るよう先頭へ挿入）。
4. **コミット**: `git add docs/runs && git commit -m "docs(run): add report for <RUN_ID>"`
5. **チャット報告**: 要約を提示して終了する。

## report.md テンプレート
```markdown
# Run Report — <RUN_ID>

| 項目 | 内容 |
|:---|:---|
| 実行日時 | <開始> 〜 <終了> |
| ユーザー要望 | <原文> |
| 起点コミット | `<short-hash>` |
| 最終コミット | `<short-hash>` |
| 総合ステータス | ✅ 完了 / ⚠️ 一部未完 / ❌ 中断 |

## 1. 各エージェントの結果サマリ
| ペルソナ | Status | 主な成果 | 変更ファイル | 使用CLI |
|:---|:---|:---|:---:|:---|
| @pm | ✅ | 仕様策定・承認取得 | 1 | Claude Code |
| @engineer | ✅ | 〜を実装 | 6 | Codex |
| @qa | ⚠️ | 〜を修正、1件未対応 | 2 | Claude Code |
| @devops | ✅ | ローカル起動確認 | 0 | — |

## 2. 仕様の変更点（As-Is → To-Be）
- スナップショット: [docs/specs/<RUN_ID>.md](../../specs/<RUN_ID>.md)
- 主な決定事項:
  - 〜

## 3. 変更ファイル一覧
（`git diff --stat` の出力を転記）

## 4. QA 結果
| 検出項目 | 深刻度 | 対応 |
|:---|:---|:---|
| 〜 | High | 修正済み |
| 〜 | Low | 未対応（理由: 〜） |

## 5. 稼働確認
- 起動コマンド: `<command>`
- URL: <http://localhost:PORT> / 本番URL
- 動作確認結果: 〜（未検証の場合は「未検証」と明記）

## 6. 残課題・次アクション
- [ ] 〜

## 7. 参照リンク
- 作業ログ: [journal.md](journal.md)
- CLI 生出力: [raw/](raw/)
- 仕様スナップショット: [docs/specs/<RUN_ID>.md](../../specs/<RUN_ID>.md)
```

## index.md テンプレート（初回のみ作成、以降は行を追記）
```markdown
# Run Index — 開発サイクル一覧

| Run ID | 日付 | 要望（要約） | Status | 変更 | Report | Spec |
|:---|:---|:---|:---:|:---:|:---|:---|
| <RUN_ID> | 2026-08-29 | オセロにAI難易度設定を追加 | ✅ | 8 files | [report](<RUN_ID>/report.md) | [spec](../specs/<RUN_ID>.md) |
```
