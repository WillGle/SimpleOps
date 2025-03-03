#!/bin/bash

# echo "Pulling the latest code from GitHub..."
# if [ ! -d "SimpleOps" ]; then
#   git clone https://github.com/WillGle/SimpleOps.git
# else
#   git -C SimpleOps pull
# fi

echo "Starting services with Docker Compose..."
docker compose up -d --build

echo "SimpleOps system is running! Access services at:"
echo " - GitLab: http://localhost:8080"
echo " - Jenkins: http://localhost:8081"
echo " - SonarQube: http://localhost:9000"
echo " - Prometheus: http://localhost:9090"
echo " - Loki: http://localhost:3100"
echo " - Grafana: http://localhost:3000"
