#!/bin/bash
set -e

# Script to help generate .env.production file

ENV_FILE="/opt/convex/.env.production"

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
read -p "Enter Supabase PostgreSQL connection string: " DB_URL
read -p "Enter Supabase S3 Access Key ID: " S3_ACCESS_KEY
read -p "Enter Supabase S3 Secret Access Key: " S3_SECRET_KEY
read -p "Enter Supabase S3 Endpoint (e.g., https://xxx.supabase.co/storage/v1/s3): " S3_ENDPOINT
read -p "Enter S3 Bucket name: " S3_BUCKET
read -p "Enter S3 Region (default: us-east-1): " S3_REGION
S3_REGION=${S3_REGION:-us-east-1}

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
DATABASE_URL=${DB_URL}

# --- Action Compute ---
ACTION_WORKER_COUNT=${WORKER_COUNT}

# --- File Storage (Supabase S3-compatible) ---
AWS_ACCESS_KEY_ID=${S3_ACCESS_KEY}
AWS_SECRET_ACCESS_KEY=${S3_SECRET_KEY}
AWS_REGION=${S3_REGION}
AWS_S3_ENDPOINT=${S3_ENDPOINT}
AWS_S3_BUCKET=${S3_BUCKET}
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
