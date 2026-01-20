#!/bin/bash
set -e

echo "=== t2.micro Optimization Setup ==="
echo ""
echo "This script configures your t2.micro instance for Convex backend."
echo "t2.micro has only 1 vCPU and 1GB RAM, so optimization is critical."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root. Use sudo when needed.${NC}"
    exit 1
fi

# Check instance type (basic check)
echo -e "${YELLOW}Checking system resources...${NC}"
CPU_COUNT=$(nproc)
RAM_GB=$(free -g | awk '/^Mem:/{print $2}')

echo "  CPU cores: $CPU_COUNT"
echo "  RAM: ${RAM_GB}GB"
echo ""

if [ "$CPU_COUNT" -gt 1 ]; then
    echo -e "${YELLOW}Note: This appears to be a multi-core instance (t3.micro or higher).${NC}"
    echo -e "${YELLOW}This script is optimized for t2.micro (1 vCPU).${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Setup swap space
echo -e "${GREEN}Step 1: Setting up swap space (REQUIRED for t2.micro)...${NC}"
if [ -f /swapfile ]; then
    echo "Swap file already exists. Skipping..."
else
    echo "Creating 2GB swap file..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo -e "${GREEN}✓ Swap space created and enabled${NC}"
fi

# Verify swap
echo ""
echo "Current memory status:"
free -h

# Update .env.production if it exists
ENV_FILE="/opt/convex/.env.production"
if [ -f "$ENV_FILE" ]; then
    echo ""
    echo -e "${GREEN}Step 2: Updating ACTION_WORKER_COUNT in .env.production...${NC}"
    
    # Check current value
    CURRENT_WORKERS=$(grep "^ACTION_WORKER_COUNT=" "$ENV_FILE" | cut -d'=' -f2 || echo "8")
    echo "Current ACTION_WORKER_COUNT: $CURRENT_WORKERS"
    
    if [ "$CURRENT_WORKERS" -gt 2 ]; then
        read -p "Reduce ACTION_WORKER_COUNT to 1? (recommended for t2.micro) (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            sed -i 's/^ACTION_WORKER_COUNT=.*/ACTION_WORKER_COUNT=1/' "$ENV_FILE"
            echo -e "${GREEN}✓ Updated ACTION_WORKER_COUNT to 1${NC}"
        fi
    else
        echo "ACTION_WORKER_COUNT is already optimized (≤2)"
    fi
else
    echo ""
    echo -e "${YELLOW}Step 2: .env.production not found at $ENV_FILE${NC}"
    echo "Please create it first, then set ACTION_WORKER_COUNT=1"
fi

# Docker memory limits (optional but recommended)
echo ""
echo -e "${GREEN}Step 3: Docker configuration recommendations...${NC}"
echo ""
echo "For t2.micro, consider adding memory limits to docker-compose.yml:"
echo ""
cat << 'EOF'
services:
  backend:
    # ... other config ...
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
EOF
echo ""
read -p "Add memory limits to docker-compose.yml? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DOCKER_COMPOSE="/opt/convex/docker-compose.yml"
    if [ -f "$DOCKER_COMPOSE" ]; then
        # This is a simple approach - user should verify
        echo "Please manually add memory limits to docker-compose.yml"
        echo "See the example above for the format."
    else
        echo "docker-compose.yml not found at $DOCKER_COMPOSE"
    fi
fi

echo ""
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo "Summary:"
echo "  ✓ Swap space: $(free -h | awk '/^Swap:/{print $2}')"
echo "  ✓ ACTION_WORKER_COUNT: $(grep "^ACTION_WORKER_COUNT=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2 || echo 'not set')"
echo ""
echo -e "${YELLOW}Important reminders for t2.micro:${NC}"
echo "  1. Monitor memory usage: free -h"
echo "  2. Check Docker stats: docker stats"
echo "  3. Keep ACTION_WORKER_COUNT=1 for best stability"
echo "  4. Consider upgrading to t3.small for production use"
echo ""
