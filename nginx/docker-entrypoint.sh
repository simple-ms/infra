#!/bin/sh
set -e

echo "🚀 Starting Nginx with environment variable substitution..."

# List of environment variables to substitute
ENV_VARS='${AUTH_SERVICE_HOST} ${AUTH_SERVICE_PORT} ${USER_SERVICE_HOST} ${USER_SERVICE_PORT} ${PRODUCT_SERVICE_HOST} ${PRODUCT_SERVICE_PORT} ${ORDER_SERVICE_HOST} ${ORDER_SERVICE_PORT} ${PAYMENT_SERVICE_HOST} ${PAYMENT_SERVICE_PORT} ${CORS_ORIGIN} ${RATE_LIMIT_AUTH} ${RATE_LIMIT_API} ${RATE_LIMIT_STRICT} ${RATE_LIMIT_AUTH_BURST} ${RATE_LIMIT_API_BURST} ${RATE_LIMIT_STRICT_BURST} ${CLIENT_MAX_BODY_SIZE} ${CLIENT_BODY_TIMEOUT} ${CLIENT_HEADER_TIMEOUT} ${SEND_TIMEOUT} ${PROXY_CONNECT_TIMEOUT} ${PROXY_SEND_TIMEOUT} ${PROXY_READ_TIMEOUT} ${GZIP_COMP_LEVEL} ${GZIP_MIN_LENGTH} ${KEEPALIVE_TIMEOUT} ${KEEPALIVE_REQUESTS} ${WORKER_CONNECTIONS} ${ERROR_LOG_LEVEL}'

# Substitute environment variables in upstreams template
if [ -f /etc/nginx/upstreams.conf.template ]; then
    echo "📝 Generating upstreams.conf from template..."
    envsubst "$ENV_VARS" < /etc/nginx/upstreams.conf.template > /etc/nginx/upstreams.conf
else
    echo "⚠️  Warning: upstreams.conf.template not found, using existing upstreams.conf"
fi

# Substitute environment variables in CORS config if it's a template
if [ -f /etc/nginx/cors.conf.template ]; then
    echo "📝 Generating cors.conf from template..."
    envsubst "$ENV_VARS" < /etc/nginx/cors.conf.template > /etc/nginx/cors.conf
fi

# Substitute environment variables in performance config if it's a template
if [ -f /etc/nginx/performance.conf.template ]; then
    echo "📝 Generating performance.conf from template..."
    envsubst "$ENV_VARS" < /etc/nginx/performance.conf.template > /etc/nginx/performance.conf
fi

# Substitute environment variables in timeouts config if it's a template
if [ -f /etc/nginx/timeouts.conf.template ]; then
    echo "📝 Generating timeouts.conf from template..."
    envsubst "$ENV_VARS" < /etc/nginx/timeouts.conf.template > /etc/nginx/timeouts.conf
fi

# Test nginx configuration
echo "🔍 Testing nginx configuration..."
nginx -t

# Start nginx
echo "✅ Starting nginx..."
exec nginx -g 'daemon off;'
