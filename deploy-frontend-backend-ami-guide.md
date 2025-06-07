
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

Repeat same steps as frontend, but:

- Name: `backend-server`

---

## Backend Server Configuration

### Step 1: Install Dependencies

\`\`\`bash
sudo apt update -y
sudo apt upgrade -y
sudo -i

vim test.sh
\`\`\`

Paste this:

\`\`\`bash
#!/bin/bash
sudo apt update -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs -y
sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2
\`\`\`

Run:

\`\`\`bash
chmod +x test.sh
./test.sh
\`\`\`

### Step 2: Clone and Configure App

\`\`\`bash
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
cd Terraform-aws-3tier-app-deployment-project/backend
\`\`\`

Create `.env` file:

\`\`\`bash
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="yaswanth"
PORT=3306
\`\`\`

### Step 3: Install App and PM2

\`\`\`bash
npm install
npm install dotenv
sudo pm2 start index.js --name "backendApi"
\`\`\`

### Step 4: Install MySQL

\`\`\`bash
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
mysql --version
\`\`\`

---

## Frontend Server Configuration

### Step 1: Install Dependencies

\`\`\`bash
sudo apt update -y
sudo apt upgrade -y
sudo -i

vim test.sh
\`\`\`

Paste this:

\`\`\`bash
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs -y
sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
\`\`\`

Run:

\`\`\`bash
chmod +x test.sh
./test.sh
\`\`\`

### Step 2: Clone and Configure App

\`\`\`bash
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
cd Terraform-aws-3tier-app-deployment-project/client/src/pages
\`\`\`

Edit `config.js`:

\`\`\`js
const API_BASE_URL = "http://yaswanth.aluru.site";
export default API_BASE_URL;
\`\`\`

### Step 3: Build and Deploy

\`\`\`bash
cd ../../../
npm install
npm run build
sudo cp -r build/* /var/www/html
systemctl status apache2
\`\`\`

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
