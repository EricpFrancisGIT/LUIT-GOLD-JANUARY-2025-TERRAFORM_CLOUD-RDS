# Deploying a Highly Available 2‑Tier Architecture with Terraform

Spin up a production‑style, **docs‑driven** two‑tier AWS stack using **Terraform** and **Terraform Cloud** (TFC) as your CI/CD. The stack is intentionally simple but correct: a custom VPC spread across two AZs, two public web servers, a private RDS MySQL instance, and (advanced) an internet‑facing ALB. Everything is built with **reusable modules**.

> **Use the official Terraform documentation as your primary reference while implementing. Do not copy/paste someone else’s code.** This repo demonstrates a clean approach to structure and workflow; adapt it thoughtfully.

---

## ✨ What you’ll build

- **Custom VPC**
  - 2× **Public** subnets (web tier) and 2× **Private** subnets (db tier), across **two Availability Zones**
  - Internet Gateway, NAT Gateway, route tables & associations
- **Web tier**
  - 2× EC2 instances (Amazon Linux 2023) with **NGINX** via user‑data
  - One instance per public subnet for HA
- **DB tier**
  - **RDS MySQL** (`db.t3.micro`) in **private** subnets
  - Password generated safely for RDS (allowed ASCII only)
- **Network security**
  - Security Groups for **ALB**, **web**, and **db**, following least privilege
- **Terraform Cloud**
  - VCS‑driven plan/apply with workspace variables for AWS credentials
- **(Advanced)**
  - Internet‑facing **Application Load Balancer** targeting the web servers
  - Web SG tightened to accept HTTP only from the ALB SG

---

## 🗺️ Architecture

```mermaid
flowchart LR
  internet((Internet)) -->|HTTP 80| ALB[Application Load Balancer (public)]
  subgraph Public_Subnets[Public Subnets (AZ-a / AZ-b)]
    WS1[EC2 Web Server #1]
    WS2[EC2 Web Server #2]
  end
  subgraph Private_Subnets[Private Subnets (AZ-a / AZ-b)]
    RDS[(RDS MySQL)]
  end
  ALB -->|HTTP 80| WS1
  ALB -->|HTTP 80| WS2
  WS1 -->|TCP 3306| RDS
  WS2 -->|TCP 3306| RDS
```

---

## 📦 Repository structure

```
.
├── versions.tf                 # Terraform + provider versions (and TFC backend)
├── providers.tf                # AWS provider + region
├── variables.tf                # Root input variables
├── main.tf                     # Root composition (VPC, SG, EC2, RDS, ALB wiring)
├── outputs.tf                  # Useful outputs (ALB DNS, web URLs, RDS endpoint)
├── terraform.tfvars.example    # Example variables file
└── modules/
    ├── vpc/    (VPC, subnets, IGW, NAT, routes, associations)
    ├── sg/     (security groups: alb, web, db)
    ├── ec2/    (web instances + user‑data)
    ├── rds/    (db subnet group + RDS MySQL)
    └── alb/    (ALB, target group, listener, attachments)
```

> If you add tooling/integrations (e.g., Datadog), keep them under `monitoring/`.

---

## ✅ Prerequisites

- **AWS account** with permissions for VPC/EC2/RDS/IAM/ELB.
- **Terraform ≥ 1.5** locally (optional, for `fmt/validate` before pushing).
- **Terraform Cloud** account + GitHub repo (VCS workflow).
- (Optional) An **EC2 key pair** if you plan to allow SSH (otherwise use SSM Session Manager).

---

## ⚙️ Configuration

Create `terraform.tfvars` from the example and edit to suit your account/region:

```hcl
# terraform.tfvars
aws_region  = "us-east-1"
project     = "City Of Anaheim Cloud Project" # any string; modules sanitize names where needed
my_ip_cidr  = "203.0.113.55/32"               # your public IP for optional SSH; use /32
key_name    = null                             # or "your-keypair-name"
multi_az_db = false                            # toggle true for Multi-AZ RDS (extra cost)

# Optional: ALB helper slug if your project name is long/has spaces
# project_slug = "city-of-anaheim-cloud-project"
```

