#!/bin/bash
set -e

echo "=== Setting up S3 bucket for Ansible-SSM transfers ==="

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"
BUCKET_NAME="devops-ansible-transfer-${AWS_ACCOUNT_ID}"

echo "Bucket name: ${BUCKET_NAME}"

# Check if bucket exists
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "✓ Bucket already exists: ${BUCKET_NAME}"
else
    echo "Creating S3 bucket for Ansible-SSM..."
    aws s3 mb "s3://${BUCKET_NAME}" --region "${AWS_REGION}"
    echo "✓ Bucket created: ${BUCKET_NAME}"
fi

# Set lifecycle policy to clean up temp files
cat > /tmp/lifecycle-policy.json << 'EOF'
{
  "Rules": [
    {
      "Id": "DeleteTempFilesAfter1Day",
      "Status": "Enabled",
      "Prefix": "",
      "Expiration": {
        "Days": 1
      }
    }
  ]
}
EOF

aws s3api put-bucket-lifecycle-configuration \
  --bucket "${BUCKET_NAME}" \
  --lifecycle-configuration file:///tmp/lifecycle-policy.json

echo "✓ Lifecycle policy configured"
echo ""
echo "Bucket ready: s3://${BUCKET_NAME}"