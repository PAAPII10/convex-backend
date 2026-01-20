# CONVEX_CLOUD_ORIGIN and CONVEX_SITE_ORIGIN Values Guide

## What Are These?

- **`CONVEX_CLOUD_ORIGIN`**: The public URL where your Convex API is accessible (port 3210)
- **`CONVEX_SITE_ORIGIN`**: The public URL where Convex Site/Webhooks are accessible (port 3211)

## Values by Environment

### 🏠 Local Development

```env
CONVEX_CLOUD_ORIGIN=http://localhost:3210
CONVEX_SITE_ORIGIN=http://localhost:3211
```

**Use when:**
- Testing locally on your machine
- Running `docker compose up` (not production)
- Development/testing purposes

---

### ☁️ EC2 Production (HTTP - Temporary)

If you haven't set up HTTPS yet:

```env
CONVEX_CLOUD_ORIGIN=http://your-ec2-ip:3210
CONVEX_SITE_ORIGIN=http://your-ec2-ip:3211
```

**Example:**
```env
CONVEX_CLOUD_ORIGIN=http://3.123.45.67:3210
CONVEX_SITE_ORIGIN=http://3.123.45.67:3211
```

**⚠️ Note:** This is temporary. Use HTTPS for production.

---

### 🔒 EC2 Production (HTTPS - Recommended)

After setting up nginx and SSL certificate:

```env
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

**Or if using different subdomains:**

```env
CONVEX_CLOUD_ORIGIN=https://api.yourdomain.com
CONVEX_SITE_ORIGIN=https://webhooks.yourdomain.com
```

**Most common:** Use the same domain for both:
```env
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

---

## How to Determine Your Values

### Step 1: Are you running locally or on EC2?

- **Local** → Use `http://localhost:3210` and `http://localhost:3211`
- **EC2** → Continue to Step 2

### Step 2: Do you have a domain and HTTPS?

- **No domain/HTTPS** → Use EC2 IP with HTTP (temporary)
- **Yes, have domain** → Use HTTPS with your domain

### Step 3: What's your domain setup?

**Option A: Single subdomain (recommended)**
```env
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```

**Option B: Different subdomains**
```env
CONVEX_CLOUD_ORIGIN=https://api.yourdomain.com
CONVEX_SITE_ORIGIN=https://webhooks.yourdomain.com
```

**Option C: Same domain, different paths** (if configured in nginx)
```env
CONVEX_CLOUD_ORIGIN=https://yourdomain.com/convex
CONVEX_SITE_ORIGIN=https://yourdomain.com/convex
```

---

## Examples

### Example 1: Local Development
```env
CONVEX_CLOUD_ORIGIN=http://localhost:3210
CONVEX_SITE_ORIGIN=http://localhost:3211
```

### Example 2: EC2 with IP (before HTTPS setup)
```env
CONVEX_CLOUD_ORIGIN=http://54.123.45.67:3210
CONVEX_SITE_ORIGIN=http://54.123.45.67:3211
```

### Example 3: EC2 with domain and HTTPS
```env
CONVEX_CLOUD_ORIGIN=https://convex.example.com
CONVEX_SITE_ORIGIN=https://convex.example.com
```

### Example 4: EC2 with different subdomains
```env
CONVEX_CLOUD_ORIGIN=https://convex-api.example.com
CONVEX_SITE_ORIGIN=https://convex-webhooks.example.com
```

---

## Important Notes

1. **Both values can be the same** - Most common setup uses the same domain for both
2. **Use HTTPS in production** - Always use `https://` for production deployments
3. **Match your nginx configuration** - These values should match what you configured in nginx
4. **No trailing slash** - Don't add `/` at the end
5. **Include protocol** - Always include `http://` or `https://`

---

## Quick Decision Tree

```
Are you running locally?
├─ YES → http://localhost:3210 and http://localhost:3211
└─ NO → Do you have a domain with HTTPS?
    ├─ NO → http://your-ec2-ip:3210 and http://your-ec2-ip:3211
    └─ YES → https://convex.yourdomain.com (for both)
```

---

## Updating These Values

### After Setting Up HTTPS

1. Update your `.env` file:
   ```env
   CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
   CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
   ```

2. Update GitHub Secret `CONVEX_ENV` with new values

3. Restart services:
   ```bash
   # On EC2
   cd ~/convex-backend
   docker compose -f docker-compose.prod.yml restart
   ```

Or push to trigger automatic deployment via GitHub Actions.

---

## Verification

After setting these values, verify they're correct:

```bash
# Check environment variables
cd ~/convex-backend
cat .env | grep CONVEX_CLOUD_ORIGIN
cat .env | grep CONVEX_SITE_ORIGIN

# Test the endpoints
curl https://convex.yourdomain.com/health
```

---

## Common Mistakes

❌ **Wrong:**
```env
CONVEX_CLOUD_ORIGIN=convex.yourdomain.com  # Missing https://
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com/  # Trailing slash
CONVEX_CLOUD_ORIGIN=http://convex.yourdomain.com  # Using http in production
```

✅ **Correct:**
```env
CONVEX_CLOUD_ORIGIN=https://convex.yourdomain.com
CONVEX_SITE_ORIGIN=https://convex.yourdomain.com
```