### Root variables (high level)

| Variable | Type | Default | Description |
|---|---|---:|---|
| `aws_region` | string | `us-east-1` | AWS region |
| `project` | string | `"two-tier"` | Human‑readable project name; used in tags/names (sanitized where needed) |
| `my_ip_cidr` | string | `"0.0.0.0/0"` | Your IP in `/32` if enabling SSH to web tier |
| `key_name` | string\|null | `null` | EC2 key pair name (for SSH) |
| `vpc_cidr` | string | `10.0.0.0/16` | VPC CIDR |
| `public_subnet_cidrs` | list(string) | `["10.0.1.0/24","10.0.2.0/24"]` | Two web subnets |
| `private_subnet_cidrs` | list(string) | `["10.0.11.0/24","10.0.12.0/24"]` | Two db subnets |
| `multi_az_db` | bool | `false` | RDS Multi‑AZ (HA, extra cost) |
| `project_slug` | string\|null | `null` | (Advanced) Pre‑sanitized slug for ALB names |

---

## ☁️ Terraform Cloud (CI/CD)

1. **Backend:** In `versions.tf`, set your Terraform Cloud `organization` and `workspaces.name`.
2. **Connect repo:** Create a **VCS workspace** in TFC and link this GitHub repo.
3. **Workspace → Variables → Environment:** add AWS creds (**case‑sensitive keys**):
   - `AWS_ACCESS_KEY_ID`  
   - `AWS_SECRET_ACCESS_KEY`  
   - (If using STS) `AWS_SESSION_TOKEN`  
   - (Optional) `AWS_DEFAULT_REGION` (or pass `aws_region` as a Terraform var)

> **NOTE:** **DO NOT FORGET** to set your **ACCESS KEY**, **SECRET ACCESS KEY**, and **REGION** environment variables in Terraform Cloud.

Push a commit → TFC runs **plan** automatically. Approve **apply** to deploy.

---

## 🚀 Deploy

```bash
# (Optional local checks before pushing)
terraform fmt -recursive
terraform validate

# Commit & push to your default branch
# GitHub → triggers TFC plan → Review → Apply

# After apply, check outputs in TFC:
# - alb_url (if ALB enabled)
# - web_urls
# - rds_endpoint
```

Validate from a browser/terminal:
```bash
# Hit ALB (preferred)
open http://<alb_dns_name>

# Or reach each web server directly (if exposed; not recommended with ALB)
open http://<web_public_ip_1>
open http://<web_public_ip_2>
```

Optional DB check from a web instance:
```bash
# Use SSM Session Manager (no inbound SSH needed)
# AWS Console → Systems Manager → Session Manager → Start session → pick a web instance
sudo dnf -y install mariadb105
mysql -h <rds_endpoint> -u admin -p
```

---

## 🔐 Security Groups (intended rules)

- **ALB SG**  
  - Inbound: `80/tcp` from `0.0.0.0/0` (add `443` later for TLS)  
  - Outbound: all
- **Web SG**  
  - Inbound: `80/tcp` **from ALB SG only**  
  - (Optional) `22/tcp` **from your IP only** if `enable_ssh = true`  
  - Outbound: all
- **DB SG**  
  - Inbound: `3306/tcp` from **Web SG** only  
  - Outbound: all

---

## 🧱 Modules overview

- `modules/vpc` – VPC, 2× public subnets, 2× private subnets, IGW, NAT, routes, associations  
- `modules/sg` – ALB/Web/DB security groups with least privilege  
- `modules/ec2` – Two web instances (one per public subnet), NGINX user‑data  
- `modules/rds` – DB subnet group + RDS MySQL (db.t3.micro) in private subnets  
- `modules/alb` – Internet‑facing ALB, target group, listener, instance attachments

> To make planning deterministic, the EC2 module uses a **map with static keys** (`{ az1 = ..., az2 = ... }`) for `for_each`. The ALB module accepts a **map of instance IDs** to attach. This avoids the classic “invalid for_each” error with apply‑time unknowns.

---

## 🧪 Outputs

