# Self-Hosted Convex Backend on EC2

Complete setup guide for self-hosting Convex backend on AWS EC2 with GitHub Actions CI/CD, using Supabase PostgreSQL and S3-compatible storage.

## Architecture

```
┌─────────────────┐
│  GitHub Repo    │
│  + GitHub       │
│    Actions      │
└────────┬────────┘
         │ SSH Deploy
         ▼
┌─────────────────┐
│  EC2 Instance   │
│  ┌───────────┐  │
│  │  Docker   │  │
│  │  Compose  │  │
│  └───────────┘  │
│  ┌───────────┐  │
│  │  Nginx    │  │
│  │  (Proxy)  │  │
│  └───────────┘  │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────┐
│Supabase │ │ Supabase │
│Postgres │ │   S3     │
└─────────┘ └──────────┘
```

## Prerequisites

- AWS EC2 instance (Ubuntu 22.04 LTS)
  - **Recommended**: `t3.medium` or higher (2 vCPU, 4GB RAM)
  - **Minimum**: `t2.micro` or `t3.micro` (1GB RAM) - for testing/very low-traffic
  - **Note**: t2.micro (1 vCPU) is more constrained than t3.micro (2 vCPU)
- Supabase project with PostgreSQL database
- Supabase Storage bucket configured for S3-compatible access
- Domain name pointing to EC2 instance
- GitHub repository with Actions enabled

## Phase 1: EC2 Server Preparation

### 1. Create EC2 Instance

- **OS**: Ubuntu 22.04 LTS
- **Instance Type**: 
  - **Recommended**: `t3.medium` (2 vCPU, 4GB RAM) - for production workloads
  - **Minimum**: `t2.micro` (1 vCPU, 1GB RAM) or `t3.micro` (2 vCPU, 1GB RAM) - for testing/very low-traffic
  - **Note**: t2.micro/t3.micro will experience performance limitations under load
- **Storage**: Minimum 20GB (30GB recommended)
- **Security Group**:
  - Port 22 (SSH)
  - Port 80 (HTTP)
  - Port 443 (HTTPS)

### 2. Initial Server Setup

SSH into your EC2 instance and run:

```bash
# Clone this repository or upload files
git clone <your-repo-url>
cd convex-backend

# Run setup script
chmod +x scripts/setup-ec2.sh
./scripts/setup-ec2.sh

# If you were added to docker group, either:
newgrp docker
# OR log out and log back in

# For t2.micro instances, run optimization script:
chmod +x scripts/setup-t2-micro.sh
./scripts/setup-t2-micro.sh
```

### 3. Directory Structure

The setup script creates:

```
/opt/convex/
 ├── docker-compose.yml
 ├── .env.production
 ├── data/
 └── nginx/
```

### 4. Instance Type Considerations

#### t2.micro (1 vCPU, 1GB RAM) - **Absolute Minimum**
- ✅ **Suitable for**: Testing, development, very light workloads
- ⚠️ **Limitations**: 
  - Only 1 vCPU (single-threaded operations)
  - Limited memory may cause OOM errors
  - Very slow under any load
  - **Must** reduce `ACTION_WORKER_COUNT` to 1-2
  - **Highly recommended** to enable swap space
- 💡 **Optimization tips** (REQUIRED for t2.micro):
  ```bash
  # In .env.production - reduce worker count
  ACTION_WORKER_COUNT=1
  
  # Enable swap to prevent OOM (REQUIRED for t2.micro)
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  
  # Verify swap is active
  free -h
  ```

#### t3.micro (2 vCPU, 1GB RAM)
- ✅ **Suitable for**: Testing, development, low-traffic applications
- ⚠️ **Limitations**: 
  - Limited memory may cause OOM (Out of Memory) errors under load
  - Slower response times during peak usage
  - Should reduce `ACTION_WORKER_COUNT` to 2-4
- 💡 **Optimization tips**:
  ```bash
  # Reduce worker count in .env.production
  ACTION_WORKER_COUNT=2
  
  # Enable swap to prevent OOM (recommended)
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  ```

