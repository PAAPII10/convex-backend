# Running Convex Alongside Other Services on EC2

This guide shows how to run Convex self-hosted backend alongside your existing service (port 3001) on the same EC2 instance.

## Port Allocation

| Service | Port | Notes |
|---------|------|-------|
| Your Existing Service | 3001 | Already running |
| Convex API | 3210 | New |
| Convex Site/Webhooks | 3211 | New |
| Convex Dashboard | 6791 | New (optional, localhost only) |

**No port conflicts!** All services can run simultaneously.

## Quick Setup

### 1. Deploy Convex (Doesn't Affect Your Service)

```bash
# Your existing service on 3001 continues running
# Deploy Convex in a separate directory
cd ~
git clone <your-repo> convex-backend
cd convex-backend/convex-backend

# Configure and start
cp .env.example .env
nano .env  # Configure your settings
./deploy-ec2.sh
```

Your service on port 3001 will continue running unaffected.

### 2. Configure Nginx for Multiple Services

You have two options:

#### Option A: Separate Subdomains (Recommended)

- `convex.yourdomain.com` → Convex (port 3210)
- `yourapp.yourdomain.com` → Your app (port 3001)

```bash
# Create Convex nginx config
sudo cp nginx.conf.example /etc/nginx/sites-available/convex
sudo nano /etc/nginx/sites-available/convex
# Update server_name to convex.yourdomain.com

# Your existing app config should already exist
# If not, create it:
sudo nano /etc/nginx/sites-available/yourapp
# Configure for port 3001

# Enable both
sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/yourapp /etc/nginx/sites-enabled/

# Test and reload
sudo nginx -t
sudo systemctl reload nginx

# Get SSL certificates
sudo certbot --nginx -d convex.yourdomain.com
sudo certbot --nginx -d yourapp.yourdomain.com
```

#### Option B: Same Domain, Different Paths

- `yourdomain.com/` → Your app (port 3001)
- `yourdomain.com/convex` → Convex (port 3210)

See `nginx.conf.multi-service.example` for path-based routing configuration.

### 3. Update DNS

If using Option A (subdomains), add DNS records:
- `A record`: `convex.yourdomain.com` → Your EC2 IP
- Your existing app DNS should already be configured

## Verify Both Services

```bash
# Check your existing service
curl http://localhost:3001

# Check Convex
curl http://localhost:3210/health

# Check all running services
docker ps
# Should show both your service and Convex containers
```

## Resource Management

### Check Resource Usage

```bash
# View all containers
docker ps

# View resource usage
docker stats

# View system resources
htop
```

### Recommended EC2 Instance Size

For running both services:
- **Minimum**: t3.medium (2 vCPU, 4GB RAM)
- **Recommended**: t3.large (2 vCPU, 8GB RAM) or larger

Monitor with:
```bash
free -h
df -h
```

## Security Group Updates

Add these rules to your existing security group:

| Type | Port | Source | Notes |
|------|------|--------|-------|
| HTTPS | 443 | 0.0.0.0/0 | For both services |
| Custom TCP | 3210 | Your IP | Optional, direct Convex access |
| Custom TCP | 3211 | Your IP | Optional, direct Convex access |
| Custom TCP | 6791 | Your IP | Dashboard (restrict!) |

Your existing rules for port 3001 should remain.

## Environment Variables

### Convex `.env` file

```env
# Database
DATABASE_URL=postgresql://postgres:password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543

# Secrets
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
INSTANCE_SECRET=your_instance_secret

# URLs (use subdomain)
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

### Next.js App Connection

```env
# In your Next.js app .env.local
NEXT_PUBLIC_CONVEX_URL=https://convex.yourdomain.com
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
```

## Managing Both Services

### View Logs

```bash
# Convex logs
cd ~/convex-backend
npm run logs

# Your existing service logs
# (depends on how it's deployed - docker logs, pm2, systemd, etc.)
```

### Restart Services

```bash
# Restart Convex
cd ~/convex-backend
npm run restart:prod

# Restart your existing service
# (use your existing restart method)
```

### Auto-Start on Boot

Convex already has systemd service setup. Your existing service should also have auto-start configured.

Check both:
```bash
sudo systemctl status convex
sudo systemctl status your-service-name
```

## Troubleshooting

### Port Already in Use

If you see port conflicts:
```bash
# Check what's using a port
sudo lsof -i :3210
sudo lsof -i :3211

# Check Docker containers
docker ps -a
```

### Nginx Conflicts

If nginx config conflicts:
```bash
# Test nginx config
sudo nginx -t

# Check for duplicate server_name
sudo grep -r "server_name" /etc/nginx/sites-enabled/

# View nginx error log
sudo tail -f /var/log/nginx/error.log
```

### Resource Issues

If EC2 runs out of resources:
```bash
# Check memory
free -h

# Check disk space
df -h

# Check CPU
top

# Restart if needed
sudo reboot
```

## Best Practices

1. **Use separate subdomains** for each service (cleaner separation)
2. **Monitor resources** - both services share the same EC2 resources
3. **Set up alerts** for high CPU/memory usage
4. **Use separate Docker networks** if needed (already configured in docker-compose.prod.yml)
5. **Keep services isolated** - Convex runs in its own containers
6. **Backup regularly** - both your app data and Convex data

## Example: Complete Setup

```bash
# 1. Your existing service is already running on port 3001
#    (no changes needed)

# 2. Deploy Convex
cd ~
git clone <repo> convex-backend
cd convex-backend/convex-backend
cp .env.example .env
nano .env  # Configure
./deploy-ec2.sh

# 3. Configure nginx for Convex subdomain
sudo cp nginx.conf.example /etc/nginx/sites-available/convex
sudo nano /etc/nginx/sites-available/convex
# Change server_name to convex.yourdomain.com

sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 4. Get SSL for Convex
sudo certbot --nginx -d convex.yourdomain.com

# 5. Update Convex .env with HTTPS URL
nano .env
# Set CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
# Set CONVEX_SITE_ORIGIN=https://convex.yourdomain.com

# 6. Restart Convex
npm run restart:prod

# 7. Verify both services
curl http://localhost:3001  # Your service
curl https://convex.yourdomain.com/health  # Convex
```

Both services now run independently on the same EC2 instance! 🚀
