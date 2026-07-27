#!/usr/bin/env bash
# [Staff only] Create time-boxed IAM users for the training and emit
# per-pair credential snippets under out/ (gitignored).
# Idempotent: existing users are kept; their access keys are rotated
# (old keys deleted, new key issued) so out/ always holds the live key.
# Usage:   AWS_PROFILE=<admin-profile> scripts/provision-bedrock-users.sh <pairs>
# Cleanup: scripts/cleanup-bedrock-users.sh <pairs>  (run after the training, always)
set -euo pipefail
PAIRS="${1:?usage: provision-bedrock-users.sh <pairs>}"
OUT="$(cd "$(dirname "$0")/.." && pwd)/out"
mkdir -p "$OUT"

POLICY='{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"],
    "Resource": "*"
  }]
}'

for i in $(seq 1 "$PAIRS"); do
  U="genai-training-pair$(printf '%02d' "$i")"
  echo "== $U"
  if aws iam get-user --user-name "$U" >/dev/null 2>&1; then
    echo "   exists: keeping user, rotating access key"
  else
    aws iam create-user --user-name "$U" --tags Key=purpose,Value=genai-training >/dev/null
  fi
  aws iam put-user-policy --user-name "$U" --policy-name bedrock-invoke-only --policy-document "$POLICY"

  # rotate: drop all existing keys, then issue exactly one fresh key
  for K in $(aws iam list-access-keys --user-name "$U" \
      --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    aws iam delete-access-key --user-name "$U" --access-key-id "$K"
  done
  read -r KEY SECRET < <(aws iam create-access-key --user-name "$U" \
    --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)

  {
    echo "# あなたの専用リポジトリ（事前セットアップ案内の §4 で clone するのはこの URL です）:"
    echo "# https://github.com/PrimeBrains/genai-training-sandbox-pair$(printf '%02d' "$i").git"
    echo "#"
    echo "# 以下の3行を ~/.aws/credentials に貼り付けてください（ファイルがなければ作成）:"
    echo "[genai-training]"
    echo "aws_access_key_id = $KEY"
    echo "aws_secret_access_key = $SECRET"
  } > "$OUT/$U-credentials.txt"
done
echo "Wrote credential snippets to out/. Distribute one file per pair."
echo "After the training, ALWAYS run: scripts/cleanup-bedrock-users.sh $PAIRS"
