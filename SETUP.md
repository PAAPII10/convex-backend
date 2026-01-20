# Quick Setup Checklist

## Initial Setup Steps

1. **Copy environment template**
   ```bash
   cp .env.example .env
   ```

2. **Generate secrets**
   ```bash
   # Generate admin key
   npm run generate-key
   
   # Generate instance secret (or use openssl)
   openssl rand -hex 32
   ```

3. **Edit `.env` file**
   - Set `DATABASE_URL` to your PostgreSQL connection string (without database name)
     - **For Supabase**: Use port `6543` (pooler) and remove `/postgres` from the end
     - Example: `postgresql://postgres:password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543`
   - Paste generated `CONVEX_SELF_HOSTED_ADMIN_KEY`
   - Paste generated `INSTANCE_SECRET`
   - Verify `CONVEX_CLOUD_ORIGIN` is `http://localhost:3210`
   - Verify `CONVEX_SITE_ORIGIN` is `http://localhost:3211`

4. **Start Convex backend**
   ```bash
   npm run up
   ```

5. **Verify installation**
   ```bash
   npm run verify
   ```

6. **Access dashboard**
   - Open http://localhost:6791
   - Login with your admin key

## Connect Next.js App

1. **Set environment variables in Next.js project**
   ```env
   NEXT_PUBLIC_CONVEX_URL=http://localhost:3210
   CONVEX_SELF_HOSTED_ADMIN_KEY=your_admin_key
   ```

2. **Initialize Convex**
   ```bash
   npx convex dev --url http://localhost:3210 --admin-key your_admin_key
   ```

3. **Verify connection**
   - Check that `convex/_generated/api.d.ts` is created
   - Run the verification command above

## Important Notes

- PostgreSQL connection string should NOT include database name
- Keep admin key and instance secret secure
- Do not commit `.env` file to version control
- Backend runs on port 3210, dashboard on 6791
