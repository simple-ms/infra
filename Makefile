# Makefile for Simple Microservices Project
# Provides convenient commands for managing the infrastructure

.PHONY: help up down restart logs logs-follow build clean ps health seed-data

# Default target
help:
	@echo "Simple Microservices - Available Commands:"
	@echo ""
	@echo "  make up              - Start all services"
	@echo "  make up-logs         - Start all services with logging to file"
	@echo "  make down            - Stop all services"
	@echo "  make down-v          - Stop all services and remove volumes"
	@echo "  make restart         - Restart all services"
	@echo "  make logs            - View logs from all services"
	@echo "  make logs-follow     - Follow logs from all services"
	@echo "  make build           - Build all service images"
	@echo "  make clean           - Stop and remove all containers, networks, and volumes"
	@echo "  make ps              - Show running containers"
	@echo "  make health          - Check health of all services"
	@echo "  make seed-data       - Seed database with initial data"
	@echo ""

# Start services
up:
# 	docker compose up -d
# 	docker compose logs --build | tee logs.txt
# 	docker compose up --build > logs.txt 2>&1
	rm -f logs.txt
	docker compose up --build -d
	docker compose logs -f | tee logs.txt

# Start services with logging
up-logs:
	./start-with-logs.sh

# Stop services
down:
	docker compose down

# Stop services and remove volumes
down-v:
	docker compose down -v

# Restart services
restart:
	docker compose restart

# View logs
logs:
	docker compose logs

# Follow logs
logs-follow:
	docker compose logs -f

# Build images
build:
	docker compose build

# Clean everything
clean:
	docker compose down -v --remove-orphans
	rm -f docker-compose-logs.txt

# Show running containers
ps:
	docker compose ps

# Health check
health:
	@echo "Checking service health..."
	@curl -s http://localhost/auth/health | jq . || echo "Auth service: DOWN"
	@curl -s http://localhost/user/health | jq . || echo "User service: DOWN"
	@curl -s http://localhost/product/health | jq . || echo "Product service: DOWN"
	@curl -s http://localhost/order/health | jq . || echo "Order service: DOWN"
	@curl -s http://localhost/payment/health | jq . || echo "Payment service: DOWN"

# Seed data
seed-data:
	docker compose exec product-api python -m app.seed_data
