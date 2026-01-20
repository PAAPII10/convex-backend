#!/bin/bash
set -e

# Script to help generate .env.production file
# For Ubuntu 22.04 LTS

ENV_FILE="/opt/convex/.env.production"
ENV_DIR="/opt/convex"

# Check if /opt/convex directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo "❌ Error: /opt/convex/ directory does not exist!"
    echo ""
    echo "Please create it first:"
    echo "  sudo mkdir -p /opt/convex"
    echo "  sudo chown -R \$USER:\$USER /opt/convex"
    echo ""
    echo "Then copy files from your repository:"
    echo "  cp docker-compose.yml /opt/convex/"
    echo "  cp -r scripts/* /opt/convex/scripts/"
    exit 1
fi

# Check if we're in the right directory context
if [ ! -f "$ENV_DIR/docker-compose.yml" ]; then
    echo "⚠️  Warning: docker-compose.yml not found in /opt/convex/"
    echo "Make sure you've copied files from your repository to /opt/convex/"
fi

if [ -f "$ENV_FILE" ]; then
    read -p ".env.production already exists. Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

echo "=== Convex Backend Environment Configuration ==="
echo ""

# Generate random secrets
INSTANCE_SECRET=$(openssl rand -hex 32)
JWT_KEY=$(openssl rand -hex 32)

read -p "Enter your domain (e.g., api.yourdomain.com): " DOMAIN
read -p "Enter Supabase PostgreSQL connection string (remove /postgres at end): " DB_URL
echo "Note: If you get TLS errors, add ?sslmode=require to the connection string"
read -p "Enter Supabase S3 Access Key ID: " S3_ACCESS_KEY
read -p "Enter Supabase S3 Secret Access Key: " S3_SECRET_KEY
read -p "Enter Supabase S3 Endpoint (e.g., https://xxx.supabase.co/storage/v1/s3): " S3_ENDPOINT
read -p "Enter S3 Region (default: us-east-1): " S3_REGION
S3_REGION=${S3_REGION:-us-east-1}

echo ""
echo "Convex requires 5 S3 buckets. You can:"
echo "  1. Use the same bucket name for all (simpler)"
echo "  2. Use different bucket names for each type"
read -p "Enter base bucket name (will be used for all 5 buckets, or press Enter to set individually): " S3_BASE_BUCKET

if [ -z "$S3_BASE_BUCKET" ]; then
    read -p "Enter S3 bucket for files: " S3_FILES_BUCKET
    read -p "Enter S3 bucket for modules: " S3_MODULES_BUCKET
    read -p "Enter S3 bucket for exports: " S3_EXPORTS_BUCKET
    read -p "Enter S3 bucket for snapshots: " S3_SNAPSHOTS_BUCKET
    read -p "Enter S3 bucket for search: " S3_SEARCH_BUCKET
else
    S3_FILES_BUCKET=$S3_BASE_BUCKET
    S3_MODULES_BUCKET=$S3_BASE_BUCKET
    S3_EXPORTS_BUCKET=$S3_BASE_BUCKET
    S3_SNAPSHOTS_BUCKET=$S3_BASE_BUCKET
    S3_SEARCH_BUCKET=$S3_BASE_BUCKET
fi

read -p "Enter Action Worker Count (default: 8): " WORKER_COUNT
WORKER_COUNT=${WORKER_COUNT:-8}

read -p "Enter Max File Size in Bytes (default: 104857600 = 100MB): " MAX_FILE_SIZE
MAX_FILE_SIZE=${MAX_FILE_SIZE:-104857600}

cat > "$ENV_FILE" << EOF
# --- Core Configuration ---
NODE_ENV=production
CONVEX_DEPLOYMENT=production
CONVEX_INSTANCE_NAME=production-instance
CONVEX_INSTANCE_SECRET=${INSTANCE_SECRET}

# --- Public URLs ---
CONVEX_SITE_URL=https://${DOMAIN}
CONVEX_CLOUD_ORIGIN=https://${DOMAIN}
CONVEX_SITE_ORIGIN=https://${DOMAIN}

# --- Database (Supabase PostgreSQL) ---
# Use POSTGRES_URL (DATABASE_URL is deprecated)
# If you get TLS certificate errors, add ?sslmode=require to the connection string
POSTGRES_URL=${DB_URL}

# --- Action Compute ---
ACTION_WORKER_COUNT=${WORKER_COUNT}

# --- File Storage (Supabase S3-compatible) ---
AWS_ACCESS_KEY_ID=${S3_ACCESS_KEY}
AWS_SECRET_ACCESS_KEY=${S3_SECRET_KEY}
AWS_REGION=${S3_REGION}
AWS_S3_ENDPOINT=${S3_ENDPOINT}

# Convex requires 5 S3 buckets for different storage types
S3_STORAGE_FILES_BUCKET=${S3_FILES_BUCKET}
S3_STORAGE_MODULES_BUCKET=${S3_MODULES_BUCKET}
S3_STORAGE_EXPORTS_BUCKET=${S3_EXPORTS_BUCKET}
S3_STORAGE_SNAPSHOT_IMPORTS_BUCKET=${S3_SNAPSHOTS_BUCKET}
S3_STORAGE_SEARCH_BUCKET=${S3_SEARCH_BUCKET}

MAX_FILE_SIZE_BYTES=${MAX_FILE_SIZE}

# --- Security ---
JWT_SIGNING_KEY=${JWT_KEY}

# --- Vector Search (Optional) ---
# VECTOR_EMBEDDING_PROVIDER=openai
# OPENAI_API_KEY=your-openai-api-key
EOF

chmod 600 "$ENV_FILE"
echo ""
echo "✅ Environment file created at $ENV_FILE"
echo "⚠️  Remember to keep this file secure and never commit it to git!"
echo ""
echo "Next steps:"
echo "  1. Verify the file: cat $ENV_FILE"
echo "  2. Check key variables: grep -E '^(DATABASE_URL|AWS_ACCESS_KEY_ID|CONVEX_CLOUD_ORIGIN)=' $ENV_FILE"
echo "  3. Continue with Nginx setup and deployment"
