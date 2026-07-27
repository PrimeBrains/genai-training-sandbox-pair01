#!/usr/bin/env bash
# 研修用 Issue をリポジトリに投入する（運営用）
# 使い方: scripts/seed-issues.sh <owner/repo>
set -euo pipefail
REPO="${1:?usage: seed-issues.sh <owner/repo>}"

for L in "調査:0e8a16" "バグ:d73a4a" "タスク:0075ca" "priority-high:b60205" "priority-medium:fbca04" "priority-low:c5def5"; do
  gh label create "${L%%:*}" --repo "$REPO" --color "${L##*:}" --force
done

gh issue create --repo "$REPO" --label "タスク,priority-low" \
  --title "README にプロジェクト構成図（Mermaid）を追加する" \
  --body "## 概要
README.md にクラス構成の Mermaid 図を追加する。

## 優先度
Low

## 受け入れ条件
- [ ] README に Mermaid のクラス図がある"

gh issue create --repo "$REPO" --label "調査,priority-high" \
  --title "Claude Code と GitHub Copilot の違いを調べてまとめよ" \
  --body "## 概要
Claude Code と GitHub Copilot の違いを Web で調査し、レポートにまとめる。

## 優先度
High（期限: 本日）

## 受け入れ条件
- [ ] docs/research/ にレポート（日本語 Markdown）がある
- [ ] 「どういう場面でどちらを使うか」の使い分け表がある
- [ ] PR が作成されている"

gh issue create --repo "$REPO" --label "バグ,priority-medium" \
  --title "経費精算のテストが落ちている。原因を調べて修正せよ" \
  --body "## 概要
\`./gradlew test\` を実行するとテストが失敗する。原因を特定し、プロダクトコードを修正する。

## 優先度
Medium（本日中）

## 注意
- 仕様の正は ExpenseService の Javadoc とテストコード。テスト側を書き換えて通すのは禁止

## 受け入れ条件
- [ ] \`./gradlew test\` が全件成功する
- [ ] PR が作成されている"

gh issue create --repo "$REPO" --label "タスク,priority-low" \
  --title "経費の費目に「宿泊費(LODGING)」を追加する（自由課題）" \
  --body "## 概要
費目 LODGING を追加する。1明細あたり上限 10,000 円、超過分は支給しない。

## 優先度
Low（自由時間用の課題）

## 受け入れ条件
- [ ] LODGING の精算ロジックとテストがある
- [ ] 既存テストが全件成功する"

echo "done: $(gh issue list --repo "$REPO" --json number --jq 'length') issues"
