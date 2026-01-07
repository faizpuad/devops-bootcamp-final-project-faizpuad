#!/bin/bash
set -e

echo "=== Firewall Configuration Script ==="

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    sudo apt-get update -qq
    sudo apt-get install -y ufw
fi

# Check if UFW is active
UFW_STATUS=$(sudo ufw status | grep -i "Status:" | awk '{print $2}')

if [ "$UFW_STATUS" = "inactive" ]; then
    echo "Enabling UFW..."
    
    # Allow SSH first (important!)
    sudo ufw allow 22/tcp comment 'Allow SSH'
    
    # Allow HTTP and HTTPS
    sudo ufw allow 80/tcp comment 'Allow HTTP'
    sudo ufw allow 443/tcp comment 'Allow HTTPS'
    
    # Enable UFW (with --force to avoid interactive prompt)
    sudo ufw --force enable
    
    echo "✅ UFW enabled with rules for ports 22, 80, and 443"
else
    echo "UFW is already active"
    
    # Ensure ports 80 and 443 are allowed
    sudo ufw allow 80/tcp comment 'Allow HTTP' 2>/dev/null || echo "Port 80 rule already exists"
    sudo ufw allow 443/tcp comment 'Allow HTTPS' 2>/dev/null || echo "Port 443 rule already exists"
    
    echo "✅ Verified ports 80 and 443 are allowed"
fi

# Show current firewall status
echo ""
echo "Current UFW status:"
sudo ufw status numbered