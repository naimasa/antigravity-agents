---
name: generate-code
description: /startcycle の Step 2（@engineer）で使う。承認済み spec の AC を満たす実装を Codex に委譲し、verify.sh が通るまで最大3回の修正ループを回す。
---
# Skill: Generate Code（@engineer）

承認済み `docs/spec.md` の受入基準（AC）を満たす実装・差分改修を `src/` に行い、**`verify.sh` が通るまで**修正ループを回す。

## Rules
- **前提確認**: `docs/runs/$RUN_ID/APPROVED` が無ければ開始しない。`docs/ARCHITECTURE.md` と `docs/spec.md` の AC を読む。
- **新規**: spec 指定の言語・FW に従い完全なファイルを生成。省略・プレースホルダー禁止。
- **リファクタリング**: 既存コード・スタイルを尊重し対象箇所のみ差分改修。正常な機能やコメントを消さない。
- **委譲（既定）**: 複数ファイルにまたがる実装・アルゴリズム・最適化は Codex へ。単一ファイルの小編集は自前でよい。自前処理した CLI 指定タスクは理由を `findings=` に記録。
- **brief 方式**: `docs/runs/$RUN_ID/briefs/NN.md` に ①対象 AC ②触るファイル／触らないファイル ③完了条件（`verify.sh` 通過）④参照すべき既存コードのパス を書き、`.agents/scripts/cli.sh codex docs/runs/$RUN_ID/briefs/NN.md engineer-<topic>` で呼ぶ。コード断片を brief に貼らず、パスで指す。
- **brief の書式**: 範囲検査のため、brief に `## 触るファイル` 見出しを置き、直下に箇条書きでパス（ディレクトリ・glob 可）を列挙する。
- **着手前の基準線**: 実装前に `.agents/scripts/verify.sh --baseline` を実行し、既存テストの状態を `verify/baseline.txt` に記録する。以後の失敗が「既存の破壊」か「元から」かを区別できる。
- **範囲外の変更**: `cli.sh` は呼出後に `scope_check.sh` を自動実行し、brief 範囲外の変更や既存ファイルの大幅削除を警告する（`scope-warnings.md` にも追記）。警告が出たら diff を確認し、文書に合わせた書き換えなど意図外なら差し戻す。
- **文書との不一致**: CLI の最終報告にある `[DOC-DRIFT]` は journal の `findings=` にそのまま転記する。
- **テストの分離**: AC に対応するテストは、**実装を見せず spec の AC だけから**別の `cli.sh` 呼出（別 brief）で生成させる。実装者が自分のテストを書くと実装を追認するため。既存テストがある場合は追加分のみ。
- **利用制限**: `cli.sh` が終了コード 75 を返したら停止し `manage-quota` に従う。

## 修正ループ（最大 3 回）
1. `.agents/scripts/verify.sh` を実行（LLM 推論なし）。
2. 失敗なら、**標準出力に出た失敗ログ末尾だけ**を新しい brief に貼り、該当箇所の修正を Codex へ依頼。全文・全ファイルは渡さない。
3. 再度 `verify.sh`。通過で終了。3 回失敗したら停止し、`claude-opus` での原因分析に切り替えるかユーザーに確認する。
4. `verify.json` の steps が空（検証不能）なら「未検証」として @qa に申し送る。

## 記録
完了直後に `log.sh engineer …`（`cli=` に使用した raw、`findings=` に未実装・積み残し・verify 結果）→ `state.sh` → `git add -A && git commit -m "feat: <概要> (<RUN_ID>)"`。
