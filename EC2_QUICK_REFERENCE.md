# EC2 Deployment Quick Reference

## Initial EC2 Setup (One-time)

```bash
# 1. SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Run setup script
curl -fsSL https://raw.githubusercontent.com/your-repo/convex-backend/main/ec2-quick-start.sh | bash
# OR upload and run locally:
./ec2-quick-start.sh

# 3. Log out and back in (for Docker group)
exit
ssh -i your-key.pem ubuntu@your-ec2-ip
```

## Deploy Convex Backend

```bash
# 1. Upload files to EC2
scp -r convex-backend ubuntu@your-ec2-ip:~/

# 2. SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# 3. Configure environment
cd ~/convex-backend
cp .env.example .env
nano .env  # Edit with your values

# 4. Generate secrets
npm run generate-key
openssl rand -hex 32

# 5. Deploy
./deploy-ec2.sh
# OR
npm run deploy:ec2
```

## Configure HTTPS (Optional but Recommended)

```bash
# 1. Point domain to EC2 IP
# Add A record: convex.yourdomain.com → your-ec2-ip

# 2. Configure nginx
sudo cp nginx.conf.example /etc/nginx/sites-available/convex
sudo nano /etc/nginx/sites-available/convex
# Replace convex.yourdomain.com with your domain

# 3. Enable site
sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 4. Get SSL certificate
sudo certbot --nginx -d convex.yourdomain.com

# 5. Update .env with HTTPS URLs
nano .env
# Set:
# CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
# CONVEX_SITE_ORIGIN=https://convex.yourdomain.com

# 6. Restart services
npm run restart:prod
```

## Security Group Rules

**Add these to your existing security group** (don't remove existing rules):

| Type | Port | Source | Notes |
|------|------|--------|-------|
| HTTP | 80 | 0.0.0.0/0 | For Let's Encrypt (if not already open) |
| HTTPS | 443 | 0.0.0.0/0 | Main access (if not already open) |
| Custom TCP | 3210 | Your IP | Optional, for direct Convex access |
| Custom TCP | 3211 | Your IP | Optional, for direct Convex access |
| Custom TCP | 6791 | Your IP | Dashboard (restrict!) |

**Note**: Your existing service on port 3001 and SSH on port 22 should remain configured.

## Environment Variables for EC2

```env
# Database (Supabase)
DATABASE_URL=postgresql://postgres:password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543

# Secrets (generate these)
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
INSTANCE_SECRET=your_instance_secret

# URLs (use HTTPS after SSL setup)
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

## Management Commands

```bash
cd ~/convex-backend

# View logs
npm run logs
npm run logs:backend

# Restart
npm run restart:prod

# Stop
docker compose -f docker-compose.prod.yml down

# Start
npm run up:prod

# Update
docker compose -f docker-compose.prod.yml pull
npm run restart:prod
```

## Auto-Start on Boot

```bash
# Create systemd service
sudo nano /etc/systemd/system/convex.service
```

Paste:
```ini
[Unit]
Description=Convex Self-Hosted Backend
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/convex-backend
ExecStart=/usr/local/bin/docker-compose -f docker-compose.prod.yml up -d
ExecStop=/usr/local/bin/docker-compose -f docker-compose.prod.yml down
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl daemon-reload
sudo systemctl enable convex
sudo systemctl start convex
```

## Connect Next.js App

```env
# .env.local in Next.js project
NEXT_PUBLIC_CONVEX_URL=https://convex.yourdomain.com
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
```

```bash
npx convex dev --url https://convex.yourdomain.com --admin-key your_admin_key
```

## Troubleshooting

```bash
# Check services
docker ps

# Check logs
npm run logs

# Check nginx
sudo systemctl status nginx
sudo nginx -t

# Check health
curl http://localhost:3210/health
curl https://convex.yourdomain.com/health

# View system resources
htop
docker stats
```
