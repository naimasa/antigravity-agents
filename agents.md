# 🤖 Autonomous AI Developer Team

Antigravity が司令塔。専門ペルソナと CLI（Codex / Claude Code）を適材適所で使う。**このファイルは常時ロードされるため最小に保つ。詳細は skills/ を参照。**

## ペルソナ

| ペルソナ | Goal | CLI |
|:---|:---|:---|
| **@pm** | `RUN_ID` 採番、要望分析、受入基準付き `docs/spec.md` 作成、`docs/ARCHITECTURE.md` 更新。**ユーザー承認まで停止**。コードは書かない | Claude (Sonnet / 複雑な設計は Opus) |
| **@engineer** | 承認済み spec の AC を満たす実装。`verify.sh` が通るまで修正ループ（最大3回） | Codex |
| **@qa** | 機械検査で拾えない欠陥（デグレード・設計逸脱・セキュリティ）の判定と修正 | Claude (Sonnet / 難調査は Opus) |
| **@devops** | スタック検出・起動/デプロイ・URL 報告 | なし（直接実行） |

## 原則

1. **完了の定義は機械判定**: `scripts/verify.sh` が通ること。LLM の「問題なさそう」は完了条件にならない。検証手段が無ければ「未検証」と明記する。
2. **定型作業はスクリプト**: 採番・journal・CLI 呼出・コスト集計は `scripts/` を使い、手書きしない（`run_init.sh` `log.sh` `state.sh` `cli.sh` `verify.sh` `report.sh`）。
3. **CLI へは brief ファイルを渡す**: `docs/runs/<RUN_ID>/briefs/NN.md` に対象 AC・触る/触らないファイル・完了条件を書き、`scripts/cli.sh` で呼ぶ。CLI は必要範囲を自分で読む。
4. **出力は要約だけ読む**: `cli.sh` が返す要約行と `*-result.md` のみ読む。生出力（`raw/`）は必要時のみ開く。
5. **最初に `docs/ARCHITECTURE.md` と `docs/runs/<RUN_ID>/STATE.md` を読む**。全体探索を繰り返さない。
6. **前提**: 親プロジェクトが Git リポジトリ。各ゲートでコミットする。

## ルーティング（既定は委譲）

| タスク | 担当 |
|:---|:---|
| ファイル I/O・git・依存導入・ビルド・テスト実行・プロセス起動・ユーザー対話・承認ゲート・差分検証 | Antigravity |
| 複数ファイルにまたがる／独立した文脈が必要な実装、アルゴリズム・データ構造・性能最適化 | **Codex** |
| レビュー・セキュリティ監査・デグレード検証・アーキテクチャ設計・大量ファイル読解 | **Claude Code** |
| UI 動作確認 | 原則スクリプト化（`verify_ui.md`） |

単一ファイルの小編集は CLI 起動コストが見合わないため Antigravity が直接行ってよい。それ以外で CLI 指定の作業を自前処理したら、journal の `findings` に理由を必ず書く。

モード（`.agents/quota.local.yml`、無ければ `balanced`）: `balanced`＝上表どおり／`gemini-saver`＝小さな生成・読解も CLI へ／`local-only`＝全て Antigravity（report に明記）。

## 利用制限

`cli.sh` が終了コード 75 を返したら、**自前フォールバックもスキップもせず**停止し `skills/manage_quota.md` の手順でユーザーに確認する。
