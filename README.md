# gitlab-ha
graph TB
  %% External Access
  Internet([Internet/Users]) --> VIP[Virtual IP<br/>192.168.1.100]
  
  %% Load Balancer Layer
  VIP --> LB1[Load Balancer 1<br/>192.168.1.5<br/>HAProxy + Keepalived<br/>MASTER]
  VIP --> LB2[Load Balancer 2<br/>192.168.1.6<br/>HAProxy + Keepalived<br/>BACKUP]
  
  %% GitLab Application Layer
  LB1 --> APP1[GitLab App 1<br/>192.168.1.10<br/>gitlab/gitlab-ce:18.7.0-ce.0]
  LB1 --> APP2[GitLab App 2<br/>192.168.1.20<br/>gitlab/gitlab-ce:18.7.0-ce.0]
  LB1 --> APP3[GitLab App 3<br/>192.168.1.21<br/>gitlab/gitlab-ce:18.7.0-ce.0]
  
  LB2 --> APP1
  LB2 --> APP2
  LB2 --> APP3
  
  %% Database Layer
  APP1 --> DB1[PostgreSQL Primary<br/>192.168.1.30<br/>postgres:18.1-alpine<br/>Port: 5432]
  APP2 --> DB1
  APP3 --> DB1
  
  DB1 --> DB2[PostgreSQL Replica<br/>192.168.1.31<br/>postgres:18.1-alpine<br/>Port: 5433]
  
  %% Redis Cache Layer
  APP1 --> REDIS1[Redis Master<br/>192.168.1.40<br/>redis:7.4.7-alpine<br/>Port: 6379]
  APP2 --> REDIS1
  APP3 --> REDIS1
  
  REDIS1 --> REDIS2[Redis Slave 1<br/>192.168.1.41<br/>redis:7.4.7-alpine]
  REDIS1 --> REDIS3[Redis Slave 2<br/>192.168.1.42<br/>redis:7.4.7-alpine]
  
  %% Object Storage Layer
  APP1 --> MINIO1[MinIO Node 1<br/>192.168.1.60<br/>minio:RELEASE.2025-01-15T09-52-05Z]
  APP2 --> MINIO2[MinIO Node 2<br/>192.168.1.61<br/>minio:RELEASE.2025-01-15T09-52-05Z]
  APP3 --> MINIO3[MinIO Node 3<br/>192.168.1.62<br/>minio:RELEASE.2025-01-15T09-52-05Z]
  
  MINIO1 --> MINIO4[MinIO Node 4<br/>192.168.1.63<br/>minio:RELEASE.2025-01-15T09-52-05Z]
  MINIO2 --> MINIO4
  MINIO3 --> MINIO4
  
  %% Shared Storage Layer
  APP1 --> NFS1[NFS Server<br/>192.168.1.50<br/>Shared Storage<br/>/srv/gitlab/shared<br/>/srv/gitlab/builds]
  APP2 --> NFS1
  APP3 --> NFS1
  
  %% GitLab Runners Layer
  APP1 --> RUNNER1[GitLab Runner 1<br/>192.168.1.90<br/>gitlab-runner:18.7.0<br/>Docker Executor]
  APP2 --> RUNNER2[GitLab Runner 2<br/>192.168.1.91<br/>gitlab-runner:18.7.0<br/>Docker Executor]
  APP3 --> RUNNER3[GitLab Runner 3<br/>192.168.1.92<br/>gitlab-runner:18.7.0<br/>Docker Executor]
  
  %% Docker-in-Docker for Runners
  RUNNER1 --> DIND1[Docker-in-Docker<br/>docker:24.0-dind]
  RUNNER2 --> DIND2[Docker-in-Docker<br/>docker:24.0-dind]
  RUNNER3 --> DIND3[Docker-in-Docker<br/>docker:24.0-dind]
  
  %% Styling
  classDef loadbalancer fill:#ff6b6b,stroke:#333,stroke-width:2px,color:#fff
  classDef gitlab fill:#fc6d26,stroke:#333,stroke-width:2px,color:#fff
  classDef database fill:#336791,stroke:#333,stroke-width:2px,color:#fff
  classDef redis fill:#dc382d,stroke:#333,stroke-width:2px,color:#fff
  classDef minio fill:#c72e49,stroke:#333,stroke-width:2px,color:#fff
  classDef nfs fill:#4caf50,stroke:#333,stroke-width:2px,color:#fff
  classDef runner fill:#ffa726,stroke:#333,stroke-width:2px,color:#fff
  classDef external fill:#9c27b0,stroke:#333,stroke-width:2px,color:#fff
  classDef vip fill:#2196f3,stroke:#333,stroke-width:3px,color:#fff
  
  class Internet external
  class VIP vip
  class LB1,LB2 loadbalancer
  class APP1,APP2,APP3 gitlab
  class DB1,DB2 database
  class REDIS1,REDIS2,REDIS3 redis
  class MINIO1,MINIO2,MINIO3,MINIO4 minio
  class NFS1 nfs
  class RUNNER1,RUNNER2,RUNNER3,DIND1,DIND2,DIND3 runner
