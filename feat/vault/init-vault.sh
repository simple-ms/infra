#!/bin/bash
# Vault Initialization Script

set -e

echo "🔐 Initializing HashiCorp Vault..."

# Wait for Vault to be ready
echo "Waiting for Vault to start..."
sleep 5

export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='root-token'

# Enable KV secrets engine
echo "Enabling KV secrets engine..."
vault secrets enable -path=secret kv-v2 || echo "KV engine already enabled"

# Create secrets for each service
echo "Creating database secrets..."

# Auth Service
vault kv put secret/auth \
    db_password="postgres" \
    jwt_secret="your-super-secret-jwt-key-change-in-production" \
    jwt_algorithm="HS256"

# User Service  
vault kv put secret/user \
    db_password="postgres"

# Product Service
vault kv put secret/product \
    db_password="postgres"

# Order Service
vault kv put secret/order \
    db_password="postgres"

# Payment Service
vault kv put secret/payment \
    db_password="postgres" \
    stripe_secret_key="sk_test_simulated" \
    stripe_publishable_key="pk_test_simulated"

# Kafka credentials
vault kv put secret/kafka \
    bootstrap_servers="kafka:9092"

echo "✅ Vault initialized successfully!"
echo ""
echo "To read secrets:"
echo "  vault kv get secret/auth"
echo ""
echo "To update secrets:"
echo "  vault kv put secret/auth db_password=newpassword"
