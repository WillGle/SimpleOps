# SimpleOps: DevOps Automation Stack

SimpleOps is an **automated DevOps environment** that integrates **GitLab, Jenkins, SonarQube, Prometheus, Loki, and Grafana** into a single streamlined system. This stack is designed to simplify CI/CD pipelines, monitoring, and logging for software development teams.

---

## Features
- **GitLab** – Version control & repository management  
- **Jenkins** – CI/CD automation  
- **SonarQube** – Code quality and security analysis  
- **Prometheus** – System monitoring and alerting  
- **Loki** – Log aggregation  
- **Grafana** – Data visualization  

---

## Prerequisites
Ensure you have the following installed:
- [Docker](https://docs.docker.com/get-docker/)  
- [Docker Compose](https://docs.docker.com/compose/install/)  
- (Optional) `git` for version control  

---

## Quick Start

### Clone the Repository
```bash
git clone https://github.com/yourusername/simpleops.git
cd simpleops
```
### Configure Environment Variables
Create a .env file and configure your credentials:
```bash
cp .env.example .env
nano .env
```
Ensure you set values for:
```bash
POSTGRES_USER=yourkey
POSTGRES_PASSWORD=yourkey
POSTGRES_DB=yourkey
GITLAB_EXTERNAL_URL=http://yourURL
```
### Run the Setup Script
Execute the installation script:
```bash
chmod +x setup.sh
./setup.sh
```

Default URL
```bash
GitLab	http://localhost:8080
Jenkins	http://localhost:8081
SonarQube	http://localhost:9000
Prometheus	http://localhost:9090
Loki	http://localhost:3100
Grafana	http://localhost:3000
```