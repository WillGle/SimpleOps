#!/bin/bash

set -eo pipefail

# --- Configuration ---
COMPOSE_FILE="docker-compose.yml"
SERVICES=("gitlab" "jenkins" "grafana" "loki" "prometheus" "sonarqube" "postgres")

# --- Check Docker ---
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "❌ Error: Docker not installed!" >&2
        exit 1
    fi
    docker info >/dev/null 2>&1 || {
        echo "❌ Error: Docker daemon not running!" >&2
        exit 1
    }
}

# --- Handle Environment Files ---
setup_environment() {
    if [ -f .env ]; then
        echo "🔄 Loading .env file"
        source .env
    elif [ -f .env.example ]; then
        echo "🔄 Using .env.example"
        source .env.example
    else
        echo "❌ Error: No .env or .env.example found!" >&2
        exit 1
    fi
}

# --- Generate Config Files if Missing ---
generate_configs() {
    mkdir -p services/monitoring/prometheus
    mkdir -p services/monitoring/loki  

    # Prometheus
    PROMETHEUS_CONFIG="services/monitoring/prometheus/prometheus.yml"
    if [ ! -f "$PROMETHEUS_CONFIG" ]; then
        echo "🔧 Creating Prometheus config at $PROMETHEUS_CONFIG"
        cat << EOF > "$PROMETHEUS_CONFIG"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'services'
    static_configs:
      - targets:
        - 'gitlab:80'
        - 'jenkins:8080'
        - 'sonarqube:9000'
        - 'prometheus:9090'
EOF
    else
        echo "✅ Prometheus config already exists."
    fi

    # Loki
    LOKI_CONFIG="services/monitoring/loki/config.yml"
    if [ ! -f "$LOKI_CONFIG" ]; then
        echo "🔧 Creating Loki config at $LOKI_CONFIG"
        cat << EOF > "$LOKI_CONFIG"
auth_enabled: false
server:
  http_listen_port: 3100
common:
  storage:
    filesystem:
      chunks_directory: /tmp/loki/chunks
schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
EOF
    else
        echo "✅ Loki config already exists."
    fi
}

# --- Main Execution ---
check_docker
setup_environment
generate_configs

echo "🚀 Starting Docker Compose..."
docker compose -f "$COMPOSE_FILE" up -d --build

# --- Health Checks with Timeout ---
echo "⏳ Waiting for services (health checks can take a while, especially GitLab)..."
for SERVICE in "${SERVICES[@]}"; do
    timeout=200 
    while :; do
        status=$(docker inspect -f '{{.State.Health.Status}}' "$SERVICE" 2>/dev/null || echo "starting")
        if [ "$status" = "healthy" ]; then
            break  # Exit the loop if healthy
        fi
        ((timeout-=5))
        if [ "$timeout" -le 0 ]; then
            echo -e "\n❌ Timeout waiting for $SERVICE"
            exit 1
        fi
        echo -n "."
        sleep 5
    done
    echo -e "\n✅ $SERVICE healthy"
done

# --- Output URLs ---
echo -e "\n🌐 Services ready at:"
echo "GitLab:     ${GITLAB_EXTERNAL_URL}"
echo "Jenkins:    http://localhost:8081"
echo "SonarQube:  http://localhost:9000"
echo "Prometheus: http://localhost:9090"
echo "Loki:       http://localhost:3100"
echo "Grafana:    http://localhost:3000"

