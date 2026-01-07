# GitLab High Availability (HA) Deployment

This repository contains Ansible playbooks for deploying a complete **production-ready GitLab HA environment** using Docker Compose. The setup provides high availability, load balancing, and scalable CI/CD infrastructure.

## 🏗️ Architecture Overview

```
Internet/Users
    ↓
Virtual IP (192.168.1.100)
    ↓
┌─────────────────┬─────────────────┐
│ Load Balancer 1 │ Load Balancer 2 │
│ 192.168.1.5     │ 192.168.1.6     │
│ HAProxy + Keep  │ HAProxy + Keep  │
│ alived (MASTER) │ alived (BACKUP) │
└─────────┬───────┴─────────┬───────┘
          │                 │
          └─────────────────┘
                  ↓
     ┌─────────┬─────────┐
     │ App 1   │ App 2   │
     │ 192.168 │ 192.168 │
     │ .1.10   │ .1.20   │
     │ GitLab +│ GitLab +│
     │ Redis M │ Redis S │
     └────┬────┴────┬────┘
          │         │
          └─────────┼─────────┘
                    ↓
          ┌─────────┴─────────┐
          │   Database HA    │
          │ PostgreSQL 18.1  │
          │ Primary: 192.168.1.30 │
          │ Replica: 192.168.1.31 │
          └───────────────────┘

     ┌─────────┬─────────┐
     │ Runner  │ Runner  │
     │ 192.168 │ 192.168 │
     │ .1.90   │ .1.91   │
     │ GitLab  │ GitLab  │
     │ Runner +│ Runner +│
     │ MinIO   │ MinIO   │
     └─────────┴─────────┘

          ┌───────────────────┐
          │   Ceph Storage    │
          │ Distributed FS    │
          │ /srv/gitlab/*     │
          └───────────────────┘
```

### Component Details:
- **🔴 Load Balancers**: HAProxy with Keepalived for VIP failover
- **🟠 Application Servers**: GitLab CE with Redis (Master/Slave)
- **🔵 Database**: PostgreSQL with streaming replication
- **🟢 CI/CD Runners**: GitLab Runner + MinIO object storage
- **🟣 Shared Storage**: Ceph distributed filesystem

## 🚀 Quick Start

### Prerequisites
- **Ubuntu 22.04+ servers** with SSH access
- **Docker & Docker Compose** pre-installed on all servers
- **Ansible 2.9+** on control machine
- **8+ CPU cores, 16GB+ RAM, 100GB+ storage** per server

### Infrastructure Requirements
| Component | Servers | CPU | RAM | Storage | Purpose |
|-----------|---------|-----|-----|---------|---------|
| Load Balancers | 2 | 2 cores | 4GB | 50GB | HAProxy + Keepalived |
| Application Servers | 2 | 8 cores | 32GB | 200GB | GitLab + Redis |
| Database Servers | 2 | 4 cores | 16GB | 500GB | PostgreSQL HA |
| Runner Servers | 2 | 4 cores | 8GB | 200GB | CI/CD + MinIO |

### Deployment Steps

1. **Clone and configure:**
   ```bash
   git clone <repository>
   cd gitlab-ha
   # Edit hosts file with your server IPs
   # Update passwords in hosts file
   ```

2. **Deploy infrastructure:**
   ```bash
   chmod +x start_script.sh
   ./start_script.sh
   ```

3. **Access GitLab:**
   - **URL:** `http://192.168.1.100`
   - **HAProxy Stats:** `http://192.168.1.100:8404/stats`
   - **MinIO Console:** `http://192.168.1.100:9001`

## 📋 Components

### Load Balancers (HAProxy + Keepalived)
- **Virtual IP:** 192.168.1.100
- **High availability** with automatic failover
- **SSL termination** ready
- **Rate limiting** and security headers

### Application Servers (GitLab CE)
- **Version:** 18.7.0-ce.0
- **Multi-server deployment** with shared storage
- **Container Registry** enabled
- **Pages** support
- **Monitoring** with Prometheus

### Database (PostgreSQL HA)
- **Version:** 18.1-alpine
- **Streaming replication** (Primary + Replica)
- **SSL encryption** enabled
- **Optimized for GitLab** workloads
- **Automatic failover** ready

### Cache (Redis Cluster)
- **Version:** 7.4.7-alpine
- **Master-slave replication**
- **Persistence** enabled
- **Security** with authentication

### Object Storage (MinIO)
- **Version:** RELEASE.2025-01-15T09-52-05Z
- **Distributed cluster** on runner servers
- **S3-compatible** API
- **GitLab integration** for artifacts/uploads
- **CI/CD cache** storage

### CI/CD Runners
- **Version:** 18.7.0
- **Docker executor** with DinD
- **MinIO cache** for build artifacts
- **Auto-scaling** ready

### Shared Storage (NFS)
- **High-performanceCeph)
- **Distributed filesystem** for high availability
- **Git repositories** and build artifacts
- **Scalable** and fault-tolerant storage
## 🔧 Configuration Files

| File | Purpose | Target Servers |
|------|---------|----------------|
| `hosts` | Ansible inventory | All servers |
| `load-balancer.yaml` | HAProxy + Keepalived | lb1, lb2 |
| `databases.yaml` | PostgreSQL HA | db1, db2 |
| `redis-cluster.yaml` | Redis replication | app1, app2 |
| `minio-cluster.yaml` | MinIO distributed | runner1, r |
| `minio-cluster.yaml` | MinIO distributed | runner1, runner2 |
| `gitlab.yaml` | GitLab application | app1, app2 |
| `gitlab-runner.yaml` | CI/CD runners | runner1, runner2| Control machine |

## 🔒 Security Features

- **SSL/TLS encryption** for database and web traffic
- **Firewall configuration** (UFW)
- **Secure defaults** with authentication
- **Network isolation** between components
- **Regular security updates** via Docker

## 📊 Monitoring & Health Checks

- **HAProxy statistics** at `:8404/stats`
- **GitLab health checks** built-in
- **Database replication** monitoring
- **MinIO cluster** status
- **Container health checks** for all services

## 🔄 Backup & Recovery

- **Database backups** configured
- **GitLab backup** integration
- **Ceph shared storage** for consistency
- **MinIO data** persistence
- **Automated backup** scripts ready

## 🛠️ Maintenance

### Scaling
- Add more application servers to `[gitlab_apps]`
- Expand MinIO cluster by adding runner servers
- Scale database read replicas

### Updates
- Update versions in `hosts` file
- Run playbooks individually for rolling updates
- Test updates in staging environment first

### Troubleshooting
- Check HAProxy stats for load distribution
- Monitor Docker container logs
- Use Ansible ad-hoc commands for diagnostics

## 📝 Manual Steps Required

After deployment:
1. **Register GitLab Runners** with tokens from GitLab admin
2. **Configure SSL certificates** for production
3. **Set up backup schedules**
4. **Configure monitoring/alerting**
5. **Change default passwords** in `hosts` file

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes thoroughly
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note:** This setup is designed for production use. Always test in a staging environment before deploying to production.
