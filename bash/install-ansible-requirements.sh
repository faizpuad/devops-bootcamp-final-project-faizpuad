#!/bin/bash
set -e

echo "=== Installing Ansible Requirements ==="

# Install boto3 and botocore (required for aws_ssm inventory plugin)
pip3 install --user boto3 botocore

# Install SSM plugin for Ansible
pip3 install --user ansible

echo "✅ Ansible requirements installed"

# Verify
python3 -c "import boto3; print(f'boto3 version: {boto3.__version__}')"
ansible --version