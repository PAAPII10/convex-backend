#!/bin/bash
set -e

echo "=== Nginx Configuration Setup ==="

DOMAIN=${1:-"api.yourdomain.com"}
NGINX_CONF="/etc/nginx/sites-available/convex"
NGINX_ENABLED="/etc/nginx/sites-enabled/convex"

if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Copy nginx configuration
if [ -f "./nginx/nginx.conf" ]; then
    cp ./nginx/nginx.conf "$NGINX_CONF"
    # Replace placeholder domain
    sed -i "s/api.yourdomain.com/${DOMAIN}/g" "$NGINX_CONF"
else
    echo "Error: nginx.conf not found in ./nginx/"
    exit 1
fi

# Remove default nginx site if exists
if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# Enable Convex site
if [ -L "$NGINX_ENABLED" ]; then
    rm "$NGINX_ENABLED"
fi
ln -s "$NGINX_CONF" "$NGINX_ENABLED"

# Test nginx configuration
nginx -t

# Setup SSL with certbot
echo ""
read -p "Do you want to set up SSL with Let's Encrypt? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email admin@${DOMAIN#*.} || {
        echo "Certbot setup failed. You may need to:"
        echo "1. Point your domain DNS to this server's IP"
        echo "2. Run: sudo certbot --nginx -d $DOMAIN"
    }
fi

# Reload nginx
systemctl reload nginx

echo "✅ Nginx configured successfully!"
echo "Configuration file: $NGINX_CONF"
