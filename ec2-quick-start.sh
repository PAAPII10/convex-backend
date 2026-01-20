#!/bin/bash
# Quick setup script for EC2 instance
# Run this once on a fresh EC2 Ubuntu instance

set -e

echo "🔧 Setting up EC2 instance for Convex Backend..."

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Install Node.js
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "✅ Node.js installed"
else
    echo "✅ Node.js already installed"
fi

# Install nginx and certbot
if ! command -v nginx &> /dev/null; then
    echo "🌐 Installing nginx..."
    sudo apt install -y nginx certbot python3-certbot-nginx
    echo "✅ nginx installed"
else
    echo "✅ nginx already installed"
fi

# Install utilities
echo "🛠️  Installing utilities..."
sudo apt install -y curl wget git nano ufw

# Configure firewall
echo "🔥 Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

echo ""
echo "✅ EC2 setup complete!"
echo ""
echo "⚠️  IMPORTANT: Log out and log back in for Docker group changes to take effect"
echo ""
echo "Next steps:"
echo "1. Log out: exit"
echo "2. SSH back in"
echo "3. Upload convex-backend files to ~/convex-backend"
echo "4. Configure .env file"
echo "5. Run: ./deploy-ec2.sh"
