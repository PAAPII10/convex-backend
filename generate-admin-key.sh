#!/bin/bash
# Generate admin key for Convex self-hosted instance
# This key is used for dashboard login and convex dev commands

echo "Generating Convex admin key..."
ADMIN_KEY=$(openssl rand -hex 32)
echo ""
echo "=========================================="
echo "ADMIN KEY: $ADMIN_KEY"
echo "=========================================="
echo ""
echo "Add this to your .env file:"
echo "CONVEX_SELF_HOSTED_ADMIN_KEY=$ADMIN_KEY"
echo ""
echo "Keep this key secure and do not commit it to version control!"
