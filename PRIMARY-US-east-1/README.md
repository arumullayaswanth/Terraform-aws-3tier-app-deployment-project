

# 🏗️ Terraform Infrastructure for Primary Region (us-east-1)

This project provisions a cloud infrastructure in the **primary region** (`us-east-1`) to handle main traffic, services, and databases for your application. It includes the following:

- VPC and networking setup
- Auto scaling compute instances (frontend & backend)
- Load balancers and target groups
- RDS database
- Bastion host for SSH access
- EC2 initialization scripts

---

## 📁 File Overview

### 🛠 Core Configuration

| File | Description |
|------|-------------|
| `provider.tf` | Cloud provider setup (e.g., AWS region, credentials). |
| `variable.tf` | Input variables used throughout the infrastructure. |

---

### 🌐 Networking

| File | Description |
|------|-------------|
| `vpc.tf` | Virtual Private Cloud (VPC), subnets, route tables, internet/NAT gateways. |
| `security_group.tf` | Security group rules for controlling traffic between components. |

---

### 🚀 Compute & Autoscaling

| File | Description |
|------|-------------|
| `autoscalling.tf` | Auto Scaling Group configuration for managing EC2 instance scaling. |
| `launctemp.tf` | EC2 Launch Templates (recommended to rename to `launchtemplate.tf`). |
| `bastionserver.tf` | Bastion host setup for secure SSH into private instances. |

---

### 🎛️ Load Balancers

| File | Description |
|------|-------------|
| `frontend-tg&lb.tf` | Load Balancer and Target Group for front-end services. |
| `backend-tg&lb.tf` | Load Balancer and Target Group for back-end services. |

---

### 🖥 Initialization Scripts

| File | Description |
|------|-------------|
| `frontend-lt.sh` | User data script to initialize front-end EC2 instances (e.g., install web server). |
| `backend-lt.sh` | User data script to initialize back-end EC2 instances (e.g., install backend services). |

---

### 💾 Database

| File | Description |
|------|-------------|
| `rds.tf` | AWS RDS instance provisioning (e.g., MySQL/PostgreSQL database). |

---

## ✅ Getting Started

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Preview the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **(Optional) Destroy resources:**
   ```bash
   terraform destroy
   ```

---

## 📂 Recommended Structure

```
.
PRIMARY-US-east-1/
├── scripts/
│   ├── backend-lt.sh             # EC2 user data script for backend
│   └── frontend-lt.sh            # EC2 user data script for frontend
├── autoscalling.tf               # Auto Scaling configuration
├── backend-tg&lb.tf              # Backend target group and load balancer setup
├── bastionserver.tf              # Bastion host setup for SSH access
├── frontend-tg&lb.tf             # Frontend target group and load balancer setup
├── launctemp.tf                  # EC2 launch template (rename to launchtemplate.tf)
├── provider.tf                   # AWS provider setup (us-east-1)
├── rds.tf                        # RDS provisioning for primary database
├── security_group.tf             # Security group definitions
├── variable.tf                   # Input variables used in infrastructure
├── vpc.tf                        # VPC setup (subnets, route tables, gateways)
└── README.md                     # Primary region documentation

```

---

## 📌 Notes

- ✅ Make sure AWS credentials are configured before running Terraform.
- ⚠️ File `launctemp.tf` may contain a typo — consider renaming to `launchtemplate.tf` for clarity.
- 💬 Use modularization for better reuse if the infrastructure grows.

---

## 📞 Contact

For feedback, suggestions, or questions, feel free to reach out to the project maintainer.
