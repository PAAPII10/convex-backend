# Convex Self-Hosted Backend

Self-hosted Convex backend configured to use an existing PostgreSQL database.

## Prerequisites

- Node.js 18+
- Docker & Docker Compose
- Existing PostgreSQL database (accessible via connection string)

## Deployment Options

- **Which Guide to Follow?** → See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) to choose the right guide
- **Local Development**: See [Quick Start](#quick-start) below
- **EC2 Production**: See [EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md) for complete AWS EC2 deployment guide
- **Multiple Services on EC2**: See [MULTI_SERVICE_SETUP.md](./MULTI_SERVICE_SETUP.md) if running alongside other services
- **Supabase Database**: See [SUPABASE_SETUP.md](./SUPABASE_SETUP.md) for Supabase-specific configuration
- **CI/CD with GitHub Actions**: See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for automated deployment setup

## Quick Start

### 1. Configure Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` and set:

- `DATABASE_URL`: Your PostgreSQL connection string (format: `postgresql://user:password@host:port`)
- `CONVEX_SELF_HOSTED_ADMIN_KEY`: Generate using `npm run generate-key`
- `INSTANCE_SECRET`: Generate a random 32+ character string
- `CONVEX_CLOUD_ORIGIN`: Default is `http://localhost:3210`
- `CONVEX_SITE_ORIGIN`: Default is `http://localhost:3211`

**Important**: 
- The `DATABASE_URL` should NOT include the database name. Convex will create/use its own database.
- **For Supabase**: Use port `6543` (connection pooler) instead of `5432` for easier setup. See `SUPABASE_SETUP.md` for details.

### 2. Generate Admin Key

```bash
npm run generate-key
```

Copy the generated key to your `.env` file.

### 3. Start Services

```bash
# Build and start containers
npm run up

# Or using docker compose directly
docker compose up -d
```

### 4. Verify Installation

```bash
# Check backend health
npm run verify

# Or manually
curl http://localhost:3210/health
```

### 5. Access Dashboard

Open http://localhost:6791 in your browser and log in with your admin key.

## Available Commands

```bash
npm run build          # Build Docker images
npm run up             # Start services in background
npm run down           # Stop services
npm run logs           # View all logs
npm run logs:backend   # View backend logs only
npm run logs:dashboard # View dashboard logs only
npm run restart        # Restart services
npm run generate-key   # Generate admin key
npm run verify         # Verify backend is running
```

## Connecting Next.js App

### 1. Install Convex Client

```bash
npm install convex
```

### 2. Configure Environment Variables

In your Next.js app's `.env.local`:

```env
NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key_here
```

### 3. Initialize Convex

```bash
npx convex dev --url http://localhost:3210 --admin-key your_admin_key_here
```

### 4. Use in Your App

```typescript
// lib/convex.ts
import { ConvexHttpClient } from "convex/browser";

const client = new ConvexHttpClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

// Use the client in your components
export { client };
```

Or with React hooks:

```typescript
// lib/convex-provider.tsx
"use client";

import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export function ConvexClientProvider({ children }: { children: React.ReactNode }) {
  return <ConvexProvider client={convex}>{children}</ConvexProvider>;
}
```

## Verification

Test the connection from your Next.js app:

```bash
npx convex dev --url http://localhost:3210 --admin-key YOUR_ADMIN_KEY
```

This will:
- Connect to your self-hosted instance
- Sync your schema
- Enable real-time updates

## Ports

- **3210**: Convex API (main endpoint)
- **3211**: Convex Site/Webhooks
- **6791**: Convex Dashboard

## Troubleshooting

### Backend won't start

1. Check PostgreSQL connection string format
2. Ensure PostgreSQL is accessible from Docker network
3. Verify all environment variables are set
4. Check logs: `npm run logs:backend`

### Can't connect from Next.js

1. Verify `NEXT_PUBLIC_CONVEX_URL` matches `CONVEX_CLOUD_ORIGIN`
2. Ensure admin key matches in both `.env` files
3. Check CORS settings if accessing from different origin

### Database connection errors

- Ensure `DATABASE_URL` doesn't include database name
- Verify PostgreSQL credentials are correct
- Check network connectivity between containers and PostgreSQL

## Production Considerations

- Use HTTPS for `CONVEX_CLOUD_ORIGIN` and `CONVEX_SITE_ORIGIN`
- Keep admin key and instance secret secure
- Set up proper backups for PostgreSQL
- Configure firewall rules appropriately
- Use environment-specific configuration files
- Monitor logs and health endpoints

## EC2 Deployment

For production deployment on AWS EC2, see the comprehensive guide:

- **[EC2_DEPLOYMENT.md](./EC2_DEPLOYMENT.md)** - Complete step-by-step EC2 deployment guide
- **[EC2_QUICK_REFERENCE.md](./EC2_QUICK_REFERENCE.md)** - Quick command reference for EC2

The EC2 deployment includes:
- Automated setup scripts
- Nginx reverse proxy configuration
- SSL/TLS with Let's Encrypt
- Systemd service for auto-start
- Production-optimized Docker Compose configuration
- Security best practices
