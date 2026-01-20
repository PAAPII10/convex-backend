# Deployment Checklist

Use this checklist to ensure a successful deployment of Convex backend on EC2.

## Pre-Deployment

- [ ] EC2 instance created (Ubuntu 22.04, t3.medium+)
- [ ] Security group configured (ports 22, 80, 443)
- [ ] Domain name registered and DNS configured
- [ ] Supabase project created
- [ ] Supabase PostgreSQL database ready
- [ ] Supabase Storage bucket created
- [ ] Supabase S3 API credentials obtained
- [ ] GitHub repository created
- [ ] SSH key pair generated for GitHub Actions

## EC2 Setup

- [ ] SSH access to EC2 instance verified
- [ ] Initial server setup script run (`scripts/setup-ec2.sh`)
- [ ] Docker and Docker Compose installed
- [ ] User added to docker group
- [ ] Directory structure created (`/opt/convex`)
- [ ] Files copied to EC2 (or cloned from GitHub)

## Configuration

- [ ] Environment file created (`.env.production`)
- [ ] All environment variables configured:
  - [ ] Domain URLs
  - [ ] Database connection string
  - [ ] S3 credentials
  - [ ] Security secrets (random strings)
- [ ] Nginx configuration updated with your domain
- [ ] SSL certificate obtained (Let's Encrypt)

## GitHub Actions

- [ ] GitHub Secrets configured:
  - [ ] `EC2_HOST`
  - [ ] `EC2_USER`
  - [ ] `EC2_SSH_KEY`
- [ ] SSH public key added to EC2 `~/.ssh/authorized_keys`
- [ ] Workflow file committed to repository
- [ ] Branch protection rules set (if needed)

## Initial Deployment

- [ ] Docker Compose file in place
- [ ] Environment file in place
- [ ] Nginx configured and running
- [ ] SSL certificate active
- [ ] Docker images pulled
- [ ] Containers started successfully
- [ ] Admin key generated
- [ ] Health checks passing

## Verification

- [ ] Backend API accessible: `https://api.yourdomain.com/health`
- [ ] Dashboard accessible: `https://api.yourdomain.com/dashboard/`
- [ ] HTTP actions endpoint working
- [ ] Database connection verified
- [ ] S3 storage working (test file upload)
- [ ] GitHub Actions deployment successful

## Post-Deployment

- [ ] Admin key saved securely
- [ ] Convex CLI configured locally
- [ ] Monitoring set up (optional)
- [ ] Backup strategy documented
- [ ] Team access configured
- [ ] Documentation shared with team

## Troubleshooting Notes

If any step fails, check:
- [ ] EC2 instance logs: `docker compose logs`
- [ ] Nginx logs: `sudo tail -f /var/log/nginx/error.log`
- [ ] System resources: `htop` or `free -h`
- [ ] Network connectivity: `curl` or `ping`
- [ ] DNS resolution: `nslookup api.yourdomain.com`

## Security Checklist

- [ ] `.env.production` not committed to git
- [ ] SSH keys secured
- [ ] Firewall rules configured
- [ ] Strong secrets generated
- [ ] SSL certificate valid
- [ ] Regular updates scheduled
- [ ] Access logs monitored
