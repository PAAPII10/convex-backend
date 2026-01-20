#!/bin/bash
# Generate instance secret for Convex self-hosted instance
# This secret is used for encryption/identity

echo "Generating Convex instance secret..."
INSTANCE_SECRET=$(openssl rand -hex 32)
echo ""
echo "=========================================="
echo "INSTANCE SECRET: $INSTANCE_SECRET"
echo "=========================================="
echo ""
echo "Add this to your .env file:"
echo "INSTANCE_SECRET=$INSTANCE_SECRET"
echo ""
echo "Keep this secret secure and do not commit it to version control!"
