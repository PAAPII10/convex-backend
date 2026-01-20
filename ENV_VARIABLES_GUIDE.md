# Environment Variables Setup Guide

## How Environment Variables Work

The GitHub Actions workflow automatically creates/updates the `.env` file on your EC2 instance during deployment using the `CONVEX_ENV` secret.

## Setup Steps

### 1. Create Your `.env` File Locally

Create a `.env` file with all required variables:

```env
DATABASE_URL=postgresql://postgres:your_password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
CONVEX_SELF_HOSTED_ADMIN_KEY=your_generated_admin_key
INSTANCE_SECRET=your_generated_instance_secret
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

### 2. Generate Required Secrets

**Admin Key:**
```bash
openssl rand -hex 32
```

**Instance Secret:**
```bash
openssl rand -hex 32
```

### 3. Add to GitHub Secret

1. Go to your GitHub repository
2. **Settings → Secrets and variables → Actions → New repository secret**
3. Name: `CONVEX_ENV`
4. Value: Copy the **entire content** of your `.env` file (all lines)
5. Click **Add secret**

### 4. Format Requirements

**✅ DO:**
- Include all variable assignments
- Use exact format: `VARIABLE_NAME=value`
- One variable per line
- No trailing spaces

**❌ DON'T:**
- Don't include comments (they'll be written to the file)
- Don't include empty lines (optional, but cleaner)
- Don't include quotes around values (unless needed)

**Example of correct format:**
```env
DATABASE_URL=postgresql://postgres:pass@host:6543
CONVEX_SELF_HOSTED_ADMIN_KEY=abc123def456
INSTANCE_SECRET=xyz789uvw012
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string (no DB name) | `postgresql://user:pass@host:6543` |
| `CONVEX_SELF_HOSTED_ADMIN_KEY` | Admin key for dashboard/auth | Generated hex string |
| `INSTANCE_SECRET` | Encryption secret | Generated hex string |
| `CONVEX_CLOUD_ORIGIN` | API origin URL | `https://convex.yourdomain.com` |
| `CONVEX_SITE_ORIGIN` | Site/webhook origin URL | `https://convex.yourdomain.com` |

## Updating Environment Variables

### Method 1: Update GitHub Secret (Recommended)

1. Update your local `.env` file
2. Go to GitHub → Settings → Secrets → `CONVEX_ENV`
3. Click **Update**
4. Paste new content
5. Push to trigger deployment (or manually trigger workflow)

### Method 2: Manual Update on EC2

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Edit .env file
cd ~/convex-backend
nano .env

# Restart services
docker compose -f docker-compose.prod.yml restart
```

## Verification

After deployment, verify environment variables are set:

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@your-ec2-ip

# Check .env file
cd ~/convex-backend
cat .env

# Verify services are using correct env
docker compose -f docker-compose.prod.yml config
```

## Security Best Practices

1. **Never commit `.env` file** - It's in `.gitignore`
2. **Use GitHub Secrets** - Store sensitive values as secrets
3. **Rotate secrets regularly** - Update admin keys and instance secrets periodically
4. **Restrict access** - Only give access to trusted team members
5. **Use different secrets per environment** - Dev, staging, production should have separate secrets

## Troubleshooting

### Environment variables not working

```bash
# Check if .env file exists
ls -la ~/convex-backend/.env

# Check file content
cat ~/convex-backend/.env

# Check if services are using env
docker compose -f docker-compose.prod.yml config | grep -A 5 environment
```

### Services failing to start

```bash
# Check logs for environment variable errors
cd ~/convex-backend
docker compose logs backend | grep -i error
docker compose logs dashboard | grep -i error
```

### Database connection issues

- Verify `DATABASE_URL` format (no database name at end)
- Check Supabase connection string
- Ensure using port 6543 (pooler) for Supabase

## Example: Complete Setup

```bash
# 1. Generate secrets locally
openssl rand -hex 32  # For CONVEX_SELF_HOSTED_ADMIN_KEY
openssl rand -hex 32  # For INSTANCE_SECRET

# 2. Create .env file
cat > .env << EOF
DATABASE_URL=postgresql://postgres:your_password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
CONVEX_SELF_HOSTED_ADMIN_KEY=abc123def456789...
INSTANCE_SECRET=xyz789uvw012345...
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
EOF

# 3. Copy content and add to GitHub Secret CONVEX_ENV
cat .env

# 4. Push to trigger deployment
git push origin main
```
