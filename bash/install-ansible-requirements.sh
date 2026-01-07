#!/bin/bash
set -e

echo "=== Installing Ansible Requirements ==="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    
    # Download AWS CLI installer
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    
    # Install unzip if not present
    if ! command -v unzip &> /dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y unzip
    fi
    
    # Extract and install AWS CLI
    unzip -q awscliv2.zip
    sudo ./aws/install
    
    # Clean up
    rm -rf awscliv2.zip aws/
    
    echo "✅ AWS CLI installed successfully"
else
    AWS_VERSION=$(aws --version)
    echo "✓ AWS CLI is already installed: $AWS_VERSION"
fi

# Install boto3 and botocore (required for aws_ssm inventory plugin)
echo "Installing boto3 and botocore..."
pip3 install --user boto3 botocore

# Verify installation
echo ""
echo "✅ Ansible requirements installed successfully"
echo ""
echo "Installed versions:"
aws --version
python3 -c "import boto3; print(f'boto3: {boto3.__version__}')"
python3 -c "import botocore; print(f'botocore: {botocore.__version__}')"