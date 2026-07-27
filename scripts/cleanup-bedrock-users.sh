#!/usr/bin/env bash
# [Staff only] Delete the time-boxed training IAM users. Run after the training, always.
# Usage: AWS_PROFILE=<admin-profile> scripts/cleanup-bedrock-users.sh <pairs>
set -euo pipefail
PAIRS="${1:?usage: cleanup-bedrock-users.sh <pairs>}"

for i in $(seq 1 "$PAIRS"); do
  U="genai-training-pair$(printf '%02d' "$i")"
  echo "== $U"
  for K in $(aws iam list-access-keys --user-name "$U" --query 'AccessKeyMetadata[].AccessKeyId' --output text); do
    aws iam delete-access-key --user-name "$U" --access-key-id "$K"
  done
  aws iam delete-user-policy --user-name "$U" --policy-name bedrock-invoke-only
  aws iam delete-user --user-name "$U"
done
echo "deleted $PAIRS users"
