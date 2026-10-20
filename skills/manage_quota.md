# Skill: Manage Quota（消費量記録とルーティング制御）

残量の自動照会は不可（Gemini は UI のみ、Claude Code / Codex に usage サブコマンドなし）。「実測の積み上げ」＋「ユーザー宣言の上限」＋「モード切替」で運用する。

## 実測
`scripts/cli.sh` が呼出ごとに `docs/runs/<RUN_ID>/usage.tsv` へ追記する（Claude: `total_cost_usd` と tokens、Codex: 回数）。Gemini 自前処理件数とブラウザ操作ステップ数は Antigravity が数え、Step 5 の `scripts/report.sh <mode> <自前件数> <ブラウザ操作数>` に渡す。これが `docs/runs/usage.md` の台帳に 1 行追記される。

## `.agents/quota.local.yml`（任意）
無ければ `mode: balanced`。書式は `quota.example.yml`。

## Step 0（preflight）
`mode` を Run 全体に適用。`docs/runs/usage.md` の直近ウィンドウ分を合計し、`limits` の 80% 超があれば提示してモード変更を提案する（勝手に停止しない）。

## 利用制限到達時（`cli.sh` 終了コード 75）— 唯一の手順定義
1. **直ちに停止**。自前フォールバックも、エラー無視も、スキップもしない。
2. チャットで対象 CLI とエラー要約を報告し、次を提示して**ユーザーの選択を待つ**:
   - **A. 代替 CLI／モデル**: Codex 制限時は Claude Code、Claude Code 制限時は Codex（または別モデル）で再実行
   - **B. Antigravity 自前処理**: 当該タスク（または Run 全体）を直接処理して続行
   - **C. 解除待ち**: 一時停止し、「再開」指示で同一 CLI を再試行
3. 記録: `log.sh <persona> Awaiting …`（選択待ち）、確定後は選択内容と理由。`report.md` にも経緯を明記。

## 委譲率
CLI 呼出数 ÷（CLI 呼出数 + Gemini 自前処理数）。`balanced` で継続 50% 未満なら report に警告（`report.sh` が出力）。ただし小編集の自前処理は正当なので、数値は理由付きで読む。
