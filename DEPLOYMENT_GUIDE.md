# Convex Backend Deployment Guide

## Which Guide to Follow?

Choose based on your setup:

### 🏠 **Local Development**
→ Follow **[SETUP.md](./SETUP.md)** or **[README.md](./README.md)** Quick Start section

### ☁️ **EC2 Deployment (Fresh Instance)**
→ Follow **[EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md)** - Complete step-by-step guide

### 🔀 **EC2 Deployment (Existing Services)**
→ Follow **[MULTI_SERVICE_SETUP.md](./MULTI_SERVICE_SETUP.md)** - If you already have services running on EC2

### 🗄️ **Supabase Database Setup**
→ Follow **[SUPABASE_SETUP.md](./SUPABASE_SETUP.md)** - For Supabase-specific configuration

### ⚡ **Quick Reference**
→ Follow **[EC2_QUICK_REFERENCE.md](./EC2_QUICK_REFERENCE.md)** - Command cheat sheet

---

## Recommended Setup Flow

### For First-Time EC2 Deployment:

1. **Initial Setup** → [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) Steps 1-4
2. **Database Config** → [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) (if using Supabase)
3. **Deploy** → [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) Steps 5-6
4. **HTTPS Setup** → [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) Step 7
5. **CI/CD Setup** → See GitHub Actions section below

### For EC2 with Existing Services:

1. **Multi-Service Guide** → [MULTI_SERVICE_SETUP.md](./MULTI_SERVICE_SETUP.md)
2. **Database Config** → [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
3. **Deploy** → Follow MULTI_SERVICE_SETUP.md deployment steps

---

## GitHub Actions CI/CD Setup

### Prerequisites

1. **GitHub Secrets** - Add these in your repository settings:

   | Secret Name | Description | How to Find | Example |
   |-------------|-------------|-------------|---------|
   | `AWS_ACCESS_KEY_ID` | AWS access key | AWS Console → IAM → Users → Security credentials | `AKIA...` |
   | `AWS_SECRET_ACCESS_KEY` | AWS secret key | Same as above (create access key) | `wJalr...` |
   | `EC2_SSH_KEY` | EC2 SSH private key | The `.pem` file content you downloaded when creating EC2 | `-----BEGIN RSA PRIVATE KEY-----...` |
   | `EC2_USERNAME` | EC2 username | See table below based on AMI | `ubuntu` |
   | `HOST_DNS` | EC2 public IP or DNS | AWS Console → EC2 → Instances → Your instance → Public IPv4 address or Public IPv4 DNS | `3.123.45.67` or `ec2-3-123-45-67.compute-1.amazonaws.com` |
   | `AWS_REGION` | AWS region | Region where your EC2 instance is located | `us-east-1` |

#### EC2_USERNAME by AMI Type

| AMI Type | Username |
|----------|----------|
| Ubuntu | `ubuntu` |
| Amazon Linux 2 | `ec2-user` |
| Amazon Linux 2023 | `ec2-user` |
| Debian | `admin` |
| RHEL | `ec2-user` |
| CentOS | `centos` |
| SUSE | `ec2-user` |

**Most common**: `ubuntu` (if using Ubuntu AMI)

#### HOST_DNS - How to Find

1. **AWS Console Method:**
   - Go to AWS Console → EC2 → Instances
   - Click on your EC2 instance
   - Look for "Public IPv4 address" or "Public IPv4 DNS"
   - Use either one (IP or DNS name both work)

2. **Command Line Method:**
   ```bash
   # If you're already SSH'd into the instance
   curl http://169.254.169.254/latest/meta-data/public-ipv4
   curl http://169.254.169.254/latest/meta-data/public-hostname
   ```

**Example values:**
- Public IP: `3.123.45.67`
- Public DNS: `ec2-3-123-45-67.compute-1.amazonaws.com`
- Either format works for `HOST_DNS`

2. **Initial Manual Deployment** - Deploy once manually to set up the directory structure:
   ```bash
   # On EC2
   mkdir -p ~/convex-backend
   # Upload files and configure .env
   ```

### Workflow File

The GitHub Actions workflow is already created at:
- **`.github/workflows/deploy.yml`**

### What It Does

1. ✅ Triggers on push to `production` or `main` branch
2. ✅ Pulls latest Convex Docker images from GitHub Container Registry
3. ✅ Stops existing services gracefully
4. ✅ Starts services with latest images
5. ✅ Verifies health check
6. ✅ Shows service status

### Manual Deployment vs CI/CD

**Use Manual Deployment when:**
- First-time setup
- Changing environment variables
- Troubleshooting issues
- Testing configuration changes

**Use CI/CD when:**
- Updating code/config files
- Regular deployments
- Team collaboration
- Automated updates

### Updating Environment Variables

The workflow automatically creates/updates the `.env` file from the `CONVEX_ENV` GitHub secret.

**Option 1: Update GitHub Secret (Recommended)**
1. Update your local `.env` file
2. Go to GitHub → Settings → Secrets → `CONVEX_ENV`
3. Update the secret with new content
4. Push to trigger deployment (or manually trigger workflow)

**Option 2: Manual Update on EC2**
```bash
# SSH into EC2
ssh ubuntu@your-ec2-ip
cd ~/convex-backend
nano .env
# Make changes
docker compose -f docker-compose.prod.yml restart
```

See **[ENV_VARIABLES_GUIDE.md](./ENV_VARIABLES_GUIDE.md)** for detailed instructions.

### Workflow Customization

The workflow file (`.github/workflows/deploy.yml`) can be customized:

- **Change trigger branches**: Edit `branches: [ 'production', 'main' ]`
- **Add notifications**: Add Slack/Discord webhooks
- **Add rollback**: Add step to rollback on failure
- **Add tests**: Add health check tests before deployment

### Troubleshooting CI/CD

**Deployment fails:**
```bash
# SSH into EC2 and check logs
ssh ubuntu@your-ec2-ip
cd ~/convex-backend
docker compose logs
```

**Services not starting:**
```bash
# Check Docker
docker ps -a
docker compose -f docker-compose.prod.yml up -d
```

**Health check fails:**
```bash
# Test manually
curl http://localhost:3210/health
# Check environment variables
cat .env
```

---

## Quick Start Checklist

### First Deployment (Manual)

- [ ] Follow [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) or [MULTI_SERVICE_SETUP.md](./MULTI_SERVICE_SETUP.md)
- [ ] Configure `.env` file with database and secrets
- [ ] Deploy manually: `./deploy-ec2.sh`
- [ ] Verify: `curl http://localhost:3210/health`
- [ ] Set up HTTPS (optional but recommended)
- [ ] Configure GitHub Secrets
- [ ] Push to trigger CI/CD

### Subsequent Deployments

- [ ] Push changes to `production` or `main` branch
- [ ] GitHub Actions automatically deploys
- [ ] Monitor deployment in GitHub Actions tab
- [ ] Verify: `curl https://convex.yourdomain.com/health`

---

## Need Help?

1. **Setup Issues** → Check the specific guide for your scenario
2. **Deployment Issues** → Check [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) Troubleshooting section
3. **CI/CD Issues** → Check GitHub Actions logs and EC2 logs
4. **Database Issues** → Check [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
