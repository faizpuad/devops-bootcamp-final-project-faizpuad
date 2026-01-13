# DevOps Bootcamp Final Project

Infrastructure as Code project demonstrating Terraform, Ansible, Docker, and monitoring best practices with Cloudflare Full SSL.

## Live URLs

| Service | URL | Description |
|---------|-----|-------------|
| Web Application | [web.faizp.me](https://web.faizp.me) | Main web application (HTTPS) |
| Monitoring | [monitoring.faizp.me](https://monitoring.faizp.me) | Grafana dashboards |

## Architecture

```
                         Internet
                            |
              +-------------+-------------+
              |        Cloudflare         |
              |  (DNS + Full SSL + Tunnel)|
              +-------------+-------------+
                            |
        +-------------------+-------------------+
        |              AWS VPC                  |
        |           10.0.0.0/24                 |
        |                                       |
        |  +--------------+  +----------------+ |
        |  |Public Subnet |  | Private Subnet | |
        |  | 10.0.0.0/25  |  | 10.0.0.128/25  | |
        |  |              |  |                | |
        |  | +----------+ |  | +------------+ | |
        |  | |Web Server| |  | |  Ansible   | | |
        |  | |10.0.0.5  | |  | | Controller | | |
        |  | |Port: 443 | |  | | 10.0.0.135 | | |
        |  | |     9100 | |  | |            | | |
        |  | +----------+ |  | +------------+ | |
        |  |              |  |                | |
        |  |              |  | +------------+ | |
        |  |              |  | | Monitoring | | |
        |  |              |  | | 10.0.0.136 | | |
        |  |              |  | |Prometheus  | | |
        |  |              |  | |Grafana     | | |
        |  |              |  | +------------+ | |
        |  +--------------+  +----------------+ |
        +---------------------------------------+
```

## SSL Configuration

- **Mode**: Cloudflare Full SSL
- **Web Server**: HTTPS on port 443 with self-signed certificates
- **Monitoring**: Accessed via Cloudflare Tunnel (no public exposure)

## Project Structure

```
devops-project/
├── .github/
│   └── workflows/
│       ├── 1-terraform-apply.yml      # Infrastructure provisioning
│       ├── 2-ansible-bootstrap.yml    # Ansible controller setup
│       ├── 3-build-push-ecr.yml       # Docker build & ECR push
│       ├── 4-deploy-webapp.yml        # Web app deployment
│       └── 5-deploy-monitoring.yml    # Monitoring stack deployment
├── ansible/
│   ├── ansible.cfg                    # Ansible configuration
│   ├── files/
│   │   ├── prometheus.yml             # Prometheus scrape config
│   │   └── grafana/                   # Grafana provisioning
│   │       ├── dashboards/
│   │       │   └── node-exporter.json
│   │       └── provisioning/
│   │           ├── dashboards/
│   │           └── datasources/
│   ├── group_vars/
│   │   └── all.yml                    # Global variables
│   ├── inventory/
│   │   └── ssm_inventory.aws_ec2.yml  # Dynamic EC2 inventory
│   └── playbooks/
│       ├── install-docker.yml         # Docker installation (all servers)
│       ├── configure-firewall.yml     # UFW configuration
│       ├── deploy-webapp.yml          # Web app deployment
│       ├── deploy-node-exporter.yml   # Node exporter deployment
│       ├── deploy-monitoring.yml      # Prometheus + Grafana
│       └── setup-cloudflare-tunnel.yml
├── docker/
│   └── webapp/
│       ├── Dockerfile
│       ├── docker-compose.yml
│       ├── start.sh
│       └── assets/
├── terraform/
│   ├── main.tf                        # Main infrastructure
│   ├── variables.tf                   # Variable definitions
│   ├── terraform.tfvars               # Variable values
│   ├── outputs.tf                     # Output definitions
│   ├── providers.tf                   # Provider & backend config
│   └── modules/
│       ├── iam/                       # IAM roles & policies
│       └── ssm/                       # SSM parameters
├── devops_final_project_spec.md       # Project specification
├── devops-agent-rule.md               # Development guidelines
└── README.md                          # This file
```

## Quick Start

### Prerequisites
- AWS Account with CLI configured
- Terraform >= 1.0
- Domain with Cloudflare DNS
- GitHub account

### Deployment Steps

1. **Infrastructure (Terraform)**
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

2. **Web Application**
   - Push to `main` branch triggers automatic deployment
   - Or manually run GitHub Action: "ECR Build and Push"

3. **Monitoring Stack**
   - Create Cloudflare Tunnel, store token as `CLOUDFLARE_TUNNEL_TOKEN`
   - Run GitHub Action: "Deploy Monitoring Stack"

### Grafana Access
- URL: https://monitoring.faizp.me
- Default credentials: admin / admin (change on first login)

## Technologies Used

| Category | Technology |
|----------|------------|
| IaC | Terraform |
| Config Management | Ansible |
| Containerization | Docker |
| CI/CD | GitHub Actions |
| Cloud | AWS (EC2, VPC, ECR, SSM) |
| Monitoring | Prometheus, Grafana |
| DNS/CDN/SSL | Cloudflare (Full SSL + Tunnel) |

## Monitoring Dashboards

The Grafana instance includes pre-configured dashboards for:
- CPU Usage (%)
- Memory Usage (%)
- Disk Usage (%)

## Security Features

- Cloudflare Full SSL (encrypted end-to-end)
- Monitoring server in private subnet (no public IP)
- Cloudflare Tunnel for secure monitoring access
- AWS SSM for agentless server management
- Security groups with least-privilege rules

## GitHub Secrets Required

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `CLOUDFLARE_TUNNEL_TOKEN` | Cloudflare Tunnel token |

---

*DevOps Bootcamp Final Project 2025*
