#!/bin/bash
set -e

echo "=== Installing AWS SSM Session Manager Plugin ==="

# Check if already installed
if command -v session-manager-plugin &> /dev/null; then
    echo "✓ Session Manager Plugin already installed"
    session-manager-plugin --version
    exit 0
fi

echo "Downloading Session Manager Plugin..."
cd /tmp
curl -s "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"

echo "Installing..."
sudo dpkg -i session-manager-plugin.deb

# Clean up
rm session-manager-plugin.deb

echo "✓ Session Manager Plugin installed successfully"
session-manager-plugin --version