# EC2 Deployment Guide

Complete guide for deploying Convex self-hosted backend on AWS EC2.

## Prerequisites

- EC2 instance (Ubuntu 22.04 LTS recommended)
- Domain name (optional, for HTTPS)
- AWS Security Group configured
- SSH access to EC2 instance

**Note**: If you already have services running on this EC2 instance, see [MULTI_SERVICE_SETUP.md](./MULTI_SERVICE_SETUP.md) for running Convex alongside existing services.

## Step 1: EC2 Instance Setup

### Launch EC2 Instance

1. **Instance Type**: `t3.medium` or larger (2+ vCPU, 4GB+ RAM recommended)
2. **AMI**: Ubuntu 22.04 LTS
3. **Storage**: 20GB+ SSD
4. **Security Group**: See Step 2 below

### Connect to EC2

```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

## Step 2: Configure Security Group

In AWS Console → EC2 → Security Groups, **add** these rules to your existing security group:

| Type | Protocol | Port Range | Source | Notes |
|------|----------|------------|--------|-------|
| HTTP | TCP | 80 | 0.0.0.0/0 | If not already open |
| HTTPS | TCP | 443 | 0.0.0.0/0 | If not already open |
| Custom TCP | TCP | 3210 | Your IP | Convex API (optional direct access) |
| Custom TCP | TCP | 3211 | Your IP | Convex Site (optional direct access) |
| Custom TCP | TCP | 6791 | Your IP only | Dashboard (restrict!) |

**Note**: 
- Your existing rules (SSH, port 3001, etc.) should remain unchanged
- Ports 3210, 3211, and 6791 are optional - nginx will proxy through 443
- **Security Note**: Restrict ports 3210, 3211, and 6791 to specific IPs in production

## Step 3: Install Dependencies on EC2

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Node.js (for npm scripts)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install nginx (for reverse proxy/HTTPS)
sudo apt install -y nginx certbot python3-certbot-nginx

# Log out and back in for docker group to take effect
exit
# SSH back in
```

## Step 4: Deploy Convex Backend

### Option A: Clone Repository

```bash
# Clone your repository
git clone <your-repo-url> convex-backend
cd convex-backend/convex-backend

# Or upload files via SCP
# scp -r convex-backend ubuntu@your-ec2-ip:~/
```

### Option B: Upload Files

```bash
# Create directory
mkdir -p ~/convex-backend
cd ~/convex-backend

# Upload files from local machine:
# scp -r convex-backend/* ubuntu@your-ec2-ip:~/convex-backend/
```

## Step 5: Configure Environment Variables

```bash
cd ~/convex-backend

# Copy environment template
cp .env.example .env

# Edit environment file
nano .env
```

Set these values in `.env`:

```env
# PostgreSQL (Supabase)
DATABASE_URL=postgresql://postgres:your_password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543

# Generate admin key
CONVEX_SELF_HOSTED_ADMIN_KEY=your_generated_admin_key

# Generate instance secret
INSTANCE_SECRET=your_generated_instance_secret

# Use your EC2 public IP or domain
# For HTTP (temporary):
CONVEX_CLOUD_ORIGIN=http://your-ec2-ip:3210
CONVEX_SITE_ORIGIN=http://your-ec2-ip:3211

# For HTTPS (after SSL setup):
# CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
# CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

Generate secrets:

```bash
# Generate admin key
npm run generate-key

# Generate instance secret
openssl rand -hex 32
```

## Step 6: Start Convex Services

```bash
# Start services
npm run up

# Check logs
npm run logs

# Verify health
curl http://localhost:3210/health
```

## Step 7: Configure Nginx Reverse Proxy (HTTPS)

### Get Your Domain Ready

1. Point your domain to EC2 IP:
   - `A record`: `convex.yourdomain.com` → `your-ec2-ip`

### Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/convex
```

Add this configuration:

```nginx
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name convex.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl http2;
    server_name convex.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/convex.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/convex.yourdomain.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Convex API (port 3210)
    location / {
        proxy_pass http://localhost:3210;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Convex Site/Webhooks (port 3211)
    location /site {
        proxy_pass http://localhost:3211;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Dashboard (optional, restrict access)
server {
    listen 6791;
    server_name convex.yourdomain.com;

    # Restrict by IP (optional)
    # allow your.ip.address;
    # deny all;

    location / {
        proxy_pass http://localhost:6791;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable site:

```bash
sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Get SSL Certificate

```bash
sudo certbot --nginx -d convex.yourdomain.com
```

Follow prompts. Certbot will automatically configure SSL.

### Update Environment Variables for HTTPS

```bash
nano ~/convex-backend/.env
```

Update:

```env
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

Restart services:

```bash
cd ~/convex-backend
npm run restart
```

## Step 8: Auto-Start on Boot (Systemd)

Create systemd service:

```bash
sudo nano /etc/systemd/system/convex.service
```

Add:

```ini
[Unit]
Description=Convex Self-Hosted Backend
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/convex-backend
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable convex
sudo systemctl start convex
sudo systemctl status convex
```

## Step 9: Connect Next.js App

Update your Next.js `.env.local`:

```env
NEXT_PUBLIC_CONVEX_URL=https://convex.yourdomain.com
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
```

Initialize:

```bash
npx convex dev --url https://convex.yourdomain.com --admin-key your_admin_key
```

## Step 10: Verify Deployment

```bash
# Check backend health
curl https://convex.yourdomain.com/health

# Check services
docker ps

# Check logs
cd ~/convex-backend
npm run logs

# Test from Next.js app
npx convex dev --url https://convex.yourdomain.com --admin-key your_admin_key
```

## Maintenance Commands

```bash
cd ~/convex-backend

# View logs
npm run logs
npm run logs:backend
npm run logs:dashboard

# Restart services
npm run restart

# Stop services
npm run down

# Start services
npm run up

# Update images
docker compose pull
npm run restart
```

## Security Best Practices

1. **Firewall**: Use `ufw` to restrict ports
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **SSH**: Disable password authentication, use key-based only

3. **Secrets**: Never commit `.env` file

4. **Dashboard Access**: Restrict port 6791 to your IP only

5. **Regular Updates**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   docker compose pull
   ```

## Troubleshooting

### Services won't start
```bash
# Check logs
npm run logs

# Check Docker
docker ps -a
docker logs convex-backend
```

### Can't connect from Next.js
- Verify `NEXT_PUBLIC_CONVEX_URL` matches your domain
- Check security group allows port 443
- Verify nginx is running: `sudo systemctl status nginx`

### SSL certificate issues
```bash
# Renew certificate
sudo certbot renew

# Test nginx config
sudo nginx -t
```

### Database connection errors
- Verify Supabase connection string
- Check EC2 can reach Supabase (test with `telnet`)
- Ensure using port 6543 (pooler)

## Monitoring

### View Resource Usage
```bash
# Docker stats
docker stats

# System resources
htop
```

### Log Rotation
Docker handles log rotation automatically. To configure:

```bash
sudo nano /etc/docker/daemon.json
```

Add:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker:
```bash
sudo systemctl restart docker
```
