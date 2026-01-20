# Quick Start Guide

This is a condensed guide for experienced users. See [README.md](README.md) for detailed instructions.

**Note for t2.micro users**: After initial setup, run `./scripts/setup-t2-micro.sh` to optimize for 1 vCPU/1GB RAM.

## 1. EC2 Setup (One-time)

```bash
# SSH into EC2
ssh ubuntu@YOUR_EC2_IP

# Clone repository
git clone <your-repo-url>
cd convex-backend

# Run setup
./scripts/setup-ec2.sh
newgrp docker  # Or logout/login
```

## 2. Configure Environment

```bash
cd /opt/convex
./scripts/generate-env.sh
# OR manually: cp env.production.example .env.production && nano .env.production
```

## 3. Setup Nginx & SSL

```bash
sudo ./scripts/setup-nginx.sh api.yourdomain.com
# Update domain in nginx.conf first if needed
```

## 4. GitHub Actions Setup

1. Add secrets in GitHub: `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`
2. Push to `main` branch → Auto-deploys

## 5. First Manual Deploy

```bash
cd /opt/convex
docker compose pull
docker compose up -d
docker compose exec backend ./generate_admin_key.sh
```

## Common Commands

```bash
# View logs
docker compose logs -f backend

# Restart services
docker compose restart

# Update deployment
docker compose pull && docker compose up -d

# Check status
docker compose ps

# Access dashboard
https://api.yourdomain.com/dashboard/
```

## Environment Variables Needed

- `CONVEX_CLOUD_ORIGIN`: Your domain URL
- `DATABASE_URL`: Supabase PostgreSQL connection
- `AWS_S3_ENDPOINT`: Supabase S3 endpoint
- `AWS_ACCESS_KEY_ID`: S3 access key
- `AWS_SECRET_ACCESS_KEY`: S3 secret key
- `AWS_S3_BUCKET`: Bucket name

## Troubleshooting

```bash
# Check what's wrong
docker compose logs
docker compose ps
sudo nginx -t
sudo systemctl status nginx

# Restart everything
docker compose down && docker compose up -d
sudo systemctl restart nginx
```
