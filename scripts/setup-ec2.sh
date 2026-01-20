#!/bin/bash
set -e

echo "=== Convex Backend EC2 Setup Script ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root. Use sudo when needed.${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}Step 2: Installing dependencies...${NC}"
sudo apt install -y docker.io docker-compose git nginx certbot python3-certbot-nginx curl

echo -e "${GREEN}Step 3: Configuring Docker...${NC}"
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
if ! groups | grep -q docker; then
    echo -e "${YELLOW}Adding user to docker group...${NC}"
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}Please log out and log back in for docker group changes to take effect.${NC}"
    echo -e "${YELLOW}Or run: newgrp docker${NC}"
fi

echo -e "${GREEN}Step 4: Creating directory structure...${NC}"
sudo mkdir -p /opt/convex/data
sudo mkdir -p /opt/convex/nginx
sudo chown -R $USER:$USER /opt/convex

echo -e "${GREEN}Step 5: Setting up Nginx...${NC}"
sudo systemctl enable nginx
sudo systemctl start nginx

echo -e "${GREEN}Step 6: Verifying installations...${NC}"
docker --version
docker compose version
nginx -v
certbot --version

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Copy docker-compose.yml to /opt/convex/"
echo "2. Create .env.production file in /opt/convex/"
echo "3. Configure Nginx (copy nginx.conf to /etc/nginx/sites-available/)"
echo "4. Set up SSL certificates with certbot"
echo "5. Deploy using GitHub Actions or manually run: docker compose up -d"