| Output | Description |
|---|---|
| `alb_dns_name` / `alb_url` | ALB DNS (click to open in a browser) |
| `web_public_ips` | Public IPs of web instances |
| `web_urls` | Convenience `http://<ip>` URLs |
| `rds_endpoint` | Hostname for the MySQL instance |
| `rds_port` | MySQL port (3306) |

---

## 💸 Costs & cleanup

This stack creates billable resources: **NAT Gateway**, ALB, EC2, RDS, EIP. To avoid surprise charges:

```bash
# In Terraform Cloud: Queue destroy plan → Apply
# (or locally) terraform destroy -var-file=terraform.tfvars
```

---

## 🧭 Advanced

### Internet‑facing ALB
- Deployed across the two **public** subnets.
- Health checks on `/` (200–399).
- Web SG allows HTTP only from ALB SG.

### HTTPS (later)
- Request/validate an ACM certificate.
- Add an ALB `:443` listener with the cert.
- Redirect `80 → 443`.
- Open `443` on the ALB SG.

### SSM Session Manager (no SSH)
- IAM role with `AmazonSSMManagedInstanceCore` attached to EC2.
- Start shell sessions from **AWS Console → Systems Manager → Session Manager**.

---

## 🧩 Troubleshooting (real‑world issues & fixes)

- **RDS password rejected**
  ```
  InvalidParameterValue: MasterUserPassword is not a valid password. Only printable ASCII characters besides '/', '@', '"', ' ' may be used.
  ```
  Use `random_password` with allowed chars, e.g. `override_special = "!#$%^&*()-_=+[]{}:?,."`.

- **Undeclared variable (e.g., `db_password`)**
  TFC workspace has a var your root doesn’t declare. Remove it or rename to `master_password` and pass it through (or rely on the generated password).

- **Invalid `for_each` due to unknown values**
  Use a **map with static keys** for `for_each` (e.g., `{ az1 = subnet[0], az2 = subnet[1] }`), not a set derived from other resources.

- **RDS/ALB/IAM naming constraints**
  - RDS identifiers: lowercase alphanumerics + hyphens, must start with a letter (≤63 chars). Build with `lower()`, `replace()`, and `substr()`.
  - ALB name: letters, numbers, hyphens only (≤32 chars). Replace spaces/underscores with hyphens; truncate.
  - IAM role/profile name: must match `[\w+=,.@-]`. Replace spaces/symbols with hyphens or use `name_prefix`.

- **Null in user‑data interpolation (e.g., Datadog key)**
  Guard optional chunks in user‑data:
  ```hcl
  datadog_userdata = var.dd_api_key == null ? "" : <<-EODD
    # install agent…
  EODD
  user_data = "${chomp(local.nginx_userdata)}\n${chomp(local.datadog_userdata)}"
  ```

---

## 📝 Submission checklist

- [ ] Code committed to GitHub with this README.  
- [ ] TFC workspace connected to repo; AWS creds/region set under **Environment**.  
- [ ] Plan/Apply succeeds; outputs show ALB URL and RDS endpoint.  
- [ ] NGINX reachable via the ALB; web SG not publicly exposed.  
- [ ] RDS private and reachable only from web tier.  
- [ ] (Optional) Modules used for repeatability.

---

## 📚 Documentation you should consult

- Terraform Language: variables, outputs, modules, `for_each`, functions (`lower`, `replace`, `substr`)
- Terraform AWS Provider:  
  `aws_vpc`, `aws_subnet`, `aws_internet_gateway`, `aws_nat_gateway`, `aws_route_table`, `aws_route_table_association`,  
  `aws_security_group`, `aws_instance`, `aws_db_subnet_group`, `aws_db_instance`,  
  `aws_lb`, `aws_lb_target_group`, `aws_lb_listener`, `aws_lb_target_group_attachment`,  
  IAM: `aws_iam_role`, `aws_iam_instance_profile`, `aws_iam_role_policy_attachment`

> **Reminder:** Use the official Terraform docs while you implement. Understand each resource and variable you add.

---

## 🪪 License

MIT (or your choice). Add a `LICENSE` file if you want to clarify usage.