#### t3.small (2GB RAM)
- ✅ **Suitable for**: Small production workloads, moderate traffic
- 💡 **Recommended**: Good balance of cost and performance

#### t3.medium (4GB RAM) or higher
- ✅ **Suitable for**: Production workloads, higher traffic
- 💡 **Recommended**: Best for production environments

**Cost Comparison** (approximate):
- t2.micro: ~$7-8/month (Free tier eligible)
- t3.micro: ~$7-8/month
- t3.small: ~$15/month
- t3.medium: ~$30/month

## Phase 2: Supabase Configuration

### 1. PostgreSQL Setup

1. Create a Supabase project
2. Go to **Settings** → **Database**
3. Copy the connection string or collect:
   - Host
   - Port (usually 5432)
   - Database name
   - Username
   - Password

**Connection String Format:**
```
postgresql://USER:PASSWORD@HOST:PORT/DATABASE?sslmode=require
```

### 2. Supabase Storage (S3-compatible)

1. Go to **Storage** in Supabase dashboard
2. Create a new bucket (e.g., `convex-files`)
3. Go to **Settings** → **API** → **Storage**
4. Enable S3 API and collect:
   - S3 Endpoint: `https://<project-id>.supabase.co/storage/v1/s3`
   - Access Key ID
   - Secret Access Key
   - Region (usually `us-east-1`)

## Phase 3: Environment Configuration

### Generate Environment File

```bash
cd /opt/convex
chmod +x scripts/generate-env.sh
./scripts/generate-env.sh
```

Or manually create `.env.production`:

```bash
cp env.production.example .env.production
nano .env.production
```

**Important Variables:**
- `CONVEX_CLOUD_ORIGIN`: Your public API URL (e.g., `https://api.yourdomain.com`)
- `DATABASE_URL`: Supabase PostgreSQL connection string
- `AWS_S3_ENDPOINT`: Supabase S3 endpoint
- `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`: Supabase S3 credentials
- `AWS_S3_BUCKET`: Your bucket name
- `ACTION_WORKER_COUNT`: Number of action workers 
  - t2.micro: Use 1-2 workers
  - t3.micro: Use 2-4 workers
  - t3.small+: Use 4-8 workers

## Phase 4: Nginx Configuration

### 1. Copy Nginx Configuration

```bash
sudo chmod +x scripts/setup-nginx.sh
sudo ./scripts/setup-nginx.sh api.yourdomain.com
```

Or manually:

```bash
sudo cp nginx/nginx.conf /etc/nginx/sites-available/convex
sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Remove default site
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

### 2. SSL Certificate (Let's Encrypt)

```bash
sudo certbot --nginx -d api.yourdomain.com
```

Make sure your domain DNS points to the EC2 instance IP before running certbot.

## Phase 5: GitHub Actions Setup

### 1. Create GitHub Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

- `EC2_HOST`: Your EC2 public IP or domain (e.g., `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`)
- `EC2_USER`: SSH user (usually `ubuntu`)
- `EC2_SSH_KEY`: Your private SSH key content

### 2. Generate SSH Key Pair (if needed)

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/ec2_deploy_key

# Copy public key to EC2
ssh-copy-id -i ~/.ssh/ec2_deploy_key.pub ubuntu@YOUR_EC2_IP

# Add private key to GitHub Secrets
cat ~/.ssh/ec2_deploy_key
```

### 3. Workflow File

The workflow file (`.github/workflows/deploy.yml`) is already configured. It will:
- Deploy on push to `main` or `production` branch
- Pull latest Docker images
- Restart containers
- Verify deployment

## Phase 6: Initial Deployment

### Manual Deployment (First Time)

```bash
cd /opt/convex

# Pull images
docker compose pull

# Start services
docker compose up -d

# Generate admin key
docker compose exec backend ./generate_admin_key.sh

# Save admin key
docker compose exec backend ./generate_admin_key.sh > admin_key.txt
cat admin_key.txt
```

