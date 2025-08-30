#!/bin/sh

# Extract the port from nginx configuration
NGINX_PORT=$(grep -r "listen" /etc/nginx/conf.d/ /etc/nginx/nginx.conf 2>/dev/null | \
    grep -v "#" | \
    grep -o "[0-9]\+" | \
    head -1)

# Default to 8080 if no port found
if [ -z "$NGINX_PORT" ]; then
    NGINX_PORT=8080
fi

echo
echo "🌐 Nginx server available at: http://localhost:$NGINX_PORT"
echo