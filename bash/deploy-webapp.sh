#!/bin/bash
set -e

echo "=== WebApp Deployment Script ==="

# Variables
COMPOSE_FILE="/home/ubuntu/webapp/docker-compose.yml"
WEBAPP_DIR="/home/ubuntu/webapp"

# Create webapp directory if it doesn't exist
if [ ! -d "$WEBAPP_DIR" ]; then
    echo "Creating webapp directory..."
    mkdir -p "$WEBAPP_DIR"
fi

# Check if docker-compose.yml exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Error: docker-compose.yml not found at $COMPOSE_FILE"
    exit 1
fi

echo "Docker Compose file found: $COMPOSE_FILE"

# Login to ECR
echo "Logging in to ECR..."
AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Pull latest images
echo "Pulling latest images from ECR..."
cd "$WEBAPP_DIR"
docker compose pull

# Stop existing containers
echo "Stopping existing containers..."
docker compose down || true

# Start containers
echo "Starting containers..."
docker compose up -d

# Show running containers
echo ""
echo "✅ WebApp deployed successfully!"
echo ""
echo "Running containers:"
docker compose ps

# Show logs (last 20 lines)
echo ""
echo "Recent logs:"
docker compose logs --tail=20