### Via GitHub Actions

1. Push code to `main` branch
2. GitHub Actions will automatically deploy
3. Check Actions tab for deployment status

## Phase 7: Post-Deployment

### 1. Get Admin Key

```bash
cd /opt/convex
docker compose exec backend ./generate_admin_key.sh
```

Save this key securely. You'll need it for:
- Convex CLI authentication
- Dashboard access

### 2. Configure Convex CLI

```bash
# Install Convex CLI
npm install -g convex

# Set self-hosted URL
export CONVEX_SELF_HOSTED_URL='https://api.yourdomain.com'
export CONVEX_SELF_HOSTED_ADMIN_KEY='instance|your-admin-key-here'

# Or add to ~/.bashrc or ~/.zshrc
echo 'export CONVEX_SELF_HOSTED_URL="https://api.yourdomain.com"' >> ~/.bashrc
echo 'export CONVEX_SELF_HOSTED_ADMIN_KEY="instance|your-admin-key-here"' >> ~/.bashrc
```

### 3. Access Dashboard

- Dashboard: `https://api.yourdomain.com/dashboard/`
- API: `https://api.yourdomain.com/`
- HTTP Actions: `https://api.yourdomain.com/actions/`

## Monitoring & Maintenance

### Check Service Status

```bash
cd /opt/convex
docker compose ps
docker compose logs -f backend
```

### Update Deployment

Simply push to `main` branch - GitHub Actions will handle the rest.

### Manual Update

```bash
cd /opt/convex
docker compose pull
docker compose up -d
docker image prune -f  # Clean up old images
```

### Backup

Since data is stored in Supabase:
- **Database**: Supabase handles backups automatically
- **Files**: Stored in Supabase Storage (S3)
- **Local data**: Only temporary/cache data in `/opt/convex/data`

## Troubleshooting

### Services Not Starting

```bash
# Check logs
docker compose logs backend
docker compose logs dashboard

# Check environment
docker compose config

# Verify .env.production
cat .env.production
```

### Database Connection Issues

- Verify `DATABASE_URL` in `.env.production`
- Check Supabase connection settings
- Ensure IP is whitelisted in Supabase (if required)

### S3 Storage Issues

- Verify Supabase Storage S3 API is enabled
- Check bucket permissions
- Verify credentials in `.env.production`

### Nginx Issues

```bash
# Test configuration
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log

# Restart nginx
sudo systemctl restart nginx
```

### SSL Certificate Issues

```bash
# Renew certificate
sudo certbot renew

# Check certificate status
sudo certbot certificates
```

## Security Best Practices

1. **Never commit `.env.production`** - It's in `.gitignore`
2. **Use strong secrets** - Generate random strings for `CONVEX_INSTANCE_SECRET` and `JWT_SIGNING_KEY`
3. **Restrict SSH access** - Use key-based authentication only
4. **Keep system updated** - Run `sudo apt update && sudo apt upgrade` regularly
5. **Monitor logs** - Check Docker and Nginx logs regularly
6. **Use security groups** - Restrict EC2 ports to necessary only

## File Structure

```
convex-backend/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD
├── nginx/
│   └── nginx.conf              # Nginx reverse proxy config
├── scripts/
│   ├── setup-ec2.sh            # EC2 initial setup
│   ├── generate-env.sh         # Environment file generator
│   └── setup-nginx.sh          # Nginx configuration
├── docker-compose.yml          # Docker Compose configuration
├── .env.production.template    # Environment variables template
└── README.md                   # This file
```

## References

- [Convex Self-Hosted Documentation](https://github.com/get-convex/convex-backend/blob/main/self-hosted/README.md)
- [Supabase Documentation](https://supabase.com/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## Support

For issues related to:
- **Convex Backend**: [Convex GitHub Issues](https://github.com/get-convex/convex-backend/issues)
- **This Setup**: Open an issue in this repository
