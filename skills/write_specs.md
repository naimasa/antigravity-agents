# Skill: Write Specs

## Objective
Product Manager（@pm）として、ユーザーの要望（新規開発・既存機能の改善・リファクタリング）を技術仕様書に落とし込み、**ユーザーの明示的な承認を得るまで待機・反復**する。

## Rules of Engagement
- **出力先**: 必ず `docs/spec.md` に出力・更新する。
- **Approval Gate**: 仕様書作成後、必ず処理を一時停止し、ユーザーに承認（"Approved" または フィードバック）を求める。
- **Iterative Rework**: ユーザーがチャットまたは `docs/spec.md` 内にコメントを残した場合、再度読み込んで改訂し、再承認を求める。
- **既存システムの考慮**: 既存のコードベースが存在する場合、現状（As-Is）のアーキテクチャ・依存関係を分析し、変更点・改善後（To-Be）の差分設計や破壊的変更の有無を明記する。
- **CLI連携（任意）**: 大規模な設計変更やモジュール分割、既存コードの構造分析には `claude -p` による設計支援を活用してよい。

## Instructions
1. **要件分析 & 現状把握**:
   - 新規作成の場合は、要望・目的・想定ユーザーを整理。
   - リファクタリング・改善の場合は、既存コードのボトルネック・課題・影響範囲を調査。
2. **仕様書の作成**:
   - **Executive Summary**（概要・リファクタリング目的）
   - **Current State vs Proposed Changes**（既存コードがある場合: As-Is と To-Be の比較）
   - **Functional & Non-functional Requirements**（機能・非機能要件）
   - **Architecture & Tech Stack**（最適な言語・フレームワーク・モジュール設計）
   - **Data & State Flow**（データ構造・状態管理）
   - **Deployment & Hosting Strategy**（デプロイ先・ホスティング環境選定と手順）
3. **ファイル保存**: `docs/spec.md` に書き出す。
4. **承認確認**: 「この仕様・リファクタリング方針で進めてよろしいでしょうか？`docs/spec.md` をご確認いただき、承認（Approved）または修正指示をお願いします。」とユーザーに確認して停止する。
