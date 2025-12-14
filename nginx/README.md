# Nginx Configuration

Production-ready nginx configuration with environment variables for Kubernetes deployment.

## Quick Start

### 1. Environment Variables

Copy the example file and customize:
```bash
cp .env.example .env
# Edit .env with your values
```

### 2. Start Services

```bash
cd ../
docker-compose up -d nginx-gateway
```

### 3. Test Configuration

```bash
# Test rate limiting
for i in {1..25}; do curl http://localhost/auth/health; done

# Test compression
curl -H "Accept-Encoding: gzip" http://localhost/products -I | grep "Content-Encoding"

# Test all services
curl http://localhost/auth/health
curl http://localhost/user/health
curl http://localhost/product/health
curl http://localhost/order/health
curl http://localhost/payment/health
```

## Configuration Files

```
nginx/
├── .env.example              # Environment variables template
├── nginx.conf                # Main configuration
├── logging.conf              # JSON logging
├── security.conf             # Security headers
├── performance.conf          # Rate limiting + compression
├── timeouts.conf             # Timeout settings
├── cors.conf                 # CORS configuration
├── upstreams.conf.template   # Service upstreams (template)
├── errors.conf               # Error handling
├── docker-entrypoint.sh      # Env var substitution script
└── services/
    ├── auth.conf             # Auth service routes
    ├── user.conf             # User service routes
    ├── product.conf          # Product service routes
    ├── order.conf            # Order service routes
    └── payment.conf          # Payment service routes
```

## Environment Variables

See `.env.example` for all available variables.

### Key Variables

**Service Discovery:**
```bash
AUTH_SERVICE_HOST=auth-api          # Docker: service name
AUTH_SERVICE_PORT=8000              # K8s: auth-service.default.svc.cluster.local
```

**Rate Limiting:**
```bash
RATE_LIMIT_AUTH=10r/s               # Auth endpoints (prevent brute force)
RATE_LIMIT_API=100r/s               # General API
RATE_LIMIT_STRICT=50r/s             # Payments/Orders
```

**Performance:**
```bash
GZIP_COMP_LEVEL=6                   # Compression level (1-9)
CLIENT_MAX_BODY_SIZE=10M            # Max request size
```

## Features

### ✅ Security
- Rate limiting (10 req/s for auth, 100 req/s for API)
- Request size limits (10MB max)
- Connection limits
- Security headers (XSS, clickjacking protection)
- Proper timeouts

### ✅ Performance
- Gzip compression (6x smaller responses)
- Keepalive connections
- Proxy buffering
- Optimized timeouts

### ✅ Kubernetes Ready
- Environment variables for all services
- No hardcoded values
- Same config for dev/staging/prod
- Service discovery via env vars

### ✅ Observability
- JSON logging (ELK/Splunk ready)
- Structured logs with timing
- Health check endpoints

## Kubernetes Deployment

### 1. Create ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-env
data:
  AUTH_SERVICE_HOST: "auth-service"
  AUTH_SERVICE_PORT: "8000"
  USER_SERVICE_HOST: "user-service"
  USER_SERVICE_PORT: "8000"
  # ... etc
```

### 2. Update Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-gateway
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        envFrom:
        - configMapRef:
            name: nginx-env
```

### 3. Deploy

```bash
kubectl apply -f k8s/nginx-configmap.yaml
kubectl apply -f k8s/nginx-deployment.yaml
```

## Testing

### Rate Limiting Test

```bash
# Should get 429 after 10 requests
for i in {1..15}; do 
  curl -w "%{http_code}\n" http://localhost/auth/login -d '{}' -H "Content-Type: application/json"
done
```

### Compression Test

```bash
# Should see "Content-Encoding: gzip"
curl -H "Accept-Encoding: gzip" http://localhost/products -I
```

### Health Checks

```bash
# All should return 200
curl http://localhost/auth/health
curl http://localhost/user/health
curl http://localhost/product/health
curl http://localhost/order/health
curl http://localhost/payment/health
```

## Troubleshooting

### Check nginx logs
```bash
docker-compose logs nginx-gateway
```

### Test configuration
```bash
docker-compose exec nginx-gateway nginx -t
```

### Reload configuration
```bash
docker-compose exec nginx-gateway nginx -s reload
```

### View generated upstreams
```bash
docker-compose exec nginx-gateway cat /etc/nginx/upstreams.conf
```

## Production Checklist

- [ ] Set proper `CORS_ORIGIN` for production domain
- [ ] Adjust rate limits based on traffic
- [ ] Configure SSL/TLS (if not using load balancer)
- [ ] Set up monitoring/alerting
- [ ] Test failover scenarios
- [ ] Review security headers
- [ ] Enable access logs aggregation

## Migration Notes

**From Docker Compose to Kubernetes:**
1. No code changes needed
2. Just update environment variables
3. Use K8s service DNS names
4. Deploy ConfigMap + Deployment
5. Done!

**Example:**
- Docker: `AUTH_SERVICE_HOST=auth-api`
- K8s: `AUTH_SERVICE_HOST=auth-service.default.svc.cluster.local`
