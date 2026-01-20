# Supabase PostgreSQL Setup

## Connection Options

Supabase provides two connection methods:

### Option 1: Connection Pooler (Recommended) ✅

**Port: 6543** - Works from anywhere, no IP allowlisting needed

```env
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
```

**Advantages:**
- No IP allowlisting required
- Works from Docker containers
- Better for connection pooling
- Recommended for production

### Option 2: Direct Connection

**Port: 5432** - Requires IP allowlisting in Supabase dashboard

```env
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.rxzzrjokpozbmdzunkcr.supabase.co:5432
```

**Setup Steps:**
1. Go to Supabase Dashboard → Settings → Database
2. Find "Connection Pooling" section
3. Add your IP address to allowlist (or use 0.0.0.0/0 for development only)

## Important Notes

### Database Name in Connection String

**For Convex self-hosting:**
- Remove the `/postgres` database name from the connection string
- Convex will create/use its own database
- Format: `postgresql://user:pass@host:port` (no `/database` at end)

**Your connection string:**
```
postgresql://postgres:[YOUR-PASSWORD]@db.rxzzrjokpozbmdzunkcr.supabase.co:5432/postgres
```

**Should be:**
```
postgresql://postgres:[YOUR-PASSWORD]@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
```

Note: Changed port to 6543 (pooler) and removed `/postgres` at the end.

## IPv4 Compatibility

**No IPv4 compatibility needed!** Docker containers can connect to external databases over the internet. The connection pooler (port 6543) works from any network without special configuration.

## Quick Setup

1. **Get your Supabase connection string:**
   - Go to Supabase Dashboard → Settings → Database
   - Copy "Connection string" → "URI" format

2. **Modify for Convex:**
   - Change port from `5432` to `6543` (for pooler)
   - Remove `/postgres` database name from the end
   - Example: `postgresql://postgres:password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543`

3. **Add to `.env` file:**
   ```env
   DATABASE_URL=postgresql://postgres:your_password@db.rxzzrjokpozbmdzunkcr.supabase.co:6543
   ```

4. **Start Convex:**
   ```bash
   npm run up
   ```

## Troubleshooting

### Connection Refused
- Verify you're using port `6543` (pooler) instead of `5432`
- Check your password is correct
- Ensure Supabase project is active

### Authentication Failed
- Double-check username is `postgres` (default Supabase user)
- Verify password matches Supabase dashboard
- Check connection string format

### Database Creation Issues
- Ensure connection string doesn't include database name at the end
- Convex will create its own database automatically
