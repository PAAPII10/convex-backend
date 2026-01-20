#!/bin/bash
# Quick deployment script for EC2
# Run this on your EC2 instance after initial setup

set -e

echo "🚀 Deploying Convex Backend to EC2..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please copy .env.example to .env and configure it first."
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose first."
    exit 1
fi

# Pull latest images
echo "📥 Pulling latest Docker images..."
docker compose pull

# Start services
echo "🔄 Starting services..."
docker compose -f docker-compose.prod.yml up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 10

# Check health
echo "🏥 Checking backend health..."
if curl -f http://localhost:3210/health > /dev/null 2>&1; then
    echo "✅ Backend is healthy!"
else
    echo "⚠️  Backend health check failed. Check logs with: npm run logs"
fi

# Show status
echo ""
echo "📊 Service Status:"
docker ps --filter "name=convex" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Configure nginx (see nginx.conf.example)"
echo "2. Set up SSL with certbot"
echo "3. Update .env with HTTPS URLs"
echo "4. Restart services: npm run restart"
echo ""
echo "View logs: npm run logs"
echo "Check health: curl http://localhost:3210/health"
