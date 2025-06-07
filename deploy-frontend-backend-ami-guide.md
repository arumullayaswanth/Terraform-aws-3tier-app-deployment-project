
# Terraform AWS 3-Tier App Deployment (Manual EC2 Setup Guide)

## Table of Contents

1. [Overview](#overview)  
2. [Frontend EC2 Setup](#frontend-ec2-setup)  
3. [Backend EC2 Setup](#backend-ec2-setup)  
4. [Backend Server Configuration](#backend-server-configuration)  
5. [Frontend Server Configuration](#frontend-server-configuration)  
6. [Create AMIs](#create-amis)  
7. [Terraform Code Updates](#terraform-code-updates)  
8. [DNS Configuration with Route 53](#dns-configuration-with-route-53)  
9. [HTTPS Setup with ACM](#https-setup-with-acm)  
10. [Data Seeding in RDS](#data-seeding-in-rds)  
11. [Destroy Infrastructure](#destroy-infrastructure)

---

## Overview

You will deploy two EC2 instances: a frontend server and a backend server. Each will host parts of a full-stack app connected to an RDS MySQL database. After deploying manually and taking AMIs, Terraform can recreate the infrastructure using your saved AMIs.

---

## Frontend EC2 Setup

# PART 1: Create EC2 Instances (Frontend Server)

## Step-by-Step Instructions

1. **Login to AWS Console**
   - Navigate to: [https://console.aws.amazon.com/ec2](https://console.aws.amazon.com/ec2)

2. **Launch a New EC2 Instance**
   - Go to: `EC2 Dashboard` → `Instances` → `Launch Instance`

3. **Configure Instance Details**
   - **Name**: `frontend-server`
   - **Application and OS Image (AMI)**: `Ubuntu Server 24.04 LTS`
   - **Instance Type**: `t2.micro`
   - **VPC**: Select `project-vpc`
   - **Subnet**: Choose a **public subnet**

4. **Network Settings**
   - **Enable Auto-assign Public IP**

5. **Configure Security Group**
   - Create a new security group or choose an existing one with the following inbound rules:
     - **HTTP** (Port 80)
     - **HTTPS** (Port 443)
     - **SSH** (Port 22)

6. **Add Storage**
   - Use the default storage settings (or customize as per requirement)

7. **Launch Instance**
   - Click on `Launch Instance` to deploy the `frontend-server`

---

## Backend EC2 Setup

# PART 2: Create EC2 Instances (Backend Server)

## Step-by-Step Instructions

1. **Login to AWS Console**
   - Navigate to: [https://console.aws.amazon.com/ec2](https://console.aws.amazon.com/ec2)

2. **Launch a New EC2 Instance**
   - Go to: `EC2 Dashboard` → `Instances` → `Launch Instance`

3. **Configure Instance Details**
   - **Name**: `backend-server`
   - **Application and OS Image (AMI)**: `Ubuntu Server 24.04 LTS`
   - **Instance Type**: `t2.micro`
   - **VPC**: Select `project-vpc`
   - **Subnet**: Choose a **public subnet**

4. **Network Settings**
   - **Enable Auto-assign Public IP**

5. **Configure Security Group**
   - Create a new security group or choose an existing one with the following inbound rules:
     - **HTTP** (Port 80)
     - **HTTPS** (Port 443)
     - **SSH** (Port 22)

6. **Add Storage**
   - Use the default storage settings (or customize as per requirement)

7. **Launch Instance**
   - Click on `Launch Instance` to deploy the `backend-server`

---

## Backend Server Configuration


# PART 3: Backend Server Configuration

## ✅ Step 1: Install Dependencies

**Connect your frontend-server**

```bash
sudo apt update -y
sudo apt upgrade -y
sudo -i
```

1. On the backend EC2, create a shell script:

```bash
vim test.sh
```

2. Paste this script:

```bash
#!/bin/bash
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
sudo apt-get install -y nodejs -y
sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2
```

3. Run the script:

```bash
chmod +x test.sh
./test.sh
```

---

## ✅ Step 2: Clone Repo & Setup `.env`

1. Clone the repo:

```bash
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
```

2. Navigate to the client directory:

```bash
ls
cd Terraform-aws-3tier-app-deployment-project
ls
cd backend
ls
cat .env
```

Example `.env` values:

```env
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="yaswanth"
PORT=3306
```

3. Create or edit `.env`:

```bash
vi .env
```

4. Add this content (change values accordingly):

```env
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="yaswanth"
PORT=3306
```

---

## ✅ Step 3: Install & Start App with PM2

Run:

```bash
npm install
npm install dotenv
sudo pm2 start index.js --name "backendApi"
```

---

## ✅ Step 4: Install MySQL on Ubuntu

```bash
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
sudo systemctl status mysql
mysql --version
```

---

✅ Now your backend server is configured successfully!


---

## Frontend Server Configuration


---

## Create AMIs

1. Go to EC2 → Select Instance → Actions → Image → Create image  
2. Name them:
   - `frontend-ami`
   - `backend-ami`

---

## Terraform Code Updates

### Update AMI Filters in `launctemp.tf`:

\`\`\`hcl
filter {
  name   = "name"
  values = ["frontend-ami"]
}
...
filter {
  name   = "name"
  values = ["backend-ami"]
}
\`\`\`

### Update Key Pair Name in `variable.tf`:

\`\`\`hcl
variable "key-name" {
  default = "us-east-1"
}
\`\`\`

---

## DNS Configuration with Route 53

### Backend Private Hosted Zone

- Domain: `rds.com`
- A Record:
  - Name: `book`
  - Value: RDS Endpoint

### Frontend Public Hosted Zone

- Domain: `aluru.site`
- A Record:
  - Name: `yaswanth`
  - Target: Backend ALB

---

## HTTPS Setup with ACM

1. Request public certificate: `*.aluru.site`
2. DNS Validation via Route 53
3. Add HTTPS Listener on backend ALB

---

## Data Seeding in RDS

On Bastion:

\`\`\`bash
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
cd Terraform-aws-3tier-app-deployment-project/backend
apt install mysql-client-core-8.0
mysql -h book.rds.com -u admin -p < test.sql
\`\`\`

Verify:

\`\`\`bash
mysql -h book.rds.com -u admin -p
SHOW DATABASES;
USE test;
SHOW TABLES;
SELECT * FROM books;
\`\`\`

---

## Destroy Infrastructure

\`\`\`bash
terraform destroy --auto-approve
\`\`\`
