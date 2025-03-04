#!/bin/bash

set -e
set -o pipefail

# Load environment variables
if [ -f .env ]; then
  echo "🔄 Loading environment variables from .env file..."
  export $(grep -v '^#' .env | xargs)
else
  echo "⚠️ Warning: .env file not found! Using default values."
fi

# Validate required environment variables
REQUIRED_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "GITLAB_EXTERNAL_URL")
for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR}" ]; then
    echo "❌ Error: Missing required environment variable: $VAR"
    exit 1
  fi
done

# Ensure Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "❌ Error: Docker is not running! Start Docker and try again."
  exit 1
fi

# Start Docker Compose
echo "🚀 Starting services with Docker Compose..."
docker compose up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
SERVICES=("db" "gitlab" "jenkins" "grafana")

for SERVICE in "${SERVICES[@]}"; do
  until [ "$(docker inspect --format='{{.State.Health.Status}}' "$SERVICE" 2>/dev/null)" == "healthy" ]; do
    echo "🔄 Waiting for $SERVICE to be ready..."
    sleep 5
  done
done

# Print service URLs
echo "✅ All services are running! Access them at:"
echo " - GitLab:      ${GITLAB_EXTERNAL_URL}"
echo " - Jenkins:     http://localhost:8081"
echo " - SonarQube:   http://localhost:9000"
echo " - Prometheus:  http://localhost:9090"
echo " - Loki:        http://localhost:3100"
echo " - Grafana:     http://localhost:3000"
