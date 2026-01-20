# Quick Reference - Convex Self-Hosted Setup

## Setup Commands

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Generate admin key
npm run generate-key
# Copy the output key to .env file

# 3. Generate instance secret
openssl rand -hex 32
# Copy to INSTANCE_SECRET in .env

# 4. Edit .env file
# Set DATABASE_URL (PostgreSQL connection string without database name)
# Set CONVEX_SELF_HOSTED_ADMIN_KEY (from step 2)
# Set INSTANCE_SECRET (from step 3)

# 5. Start services
npm run up

# 6. Verify
npm run verify
```

## Management Commands

```bash
npm run up              # Start services
npm run down            # Stop services
npm run logs            # View all logs
npm run logs:backend    # Backend logs only
npm run logs:dashboard  # Dashboard logs only
npm run restart         # Restart services
npm run verify          # Check health
```

## Next.js Connection

```bash
# In your Next.js project:

# 1. Install Convex
npm install convex

# 2. Set environment variables (.env.local)
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key

# 3. Initialize Convex
npx convex dev --url http://localhost:3210 --admin-key your_admin_key

# 4. Verify connection
# Check that convex/_generated/api.d.ts exists
```

## Ports

- `3210` - Convex API
- `3211` - Convex Site/Webhooks  
- `6791` - Dashboard

## Environment Variables Required

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection (no DB name) | `postgresql://user:pass@host:5432` |
| `CONVEX_SELF_HOSTED_ADMIN_KEY` | Admin key for auth | Generated via script |
| `INSTANCE_SECRET` | Encryption secret | Generated via openssl |
| `CONVEX_CLOUD_ORIGIN` | API origin | `http://localhost:3210` |
| `CONVEX_SITE_ORIGIN` | Site origin | `http://localhost:3211` |
