# Self-Hosted Convex Backend on EC2 - Detailed Setup Guide (Ubuntu)

Complete step-by-step guide for self-hosting Convex backend on AWS EC2 (Ubuntu 22.04 LTS) with GitHub Actions CI/CD, using Supabase PostgreSQL and S3-compatible storage.

**This guide is specifically written for Ubuntu 22.04 LTS on EC2.**

## Prerequisites - Ubuntu 22.04 LTS

**This guide is specifically for Ubuntu 22.04 LTS on EC2.**

Verify your Ubuntu version:
```bash
# Check Ubuntu version
lsb_release -a
# Should show: Ubuntu 22.04 LTS

# OR
cat /etc/os-release
```

**Default user:** This guide assumes you're using the `ubuntu` user (default on EC2 Ubuntu instances).

**Package manager:** All commands use `apt` (Ubuntu's package manager).

---

## Current Status

✅ **You have completed:**
- Phase 1: EC2 Server Preparation (cloned repository)
- Phase 2: Supabase Configuration (PostgreSQL and S3 Storage ready)

📋 **Next Steps:**
- Phase 3: Environment Configuration (create `.env.production` file)
- Phase 4: Copy files to `/opt/convex/` directory
- Phase 5: Nginx Configuration
- Phase 6: Initial Deployment

---

## Phase 3: Environment Configuration - CREATE `.env.production` FILE

### Step 3.1: Navigate to Your Repository Directory

You should already be in your cloned repository. If not:

```bash
# Find where you cloned the repository (Ubuntu home directory)
cd ~
# On Ubuntu EC2, this is typically /home/ubuntu

ls -la
# Look for a directory like 'convex-backend' or your repository name

# Navigate to it (replace 'convex-backend' with your actual folder name)
cd convex-backend

# Verify you're in the right place - you should see these files:
ls -la
# You should see: docker-compose.yml, env.production.example, scripts/, nginx/, etc.

# Check current user (should be 'ubuntu' on EC2)
whoami
```

### Step 3.2: Copy Files to `/opt/convex/` Directory

**IMPORTANT:** Your repository is in `/home/ubuntu/convex-backend/` (where you cloned it), but deployment files MUST be in `/opt/convex/` directory.

**You need to CREATE `/opt/convex/` and copy files there.**

**For Ubuntu:**

```bash
# Step 1: Make sure you're in your repository directory
cd ~/convex-backend
# OR
cd /home/ubuntu/convex-backend

# Verify you're in the right place
pwd
# Should show: /home/ubuntu/convex-backend

# Verify repository files exist
ls -la
# Should see: docker-compose.yml, env.production.example, scripts/, nginx/, etc.

# Step 2: CREATE the deployment directory /opt/convex (it doesn't exist yet!)
sudo mkdir -p /opt/convex
sudo mkdir -p /opt/convex/scripts
sudo mkdir -p /opt/convex/data
sudo mkdir -p /opt/convex/nginx

# Step 3: Change ownership so you can write to it (Ubuntu)
sudo chown -R $USER:$USER /opt/convex

# Step 4: Verify ownership (Ubuntu)
ls -ld /opt/convex
# Should show your username (ubuntu) as owner

# Step 5: Verify the directory was created
ls -la /opt/convex/
# Should show empty or just the directories we created

# Step 6: Copy files from repository to /opt/convex/
# (Make sure you're still in /home/ubuntu/convex-backend/)

# Copy docker-compose.yml
cp docker-compose.yml /opt/convex/

# Copy environment template
cp env.production.example /opt/convex/

# Copy all scripts
cp -r scripts/* /opt/convex/scripts/
chmod +x /opt/convex/scripts/*.sh

# Copy nginx configuration
cp -r nginx/* /opt/convex/nginx/

# Step 7: Verify files are copied
ls -la /opt/convex/
# You should now see: docker-compose.yml, env.production.example, scripts/, nginx/, data/

# Verify scripts are there
ls -la /opt/convex/scripts/
# Should show: generate-env.sh, setup-ec2.sh, setup-nginx.sh, etc.
```

### Step 3.3: Create `.env.production` File in `/opt/convex/` Directory

**CRITICAL:** The `.env.production` file MUST be created in `/opt/convex/` directory, NOT in your repository folder (`/home/ubuntu/convex-backend/`).

**Directory Structure:**
- **Repository:** `/home/ubuntu/convex-backend/` (where you cloned - don't create .env here!)
- **Deployment:** `/opt/convex/` (where everything runs - create .env here!)

```bash
# Navigate to /opt/convex/ (NOT your repository folder!)
cd /opt/convex

# Verify you're in the right directory
pwd
# Should show: /opt/convex
# NOT: /home/ubuntu/convex-backend

# List files to confirm
ls -la
# You should see: docker-compose.yml, env.production.example, scripts/, nginx/, data/
# If you don't see these files, go back to Step 3.2 and copy them!

# Method 1: Use the interactive script (RECOMMENDED)
chmod +x scripts/generate-env.sh
./scripts/generate-env.sh

# The script will ask you for:
# - Your domain (e.g., api.yourdomain.com)
# - Supabase PostgreSQL connection string
# - Supabase S3 Access Key ID
# - Supabase S3 Secret Access Key
# - Supabase S3 Endpoint
# - S3 Bucket name
# - S3 Region (default: us-east-1)
# - Action Worker Count (default: 8, but use 1 for t2.micro)

# After the script completes, it will show:
# "✅ Environment file created at /opt/convex/.env.production"
# "⚠️  Remember to keep this file secure and never commit it to git!"
```

**OR Method 2: Create manually**

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Copy the example file
cp env.production.example .env.production

# Edit the file with nano editor (Ubuntu default)
nano .env.production

# Nano editor instructions:
# 1. Use arrow keys to move cursor
# 2. Type to add/edit text
# 3. To save: Press Ctrl + O, then press Enter
# 4. To exit: Press Ctrl + X
# 5. If you see "Save modified buffer?" press Y then Enter
```

### Step 3.4: Fill in `.env.production` File Details

**How to Edit the File (Ubuntu):**

You have several options to edit the `.env.production` file:

**Option 1: Using nano (Easiest - Recommended for beginners)**

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Open the file with nano editor
nano .env.production

# Nano editor controls:
# - Use arrow keys to navigate
# - Type to edit text
# - Press Ctrl + O to save (then press Enter)
# - Press Ctrl + X to exit
# - Press Ctrl + K to delete a line
# - Press Ctrl + U to paste
```

**Option 2: Using vim (Advanced)**

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Open the file with vim editor
vim .env.production

# Vim editor controls:
# - Press 'i' to enter INSERT mode (you'll see -- INSERT -- at bottom)
# - Use arrow keys to navigate and type to edit
# - Press Esc to exit INSERT mode
# - Type ':wq' and press Enter to save and quit
# - Type ':q!' and press Enter to quit without saving
```

**Option 3: Using a text editor from your local machine**

```bash
# On your LOCAL machine, use VS Code with Remote SSH extension
# OR use WinSCP/FileZilla to download, edit, and upload the file
# OR use scp to copy file to local machine, edit, then copy back:
```

When editing `.env.production` in `/opt/convex/`, you need to fill in these values:

```env
# --- Core Configuration ---
NODE_ENV=production
CONVEX_DEPLOYMENT=production
# Note: docker-compose.yml maps CONVEX_INSTANCE_NAME to INSTANCE_NAME
CONVEX_INSTANCE_NAME=production-instance
CONVEX_INSTANCE_SECRET=<GENERATE_RANDOM_STRING>
# Generate random string: openssl rand -hex 32

# --- Public URLs ---
CONVEX_SITE_URL=https://api.yourdomain.com
CONVEX_CLOUD_ORIGIN=https://api.yourdomain.com
CONVEX_SITE_ORIGIN=https://api.yourdomain.com
# Replace 'api.yourdomain.com' with your actual domain

# --- Database (Supabase PostgreSQL) ---
# IMPORTANT: Use POSTGRES_URL (not DATABASE_URL) - DATABASE_URL is deprecated
# Do NOT include /DATABASE in the URL
# Convex will automatically use a database based on CONVEX_INSTANCE_NAME
# 
# For DIRECT connection (port 5432):
# POSTGRES_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432
# 
# For POOLER connection (port 6543) - RECOMMENDED for production:
# POSTGRES_URL=postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-1-ap-south-1.pooler.supabase.com:6543
# 
# If you get TLS certificate errors, add ?sslmode=require:
# POSTGRES_URL=postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-1-ap-south-1.pooler.supabase.com:6543?sslmode=require
# 
# Get connection string from: Supabase Dashboard → Settings → Database → Connection string
# Remove /postgres from the end
POSTGRES_URL=postgresql://USER:PASSWORD@HOST:PORT

# --- Action Compute ---
# ACTION_WORKER_COUNT controls how many Convex actions can run concurrently
# 
# What are Actions?
# - Actions are server-side functions that can call external APIs, make HTTP requests,
#   interact with third-party services, and perform non-deterministic operations
# - Examples: Sending emails, calling OpenAI API, webhooks, file processing
# - Actions run on port 3211 (HTTP actions endpoint)
#
# What does ACTION_WORKER_COUNT do?
# - Sets the number of worker processes/threads that handle action executions
# - Higher = more concurrent actions, but uses more CPU and memory
# - Lower = fewer concurrent actions, but uses less resources
#
# Recommended values:
ACTION_WORKER_COUNT=1
# For t2.micro: Use 1
# For t3.micro: Use 2-4
# For t3.small+: Use 4-8

# --- File Storage (Supabase S3-compatible) ---
AWS_ACCESS_KEY_ID=<YOUR_SUPABASE_S3_ACCESS_KEY>
AWS_SECRET_ACCESS_KEY=<YOUR_SUPABASE_S3_SECRET_KEY>
AWS_REGION=us-east-1
AWS_S3_ENDPOINT=https://<project-id>.supabase.co/storage/v1/s3
# Get this from Supabase Dashboard → Settings → API → Storage → S3 API
# Note: docker-compose.yml maps AWS_S3_ENDPOINT to S3_ENDPOINT_URL

# Convex requires 5 S3 buckets for different storage types
# You can use the same bucket name for all (simpler), or create separate buckets
# Create these buckets in Supabase Storage dashboard
S3_STORAGE_FILES_BUCKET=convex-files
S3_STORAGE_MODULES_BUCKET=convex-modules
S3_STORAGE_EXPORTS_BUCKET=convex-exports
S3_STORAGE_SNAPSHOT_IMPORTS_BUCKET=convex-snapshots
S3_STORAGE_SEARCH_BUCKET=convex-search

# OR use the same bucket for all (simpler - recommended):
# S3_STORAGE_FILES_BUCKET=convex-storage
# S3_STORAGE_MODULES_BUCKET=convex-storage
# S3_STORAGE_EXPORTS_BUCKET=convex-storage
# S3_STORAGE_SNAPSHOT_IMPORTS_BUCKET=convex-storage
# S3_STORAGE_SEARCH_BUCKET=convex-storage

# MAX_FILE_SIZE_BYTES: Maximum file size for Convex file storage (in bytes)
# Default: 104857600 = 100 MB
# Controls the maximum size of files that can be uploaded to Convex storage
# Files larger than this will be rejected
MAX_FILE_SIZE_BYTES=104857600

# --- Security ---
JWT_SIGNING_KEY=<GENERATE_RANDOM_STRING>
# Generate random string: openssl rand -hex 32
```

**How to get Supabase values:**

1. **PostgreSQL Connection String:**
   - Go to Supabase Dashboard
   - Settings → Database
   - Under "Connection string", you have two options:
   
   **Option A: Direct Connection (port 5432)**
   - Select "URI" tab
   - Copy the connection string
   - Format: `postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres`
   - **Remove `/postgres` and any `?sslmode=require`** 
   - Use: `postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432`
   
   **Option B: Pooler Connection (port 6543) - RECOMMENDED**
   - Select "Session mode" or "Transaction mode" tab
   - Copy the pooler connection string
   - Format: `postgresql://postgres.xxxxx:[PASSWORD]@aws-1-ap-south-1.pooler.supabase.com:6543/postgres`
   - **Remove `/postgres` at the end**
   - Use: `postgresql://postgres.xxxxx:[PASSWORD]@aws-1-ap-south-1.pooler.supabase.com:6543`
   - Pooler is better for production as it handles connection pooling
   
   **IMPORTANT:** Convex will automatically create/use a database based on your `CONVEX_INSTANCE_NAME` (e.g., `production-instance` becomes `production_instance` database)

2. **S3 Credentials:**
   - Go to Supabase Dashboard
   - Settings → API
   - Scroll to "Storage" section
   - Enable "S3 API" if not already enabled
   - Copy:
     - Access Key ID
     - Secret Access Key
     - S3 Endpoint (format: `https://xxxxx.supabase.co/storage/v1/s3`)

3. **S3 Buckets (Convex requires 5 buckets):**
   - Go to Supabase Dashboard → Storage
   - Create buckets (you can use the same name for all, or create separate ones):
     - `convex-files` (or `convex-storage` for all)
     - `convex-modules` (or same as above)
     - `convex-exports` (or same as above)
     - `convex-snapshots` (or same as above)
     - `convex-search` (or same as above)
   - Make buckets public if needed (or configure proper permissions)
   - Use bucket names in the S3_STORAGE_*_BUCKET variables
   - **Simpler option:** Create one bucket (e.g., `convex-storage`) and use it for all 5 variables

4. **Generate Random Strings (Ubuntu):**
   ```bash
   # Generate CONVEX_INSTANCE_SECRET (Ubuntu has openssl by default)
   openssl rand -hex 32
   
   # Generate JWT_SIGNING_KEY
   openssl rand -hex 32
   
   # If openssl is not installed (unlikely on Ubuntu 22.04):
   # sudo apt install -y openssl
   ```

### Step 3.5: Verify `.env.production` File

**After running `./scripts/generate-env.sh`, verify the credentials were added:**

```bash
# Make sure you're in /opt/convex/
cd /opt/convex

# Check file exists
ls -la .env.production
# Should show the file with permissions (should be readable only by you)

# View file contents (be careful, it contains secrets)
cat .env.production

# Verify all required variables are set (shows only non-comment lines)
grep -v "^#" .env.production | grep -v "^$"
# Should show all your environment variables with values

# Check specific important variables:
echo "=== Checking Key Variables ==="
grep "DATABASE_URL" .env.production
grep "AWS_ACCESS_KEY_ID" .env.production
grep "AWS_S3_ENDPOINT" .env.production
grep "CONVEX_CLOUD_ORIGIN" .env.production
grep "ACTION_WORKER_COUNT" .env.production

# Verify file permissions (should be 600 - readable/writable only by owner)
ls -l .env.production
# Should show: -rw------- (only you can read/write)
```

**What to look for:**

✅ **File exists:** `ls -la .env.production` shows the file  
✅ **Has content:** `cat .env.production` shows your values (not placeholders)  
✅ **All variables set:** No empty values or `<PLACEHOLDER>` text  
✅ **Correct format:** Each line is `VARIABLE_NAME=value` (no spaces around `=`)  
✅ **Secure permissions:** File is readable only by you (`-rw-------`)

**Common issues:**

❌ **File not found:** Make sure you're in `/opt/convex/` directory  
❌ **Empty values:** Re-run the script or edit manually  
❌ **Wrong permissions:** Run `chmod 600 .env.production` to secure it

---

## Phase 4: Initial Server Setup (If Not Done)

**For Ubuntu 22.04 LTS:**

If you haven't run the setup script yet:

```bash
# Navigate to your repository (where you cloned it)
cd ~/convex-backend
# Or wherever you cloned it

# Run the setup script (Ubuntu-specific)
chmod +x scripts/setup-ec2.sh
./scripts/setup-ec2.sh

# This will install (using apt package manager):
# - Docker (via apt)
# - Docker Compose (via apt)
# - Nginx (via apt)
# - Certbot (via apt)

# After setup, add yourself to docker group (if prompted)
newgrp docker
# OR logout and login again

# Verify Ubuntu version (should show 22.04)
lsb_release -a
```

### For t2.micro Instances: Run Optimization

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Run t2.micro optimization script
chmod +x scripts/setup-t2-micro.sh
./scripts/setup-t2-micro.sh

# This will:
# - Create 2GB swap space (REQUIRED for t2.micro)
# - Set ACTION_WORKER_COUNT=1 in .env.production
# - Show memory status
```

---

## Phase 5: Nginx Configuration

### Step 5.1: Update Nginx Configuration with Your Domain

**For Ubuntu:**

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Edit nginx configuration (Ubuntu comes with nano by default)
nano nginx/nginx.conf

# OR use vim if you prefer
# vim nginx/nginx.conf
```

**Find and replace `api.yourdomain.com` with your actual domain** in the file:

```nginx
# Find this line:
server_name api.yourdomain.com;

# Replace with your actual domain, e.g.:
server_name api.mysite.com;
```

**IMPORTANT:** The nginx.conf file is configured to work WITHOUT SSL certificates initially. After you set up SSL with certbot (Step 5.3), certbot will automatically update the configuration to add HTTPS support.

**After editing, SAVE the file:**
- In nano: Press `Ctrl + O`, then `Enter`, then `Ctrl + X`
- In vim: Press `Esc`, type `:wq`, then `Enter`

### Step 5.2: Copy Nginx Configuration to System

**For Ubuntu (uses systemd and /etc/nginx structure):**

```bash
# Copy nginx config to system directory (Ubuntu standard location)
sudo cp /opt/convex/nginx/nginx.conf /etc/nginx/sites-available/convex

# Create symbolic link to enable the site (Ubuntu standard)
sudo ln -s /etc/nginx/sites-available/convex /etc/nginx/sites-enabled/

# Remove default nginx site (if it exists)
sudo rm /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t
# Should show: "syntax is ok" and "test is successful"

# Reload nginx (Ubuntu uses systemd)
sudo systemctl reload nginx

# OR restart nginx service
sudo systemctl restart nginx

# Check nginx status (Ubuntu)
sudo systemctl status nginx
```

### Step 5.3: Set Up SSL Certificate (Let's Encrypt)

**IMPORTANT:** 
1. Your domain DNS must point to your EC2 instance IP before running this
2. Nginx must be running and accessible on port 80
3. The nginx.conf should work without SSL first (which it does)

**For Ubuntu:**

```bash
# Update package list (Ubuntu)
sudo apt update

# Install certbot if not already installed (Ubuntu)
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate (replace with your actual domain)
sudo certbot --nginx -d api.yourdomain.com

# Follow the prompts:
# - Enter your email
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)

# Certbot will automatically:
# - Create SSL certificates
# - Update nginx.conf to add HTTPS server block
# - Configure automatic redirects

# Verify certificate
sudo certbot certificates

# Check certbot service status (Ubuntu uses systemd)
sudo systemctl status certbot.timer

# Test nginx configuration after certbot changes
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

**Note:** If you get an error about missing SSL certificates before running certbot, that's normal. The nginx.conf is set up to work on HTTP (port 80) first, then certbot will add HTTPS (port 443) automatically.

---

## Phase 6: Initial Deployment

### Step 6.1: Verify Everything is Ready

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Verify files exist
ls -la
# Should see: docker-compose.yml, .env.production, scripts/, nginx/, data/

# Verify .env.production exists and has content
cat .env.production | grep -v "^#" | grep -v "^$"
# Should show your environment variables

# Check if Docker is installed
docker --version
# Should show Docker version

# Check if Docker service is running
sudo systemctl status docker
# Should show "active (running)"

# If Docker is not running, start it:
sudo systemctl start docker
sudo systemctl enable docker

# Verify docker is running
docker ps
# Should show running containers or empty list (both are OK)

# Check Docker Compose
docker compose version
# OR (if above doesn't work):
docker-compose --version

# If Docker Compose is not installed, install it:
# sudo apt install -y docker-compose-plugin
# OR
# sudo apt install -y docker-compose

# Verify you're in docker group
groups
# Should include 'docker'
# If not, run: sudo usermod -aG docker $USER && newgrp docker
```

### Step 6.2: Install/Check Docker Compose and Pull Docker Images

**First, check if Docker Compose is installed:**

```bash
# Check Docker Compose version
docker compose version
# OR try the older syntax:
docker-compose --version

# If neither works, install Docker Compose:
```

**If Docker Compose is NOT installed, install it:**

```bash
# Option 1: Install Docker Compose plugin (recommended for Ubuntu 22.04)
sudo apt update
sudo apt install -y docker-compose-plugin

# Option 2: Install standalone docker-compose (if plugin doesn't work)
sudo apt install -y docker-compose

# Verify installation
docker compose version
# OR
docker-compose --version
```

**Then pull Docker images:**

```bash
# Make sure you're in /opt/convex/
cd /opt/convex

# Pull latest Docker images (use the command that works)
docker compose pull
# OR if above doesn't work:
docker-compose pull

# This will download:
# - ghcr.io/get-convex/convex-backend:latest
# - ghcr.io/get-convex/convex-dashboard:latest
```

### Step 6.3: Start Services

```bash
# Make sure you're in /opt/convex/
cd /opt/convex

# Make sure you have the latest docker-compose.yml
# If you updated it in the repository, copy it:
# cp /home/ubuntu/convex-backend/docker-compose.yml /opt/convex/

# Verify .env.production exists (docker-compose.yml reads from it)
ls -la .env.production
# Should exist

# Start all services (use the command that works for you)
docker compose up -d
# OR if above doesn't work:
docker-compose up -d

# The -d flag runs in detached mode (background)
# docker-compose.yml will:
# - Read environment variables from .env.production
# - Map CONVEX_INSTANCE_NAME → INSTANCE_NAME
# - Map CONVEX_INSTANCE_SECRET → INSTANCE_SECRET
# - Map AWS_S3_ENDPOINT → S3_ENDPOINT_URL
# - Use named volume 'data' for storage

# Check if containers are running
docker compose ps
# OR
docker-compose ps

# Should show:
# - convex-backend (running, then "healthy" after ~10-30 seconds)
# - convex-dashboard (running after backend is healthy)

# Test backend health (uses /version endpoint)
curl http://localhost:3210/version
# Should return version information
```

### Step 6.4: Check Logs and Troubleshoot

```bash
# View backend logs
docker compose logs backend

# View dashboard logs
docker compose logs dashboard

# Follow logs in real-time
docker compose logs -f backend

# Check container status
docker compose ps
# Should show all containers as "Up" and "healthy"

# If you see errors, check:
# 1. .env.production file is correct
# 2. Database connection is working
# 3. S3 credentials are correct
# 4. CONVEX_CLOUD_ORIGIN is set in .env.production
```

### Step 6.4a: Fix "CONVEX_CLOUD_ORIGIN variable is not set" Error

**This means the environment variable is missing from .env.production:**

```bash
# Navigate to /opt/convex/
cd /opt/convex

# Check if .env.production exists
ls -la .env.production

# View the file and check for CONVEX_CLOUD_ORIGIN
cat .env.production | grep CONVEX_CLOUD_ORIGIN

# If it's missing or empty, edit the file:
nano .env.production

# Make sure you have this line (replace with your actual domain):
CONVEX_CLOUD_ORIGIN=https://sync.koanpay.com
CONVEX_SITE_URL=https://sync.koanpay.com
CONVEX_SITE_ORIGIN=https://sync.koanpay.com

# SAVE: Ctrl+O, Enter, Ctrl+X

# Verify the variable is set
grep CONVEX_CLOUD_ORIGIN .env.production
# Should show: CONVEX_CLOUD_ORIGIN=https://sync.koanpay.com

# Restart containers
docker compose down
docker compose up -d
```

### Step 6.4b: Fix "Dashboard container is unhealthy" Error

**This usually means the backend isn't ready yet or there's a configuration issue:**

```bash
# Step 1: Check backend status first
docker compose ps
# Backend should show "healthy" status before dashboard can start

# Step 2: Check backend logs for errors
docker compose logs backend | tail -50

# Step 3: Test backend health endpoint
curl http://localhost:3210/health
# Should return success (200 OK)

# Step 4: If backend is not healthy, check for common issues:
# - Database connection errors
# - Missing environment variables
# - Port conflicts

# Step 5: Check dashboard logs
docker compose logs dashboard | tail -50

# Step 6: Common fixes:

# Fix 1: Restart everything and wait
docker compose down
docker compose up -d

# Wait for backend to become healthy (30-60 seconds)
echo "Waiting for backend to be healthy..."
sleep 45
docker compose ps

# Fix 2: If backend is healthy but dashboard isn't, check dashboard logs
docker compose logs dashboard

# Fix 3: Check if .env.production is being read correctly
docker compose config | grep CONVEX_CLOUD_ORIGIN
# Should show your domain

# Fix 4: Verify file permissions
ls -l /opt/convex/.env.production
# Should be readable (not permission denied)

# Fix 5: If dashboard keeps failing, try starting backend first, then dashboard
docker compose up -d backend
# Wait for backend to be healthy
sleep 30
docker compose ps backend
# Should show "healthy"
# Then start dashboard
docker compose up -d dashboard
```

### Step 6.5: Generate Admin Key

```bash
# Wait for backend to be healthy first
docker compose ps backend
# Should show "healthy" status

# Generate admin key (first time only)
docker compose exec backend ./generate_admin_key.sh

# Save the output! It will look like:
# instance|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Save it to a file
docker compose exec backend ./generate_admin_key.sh > /opt/convex/admin_key.txt

# View the admin key
cat /opt/convex/admin_key.txt

# IMPORTANT: Save this key securely! You'll need it for:
# - Convex CLI authentication
# - Dashboard access
```

**Note:** The docker-compose.yml uses:
- **env_file**: Reads all variables from `.env.production`
- **Variable mapping**: Automatically maps your variable names:
  - `CONVEX_INSTANCE_NAME` → `INSTANCE_NAME`
  - `CONVEX_INSTANCE_SECRET` → `INSTANCE_SECRET`
  - `AWS_S3_ENDPOINT` → `S3_ENDPOINT_URL`
- **Named volume**: Uses `data` volume (managed by Docker) instead of `./data` directory
- **Healthcheck**: Uses `/version` endpoint (faster startup)

---

## Phase 7: Verify Deployment

### Step 7.1: Check Service Health

```bash
# Check container status
cd /opt/convex
docker compose ps

# All services should show "Up" status

# Check resource usage
docker stats

# For t2.micro, monitor memory usage closely
```

### Step 7.2: Test API Endpoints

```bash
# Test backend version endpoint (used by healthcheck)
curl http://localhost:3210/version
# Should return version information

# Test backend health endpoint
curl http://localhost:3210/health
# Should return health status

# Test from outside (replace with your domain)
curl https://sync.koanpay.com/version
curl https://sync.koanpay.com/health

# Test dashboard (replace with your domain)
curl https://sync.koanpay.com/dashboard/
```

### Step 7.3: Access Dashboard

Open in your browser:
- **Dashboard**: `https://api.yourdomain.com/dashboard/`
- **API**: `https://api.yourdomain.com/`
- **HTTP Actions**: `https://api.yourdomain.com/actions/`

---

## Phase 8: GitHub Actions Setup (Optional - For CI/CD)

### Step 8.1: Generate SSH Key for GitHub Actions

```bash
# On your LOCAL machine (not EC2)
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/ec2_deploy_key

# Copy public key to EC2
ssh-copy-id -i ~/.ssh/ec2_deploy_key.pub ubuntu@YOUR_EC2_IP

# View private key to add to GitHub
cat ~/.ssh/ec2_deploy_key
# Copy the entire output
```

### Step 8.2: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

   - **Name**: `EC2_HOST`
     - **Value**: Your EC2 public IP or domain (e.g., `ec2-xx-xx-xx-xx.compute-1.amazonaws.com`)

   - **Name**: `EC2_USER`
     - **Value**: `ubuntu` (or your EC2 username)

   - **Name**: `EC2_SSH_KEY`
     - **Value**: The entire content of `~/.ssh/ec2_deploy_key` (the private key)

### Step 8.3: Push to Trigger Deployment

```bash
# On your local machine, in your repository
git add .
git commit -m "Initial deployment setup"
git push origin main

# GitHub Actions will automatically:
# - Copy docker-compose.yml to /opt/convex/
# - Pull latest images
# - Restart containers
```

---

## Directory Structure Reference

### On Your EC2 Instance:

```
/home/ubuntu/
 └── convex-backend/              # Your cloned repository (source files)
     ├── docker-compose.yml
     ├── env.production.example
     ├── scripts/
     ├── nginx/
     └── .github/
     # ⚠️ DO NOT create .env.production here!

/opt/convex/                      # DEPLOYMENT DIRECTORY (where everything runs)
 ├── docker-compose.yml           # ← Copied from /home/ubuntu/convex-backend/
 ├── .env.production              # ← YOU CREATE THIS FILE HERE (not in repository!)
 ├── env.production.example       # ← Copied from /home/ubuntu/convex-backend/
 ├── admin_key.txt                # ← Generated after first run
 ├── scripts/                     # ← Copied from /home/ubuntu/convex-backend/
 │   ├── setup-ec2.sh
 │   ├── generate-env.sh
 │   ├── setup-nginx.sh
 │   └── setup-t2-micro.sh
 ├── nginx/                       # ← Copied from /home/ubuntu/convex-backend/
 │   └── nginx.conf
 └── data/                        # ← Created automatically
     └── (Docker volumes stored here)
```

**IMPORTANT:** 
- **Repository location:** `/home/ubuntu/convex-backend/` (where you cloned - source files)
- **Deployment location:** `/opt/convex/` (where everything runs - you need to CREATE this!)
- **The `.env.production` file MUST be in `/opt/convex/` directory, NOT in the repository**

**If `/opt/convex/` doesn't exist, you need to:**
1. Create it: `sudo mkdir -p /opt/convex`
2. Copy files from repository: `cp -r /home/ubuntu/convex-backend/* /opt/convex/` (selectively)
3. Then create `.env.production` in `/opt/convex/`

---

## Common Commands Reference (Ubuntu)

```bash
# Navigate to deployment directory
cd /opt/convex

# View running containers
docker compose ps

# View logs
docker compose logs -f backend
docker compose logs -f dashboard

# Restart services
docker compose restart

# Stop services
docker compose down

# Start services
docker compose up -d

# Update and restart
docker compose pull
docker compose up -d

# Check environment variables
cat .env.production

# Verify Docker Compose reads environment correctly
docker compose config | grep -E "INSTANCE_NAME|POSTGRES_URL|S3_ENDPOINT"

# Test backend endpoints
curl http://localhost:3210/version
curl http://localhost:3210/health

# Check Docker volumes (data is stored in named volume)
docker volume ls
docker volume inspect convex-backend_data

# Check nginx status (Ubuntu systemd)
sudo systemctl status nginx
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl restart nginx

# Check disk space (Ubuntu)
df -h

# Check memory usage (Ubuntu)
free -h

# Check Docker resource usage
docker stats

# Check Ubuntu system info
lsb_release -a
uname -a

# Check running services (Ubuntu)
sudo systemctl list-units --type=service --state=running

# Check Docker service (Ubuntu)
sudo systemctl status docker
```

---

## Troubleshooting

### Problem: "Cannot access scripts/generate-env.sh"

**Solution:** You're in the wrong directory. The scripts are in `/opt/convex/scripts/`:

```bash
# Make sure you're in /opt/convex/ (not /home/ubuntu/convex-backend/)
cd /opt/convex

# Verify you're in the right place
pwd
# Should show: /opt/convex

# Check if scripts exist
ls -la scripts/
# Should show: generate-env.sh, setup-ec2.sh, etc.

# If scripts don't exist, copy them from repository:
# cp -r /home/ubuntu/convex-backend/scripts/* /opt/convex/scripts/
# chmod +x /opt/convex/scripts/*.sh

# Then run the script
./scripts/generate-env.sh
```

### Problem: "/opt/convex/ directory doesn't exist"

**Solution:** You need to create it and copy files:

```bash
# Create the directory
sudo mkdir -p /opt/convex
sudo mkdir -p /opt/convex/scripts
sudo mkdir -p /opt/convex/data
sudo mkdir -p /opt/convex/nginx

# Change ownership
sudo chown -R $USER:$USER /opt/convex

# Copy files from your repository
cd /home/ubuntu/convex-backend
cp docker-compose.yml /opt/convex/
cp env.production.example /opt/convex/
cp -r scripts/* /opt/convex/scripts/
cp -r nginx/* /opt/convex/nginx/
chmod +x /opt/convex/scripts/*.sh

# Verify
ls -la /opt/convex/
```

### Problem: ".env.production not found"

**Solution:** Create it in `/opt/convex/` directory:

```bash
cd /opt/convex
cp env.production.example .env.production
nano .env.production
```

### Problem: "Permission denied" when running docker commands

**Solution (Ubuntu):** Add yourself to docker group:

```bash
# Add your user to docker group (Ubuntu)
sudo usermod -aG docker $USER

# Apply changes immediately
newgrp docker

# OR logout and login again via SSH
# Verify you're in docker group
groups
# Should show 'docker' in the list
```

### Problem: "docker compose: unknown command" or "docker-compose: command not found"

**Solution:** Install Docker Compose:

```bash
# Check if Docker is installed first
docker --version
# If not installed, run: sudo apt install -y docker.io

# Check Docker service
sudo systemctl status docker
# If not running, start it: sudo systemctl start docker

# Install Docker Compose plugin (Ubuntu 22.04)
sudo apt update
sudo apt install -y docker-compose-plugin

# Verify installation
docker compose version

# If plugin doesn't work, install standalone version:
sudo apt install -y docker-compose
docker-compose --version

# Use whichever command works:
# docker compose (newer, plugin version)
# OR
# docker-compose (older, standalone version)
```

### Problem: Environment variables not being read

**Solution:** Check docker-compose.yml configuration:

```bash
# Verify .env.production exists
ls -la /opt/convex/.env.production

# Check if docker-compose.yml has env_file
grep "env_file" /opt/convex/docker-compose.yml
# Should show: env_file: - .env.production

# Verify variables are being read
docker compose config | grep -E "INSTANCE_NAME|POSTGRES_URL|S3_ENDPOINT"
# Should show your values

# If variables are missing, check variable name mapping:
# - CONVEX_INSTANCE_NAME → INSTANCE_NAME
# - AWS_S3_ENDPOINT → S3_ENDPOINT_URL
```

### Problem: Containers won't start

**Solution:** Check logs and environment:

```bash
cd /opt/convex
docker compose logs backend
docker compose config
cat .env.production
```

### Problem: Database connection fails

**Solution:** 
1. Verify `DATABASE_URL` in `/opt/convex/.env.production`
2. Check Supabase connection string format
3. Ensure EC2 IP is whitelisted in Supabase (if required)

### Problem: Out of memory (t2.micro)

**Solution (Ubuntu):** Enable swap space:

```bash
# Create 2GB swap file (Ubuntu)
sudo fallocate -l 2G /swapfile

# Set correct permissions
sudo chmod 600 /swapfile

# Format as swap
sudo mkswap /swapfile

# Enable swap
sudo swapon /swapfile

# Make it permanent (add to /etc/fstab)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify swap is active (Ubuntu)
free -h
# Should show swap with ~2GB

# Check swap status
swapon --show
```

---

## Next Steps After Deployment

1. ✅ Save your admin key securely
2. ✅ Test API endpoints
3. ✅ Access dashboard
4. ✅ Configure Convex CLI on your local machine
5. ✅ Set up GitHub Actions for automated deployments

---

## Support

For issues:
- Check logs: `docker compose logs -f`
- Verify environment: `cat /opt/convex/.env.production`
- Check container status: `docker compose ps`
- Review this guide step-by-step
