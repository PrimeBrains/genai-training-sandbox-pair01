# Claude Code・GitHub Copilot・Gemini Code Assist の違い調査レポート

**調査日**: 2026-07-28  
**担当**: Issue #2

---

## 概要

本レポートでは、AI コーディング支援ツールとして広く利用されている **Claude Code**（Anthropic）、**GitHub Copilot**（GitHub / Microsoft）、**Gemini Code Assist**（Google）の特徴・機能・価格の違いを調査し、各ツールが適している場面を比較・整理する。

---

## 各ツールの概要

### Claude Code

Claude Code は Anthropic が提供する CLI ベースのエージェント型コーディングアシスタントである。ターミナルから直接起動し、自然言語の指示に従ってコードの読み取り・編集・テスト実行・Git 操作などを **自律的に** 遂行する。開発者はコードを逐一確認しながら、タスク単位で作業を委任できる。

- **形態**: CLI ツール（エージェント型）
- **提供元**: Anthropic
- **主な利用モデル**: Claude Sonnet / Opus 系
- **IDE サポート**: VS Code / JetBrains 拡張機能あり、Web UI（claude.ai/code）あり

### GitHub Copilot

GitHub Copilot は GitHub（Microsoft）が提供するインラインコード補完ツールである。IDE のエディタに統合され、コードを書く際にリアルタイムでサジェストを提示する。チャット機能（Copilot Chat）も備えており、コードの説明・リファクタリング提案・テスト生成なども行える。

- **形態**: IDE 統合型（インライン補完 + チャット）
- **提供元**: GitHub / Microsoft
- **主な利用モデル**: GPT-4o（一部 Claude や Gemini も選択可）
- **IDE サポート**: VS Code, JetBrains, Neovim, GitHub.com 上でも利用可

### Gemini Code Assist

Gemini Code Assist は Google が提供する IDE 統合型のコーディングアシスタントである。Gemini モデルをベースとし、インライン補完・チャット・コードレビューなどの機能を持つ。Google Cloud との親和性が高く、BigQuery・Cloud Functions などの Google サービスを使う開発者に特に向いている。

- **形態**: IDE 統合型（インライン補完 + チャット）
- **提供元**: Google
- **主な利用モデル**: Gemini 2.0 / 2.5 系
- **IDE サポート**: VS Code, JetBrains, Cloud Shell Editor

---

## 機能比較

| 機能・観点 | Claude Code | GitHub Copilot | Gemini Code Assist |
|---|---|---|---|
| **主な操作形態** | CLI（エージェント型） | IDE 統合（インライン補完 + チャット） | IDE 統合（インライン補完 + チャット） |
| **コード補完（リアルタイム）** | なし（逐次指示型） | あり | あり |
| **複数ファイルの横断編集** | 得意（プロジェクト全体を自律的に編集） | 可能だが手動で範囲を指定する場面が多い | 可能だが手動で範囲を指定する場面が多い |
| **ファイル操作・Git 操作** | 自律実行（コミット・PR 作成なども可） | 限定的（Copilot Workspace で一部対応） | 限定的 |
| **テスト実行・CI との連携** | CLI から直接実行可能 | IDE 内で提案のみ（実行は別途手動） | IDE 内で提案のみ（実行は別途手動） |
| **自然言語によるタスク委任** | 強い（「このバグを直して」で自律修正） | チャットで対話的に指示できるが逐次確認が必要 | チャットで対話的に指示できるが逐次確認が必要 |
| **コンテキスト理解の範囲** | プロジェクト全体（リポジトリ規模） | 現在開いているファイル中心（拡張で広がる） | 現在開いているファイル中心（拡張で広がる） |
| **カスタムルール・メモリ** | CLAUDE.md でプロジェクトルールを永続化できる | `.github/copilot-instructions.md` で指示可能 | `.idx/airules.md` などで指示可能 |
| **Google Cloud との親和性** | 低い | 中程度 | 高い（BigQuery, GCF, GKE 等のサジェストが得意） |
| **オフライン利用** | 不可 | 不可（一部キャッシュで補完のみ可） | 不可 |

---

## 価格比較

