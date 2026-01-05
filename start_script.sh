#!/bin/bash

# GitLab HA Production Deployment Script
# Run this script to deploy the entire GitLab HA infrastructure

set -e

echo "🚀 Starting GitLab HA Production Deployment..."

# Check if inventory file exists
if [ ! -f "hosts" ]; then
    echo "❌ hosts file not found!"
    exit 1
fi

# Check Ansible installation
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible not found! Installing..."
    sudo apt update
    sudo apt install -y ansible
fi

# Install required Ansible collections
echo "📦 Installing required Ansible collections..."
ansible-galaxy collection install community.docker
ansible-galaxy collection install ansible.posix

# Deploy in correct order
echo "📋 Step 1: Deploying Load Balancers..."
ansible-playbook -i hosts load-balancer.yaml

echo "🗄️  Step 2: Deploying Database Cluster..."
ansible-playbook -i hosts databases.yaml

echo "🔴 Step 3: Deploying Redis Cluster..."
ansible-playbook -i hosts redis-cluster.yaml

echo "📦 Step 4: Deploying MinIO Cluster..."
ansible-playbook -i hosts minio-cluster.yaml

echo "📁 Step 5: Deploying NFS Server..."
ansible-playbook -i hosts nfs-server.yaml

echo "🦊 Step 6: Deploying GitLab Applications..."
ansible-playbook -i hosts gitlab.yaml

echo "🏃 Step 7: Deploying GitLab Runners..."
ansible-playbook -i hosts gitlab-runner.yaml

echo "✅ GitLab HA Deployment Complete!"
echo ""
echo "🌐 Access GitLab at: http://$(grep gitlab_vip hosts | cut -d'=' -f2 | tr -d '"')"
echo "📊 HAProxy Stats: http://$(grep gitlab_vip hosts | cut -d'=' -f2 | tr -d '"'):8404/stats"
echo "🗄️  MinIO Console: http://$(grep gitlab_vip hosts | cut -d'=' -f2 | tr -d '"'):9001"
echo ""
echo "⚠️  MANUAL STEPS REQUIRED:"
echo "1. Register GitLab Runners with tokens from GitLab admin panel"
echo "2. Configure SSL certificates if needed"
echo "3. Set up backup schedules"
echo "4. Configure monitoring and alerting"
echo "5. Change default passwords in inventory.ini"

# Health checks
echo ""
echo "🏥 Running health checks..."

VIP=$(grep gitlab_vip hosts | cut -d'=' -f2 | tr -d '"')

echo "Checking GitLab..."
if curl -f http://$VIP/users/sign_in > /dev/null 2>&1; then
    echo "✅ GitLab is responding"
else
    echo "❌ GitLab is not responding (may still be starting up)"
fi

echo "Checking HAProxy stats..."
if curl -f http://$VIP:8404/stats > /dev/null 2>&1; then
    echo "✅ HAProxy stats available"
else
    echo "❌ HAProxy stats not available"
fi

echo "Checking MinIO..."
if curl -f http://$VIP:9000/minio/health/live > /dev/null 2>&1; then
    echo "✅ MinIO is healthy"
else
    echo "❌ MinIO is not healthy"
fi

echo ""
echo "🎉 Deployment script completed!"
echo "📝 Check logs in /var/log/ on each server for troubleshooting"