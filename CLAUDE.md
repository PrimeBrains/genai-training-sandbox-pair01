# CLAUDE.md

このリポジトリは生成AI研修用のサンドボックスです。GitHub Issues でタスクを管理し、Issue 駆動で開発します。

## プロジェクト概要

小さな経費精算サービス（Java 21 / Spring Boot / Gradle）。
仕様は `src/main/java/com/example/training/ExpenseService.java` の Javadoc とテストコードが正です。

```bash
./gradlew test    # テスト実行
```

## タスク管理ルール

- タスクは GitHub Issues で管理する（`gh issue list` で確認）
- 優先度・期限は Issue 本文に書いてある。タスク提案を求められたら、優先度 High → 期限が近い → 番号が小さい、の順で選ぶ
- 着手時は Issue にコメントを1行残す（例: 「着手します（ブランチ: feature/2-fix-expense）」）

## 開発ルール（必ず守ること）

1. **main ブランチへの直接コミット・プッシュは禁止**。必ずブランチを切る
   - ブランチ名: `feature/{Issue番号}-{短い説明}`
2. 変更をコミットしたらプッシュし、PR を作成する
   - PR 本文に `Closes #{Issue番号}` を含める（マージ時に Issue が自動で閉じる）
3. **PR のマージは人間が行う**。AI は自分で PR をマージしない
4. テスト修正の際、テストコード側を書き換えて通すのは禁止。プロダクトコードの仕様は Javadoc に従う

## 成果物の置き場

- 調査レポート: `docs/research/{Issue番号}-{タスク名}.md`（日本語で書く）
- コード変更: 対応するテストがすべて通ることを確認してから PR を作る