| プラン | Claude Code | GitHub Copilot | Gemini Code Assist |
|---|---|---|---|
| **個人向け無料枠** | なし（API 従量課金のみ） | あり（Free プラン: 月 2,000 補完・50 チャット） | あり（個人: 月 6,000 補完・1,000 チャット） |
| **個人向け有料プラン** | Claude.ai Pro: 約 $20/月（利用枠あり） | Copilot Individual: $10/月 または $100/年 | Standard: $19/月（月次）または $15/月（年次） |
| **ビジネス向けプラン** | API 従量課金（Sonnet: $3/1M tokens 入力） | Copilot Business: $19/月/ユーザー | Enterprise: $45/月/ユーザー（Standard は $25） |
| **エンタープライズ向け** | Anthropic との直接契約 | Copilot Enterprise: $39/月/ユーザー | Enterprise Plus など上位プランあり |
| **従量課金** | あり（API トークン単位） | なし | なし（API 別途利用の場合は除く） |
| **無料トライアル** | API クレジット付与あり（新規） | Free プランで恒久的に無料利用可 | 無料枠で恒久的に無料利用可 |

> ※ 価格は 2026-07-28 時点の公開情報に基づく。為替や改定により変動する場合がある。

### コスト感の目安

- **少量利用・試用**: Gemini Code Assist の無料枠（月 6,000 補完）が最も手厚い
- **個人開発者の日常利用**: GitHub Copilot Individual（$10/月）がコスパ良好
- **大きなタスクをスポットで委任**: Claude Code API 従量課金（必要な時だけ使えばコスト最小化）
- **チーム・企業利用**: GitHub Copilot Business（$19/月/ユーザー）が標準的な選択肢

---

## 場面別の使い分け比較表

| 場面・ユースケース | 推奨ツール | 理由 |
|---|---|---|
| コードを書きながらリアルタイムに補完を受けたい | **GitHub Copilot** / **Gemini Code Assist** | どちらもエディタ統合で即座に補完が表示される |
| 「このクラスのバグを直してテストも通して」のような大きなタスクを丸ごと委任したい | **Claude Code** | 複数ファイルを自律的に編集しテストを実行できる |
| リポジトリ全体のリファクタリングや移行作業 | **Claude Code** | プロジェクト全体を把握した上で一貫した変更が可能 |
| PR レビューや Issue 対応をエージェントに任せたい | **Claude Code** | Git 操作から PR 作成まで一連の作業を自律実行できる |
| 個々の関数やメソッドを素早く書きたい | **GitHub Copilot** / **Gemini Code Assist** | 文脈に合った補完候補を即座に提示する |
| テストコードの雛形を素早く生成したい | **GitHub Copilot** / **Gemini Code Assist** | 既存コードを見てインラインで生成できる |
| コードの意味・設計を対話形式で質問したい | **GitHub Copilot**（Copilot Chat）/ **Gemini Code Assist** | IDE 内で手軽にチャットできる |
| Google Cloud サービス（BigQuery, Cloud Run 等）を使って開発したい | **Gemini Code Assist** | Google サービスの文法・API に最適化されている |
| プロジェクト固有のルール（コーディング規約など）を AI に覚えさせたい | **Claude Code** | CLAUDE.md にルールを記載し継続的に参照させられる |
| コストを固定したい（月額上限を決めたい） | **GitHub Copilot** / **Gemini Code Assist** | サブスクリプション型で費用が予測しやすい |
| スポットで大きなタスクのみ AI を使いたい | **Claude Code** | 従量課金のため必要な時だけ使えばコストを抑えられる |
| 無料で始めたい | **Gemini Code Assist** | 個人向け無料枠が最も手厚い（月 6,000 補完） |

---

## まとめ

3ツールはそれぞれ異なる強みを持ち、競合というよりも **用途に応じた使い分け** が有効である。

- **GitHub Copilot** はエコシステムの広さと安定した個人向け価格が強み。GitHub を中心に開発するチームに自然に馴染む。
- **Gemini Code Assist** は無料枠の手厚さと Google Cloud との親和性が強み。GCP ユーザーや個人開発者のコスト抑制に向いている。
- **Claude Code** はエージェント型で大きなタスクの自律実行が強み。スポットで高度な作業を委任したい場面で最も力を発揮する。

日常的な開発では Copilot か Gemini Code Assist を使い、まとまった作業を自動化したい場面で Claude Code を起動するというフローが効率的である。

---

## 参考

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code/overview)
- [GitHub Copilot 公式ドキュメント](https://docs.github.com/en/copilot)
- [Gemini Code Assist 公式ドキュメント](https://cloud.google.com/gemini/docs/codeassist/overview)
- [GitHub Copilot 料金](https://github.com/features/copilot#pricing)
- [Gemini Code Assist 料金](https://cloud.google.com/gemini/docs/codeassist/overview#pricing)
