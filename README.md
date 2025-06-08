
# Terraform AWS 3-Tier Architecture for Scalable Web App Deployment

## Table of Contents

1. [Overview](#overview)  
2. [Frontend EC2 Setup](#frontend-ec2-setup)  
3. [Backend EC2 Setup](#backend-ec2-setup)  
4. [Backend Server Configuration](#backend-server-configuration)  
5. [Frontend Server Configuration](#frontend-server-configuration)  
6. [Create AMIs](#create-amis)
7. [Terminate EC2 Instances(Frontend & Backend)](#Terminate-EC2-Instances (Frontend & Backend))
8. [Terraform Code Updates](#terraform-code-updates)  


---

## Overview

You will deploy two EC2 instances: a frontend server and a backend server. Each will host parts of a full-stack app connected to an RDS MySQL database. After deploying manually and taking AMIs, Terraform can recreate the infrastructure using your saved AMIs.


✨This repository is created to learn and deploy  3-tier application on aws cloud. this project contain three layer Presentation, Application and database

## 🏠 Architecture
![Architecture of the application](architecture.gif)



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
#Install Node.js and Dependencies
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
sudo npm install -g pm2
#Verify
node -v
npm -v
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


# Install pm2 globally
npm install -g pm2

# Start your app
pm2 start index.js --name backend-app

# Save the process list
pm2 save

# Setup startup script to run after reboot
pm2 startup

pm2 list           # shows running apps
pm2 logs           # live logs
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

**NOTE:** Before you are taking backend-server image you have to take the backend-server public ip and you have to paste the Google and you can see the message  hello

---

✅ Now your backend server is configured successfully!


---

## Frontend Server Configuration


# PART 4: Frontend Server Configuration

This guide sets up the frontend server to serve your React.js application using Apache on an Ubuntu-based EC2 instance.

---

## ✅ Prerequisites

- A running EC2 instance (frontend-server) with internet access
- SSH access to the EC2 instance
- Your GitHub repository cloned

---

## ✅ Step 1: Connect to Frontend Server

```bash
ssh -i "your-key.pem" ubuntu@<frontend-public-ip>
```

Update and upgrade the system:

```bash
sudo apt update -y
sudo apt upgrade -y
sudo -i
```

---

## ✅ Step 2: Install Dependencies

1. Create a shell script:

```bash
vim test.sh
```

2. Paste the following script inside the file:

```bash
#!/bin/bash
sudo apt update -y
sudo apt install apache2 -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
sudo apt-get install -y nodejs -y
sudo npm install -g corepack -y
corepack enable
corepack prepare yarn@stable --activate
```

3. Make the script executable and run it:

```bash
chmod +x test.sh
./test.sh
```

---

## ✅ Step 3: Clone Git Repository & Edit `config.js`

1. Clone your project repository:

```bash
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
```

2. Navigate to the frontend code:

```bash
cd Terraform-aws-3tier-app-deployment-project
cd client
cd src
cd pages
```

3. Open and edit the `config.js` file:

```bash
vim config.js
```

> **Update the line:**

```js
   // const API_BASE_URL = "http://3.84.145.194:84";
 const API_BASE_URL = "http://yaswanth.aluru.site";
// export default API_BASE_URL;
// const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || "http://backend";
// export default API_BASE_URL;
// const API_BASE_URL = "REACT_APP_API_BASE_URL_PLACEHOLDER";
export default API_BASE_URL;
```
```js
const API_BASE_URL = "http://yaswanth.aluru.site";
```

To point to your backend domain or IP as needed.

> **Ensure this is the only active line:**

```js
export default API_BASE_URL;
```

---

## ✅ Step 4: Build and Deploy React App

1. Go back to the `client` directory:

```bash
cd ..
cd ..
ls
```

2. Install dependencies and build:

```bash
npm install
npm run build
```

3. Copy the build files to Apache’s default HTML directory:

```bash
sudo cp -r build/* /var/www/html
```

4. Verify Apache is running:

```bash
systemctl status apache2
```

---

## ✅ Frontend Deployment Complete

You can now access your frontend application using the public IP or domain name of your EC2 instance in a web browser.

Example:

```
http://<frontend-ec2-public-ip>
or
http://yaswanth.aluru.site
```

---

---

## Create AMIs
# PART 4: Create AMIs (Amazon Machine Images)

Creating AMIs is an optional but **highly recommended** step before terminating instances. AMIs allow you to recreate instances later with the same configuration and data.

---

## ✅ STEP 1: Create Frontend AMI

1. Go to the **EC2 Dashboard** in your AWS Console.
2. Select the **frontend EC2 instance**.
3. Click on **Actions** → **Image and templates** → **Create Image**.
4. Name the image: `frontend-ami`
5. Click **Create image**.

---

## ✅ STEP 2: Create Backend AMI

1. Go to the **EC2 Dashboard** in your AWS Console.
2. Select the **backend EC2 instance**.
3. Click on **Actions** → **Image and templates** → **Create Image**.
4. Name the image: `backend-ami`
5. Click **Create image**.

---
## Terminate EC2 Instances (Frontend & Backend)

# PART 5: Terminate EC2 Instances (Frontend & Backend)

⚠️ **WARNING**: This action is irreversible. All data on the instances will be permanently lost unless backed up via AMIs, snapshots, or EBS.

---

## ✅ Step 1: Login to AWS Console

Open your browser and go to:

```
https://console.aws.amazon.com
```

Login with your AWS credentials.

---

## ✅ Step 2: Open EC2 Dashboard

1. In the AWS Console, search for **EC2** in the top search bar.
2. Click on the **EC2** service to open the dashboard.

---

## ✅ Step 3: Select the Instances

1. On the left menu, click **Instances** under the **Instances** section.
2. You will see all the running EC2 instances.
3. Select the checkbox next to:

   - Your **Frontend** instance (e.g., `frontend-server`)
   - Your **Backend** instance (e.g., `backend-server`)

---

## ✅ Step 4: Terminate Instances

1. Click on **Actions** → **Instance state** → **Terminate instance**.
2. Confirm termination.

---

## ✅ Done

Your EC2 instances will be terminated. If you created AMIs, you can relaunch them anytime.

---



## Terraform Code Updates

# 🔧 How to Use My Terraform Code (With Your Own Changes)

To use the Terraform code from the `Terraform-aws-3tier-app-deployment-project` repository, make the following two changes before applying the code:

---

## ✅ Change #1: Update AMI Name Filters

**File**:  
`Terraform-aws-3tier-app-deployment-project/PRIMARY-US-east-1/launctemp.tf`

Replace the AMI filters to match your own AMI names:

```hcl
filter {
  name   = "name"
  values = ["frontend-ami"]  # Replace with your Frontend AMI name
}

filter {
  name   = "name"
  values = ["backend-ami"]   # Replace with your Backend AMI name
}
```

Ensure that the names match exactly the AMIs you created in Part 4.

---

## ✅ Change #2: Update Key Pair Name

**File**:  
`Terraform-aws-3tier-app-deployment-project/PRIMARY-US-east-1/variable.tf`

Modify the `key-name` variable to match the name of your manually created key pair:

```hcl
variable "key-name" {
  description = "keyname"
  type        = string
  default     = "your-key-name"  # Replace with your actual key pair name
}
```

You must create this key pair manually in the AWS Console:
- Navigate to **EC2 Dashboard**
- Click **Key Pairs**
- Create a new key pair
- Use its name in the `default` value

---

Once these changes are made, you can directly use the Terraform code from the GitHub repository:

```
https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project
```

Happy automating! 🚀


# ✅ Steps to Setup Terraform AWS 3-Tier App Deployment

## Step 1: Open  VS Code and Launch Terminal

```bash
# Clone the repo
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git

# Navigate to the main project directory
cd Terraform-aws-3tier-app-deployment-project

# Open in VS Code
code .

# List files and navigate to directory
ls
cd PRIMARY-US-east-1/
ls
```

---

## ✅ Terraform Initialization and Deployment

```bash
# Initialize Terraform
terraform init

# Preview the infrastructure plan
terraform plan

# Apply the configuration to deploy the resources
terraform apply --auto-approve

# Check the state of deployed infrastructure
terraform state list
```

---

## 🔧 Post-Terraform Configuration Steps

### Step 1: Configure Backend RDS DNS

*Note*:Before you are creating backend Route 53 Hosted zone you have go and check the code on this path


#### Step 1.1: Check Environment Variables
File: `Terraform-aws-3tier-app-deployment-project/backend /.env`

```env
DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="yaswanth"
PORT=3306
```

#### Step 1.2: Create Private Hosted Zone in Route 53

**Path:** Route 53 → Hosted Zones → **Create hosted zone**

- **Domain name:** `rds.com`
- **Type:** Private hosted zone
- **VPC Region:** us-east-1 (N. Virginia)
- **VPC ID:** 3-tier-vpc  
- Click **Create hosted zone**

#### Step 1.3: Add A Record for RDS

**Path:** Route 53 → Hosted Zones → `rds.com` → **Create record**

- **Record name:** `book`
- **Type:** CNAME
- **Routing policy:** Simple
- **Alias:** Yes
- **Value:** `book-rds.c0n8k0a0swtz.us-east-1.rds.amazonaws.com`
- Click **Create record**

---

### Step 2: Configure Frontend Domain
*Note* : Before you are creating frontend Route 53 Hosted zone you have go and check the code on this path


#### Step 2.1: Verify API Base URL
File: `Terraform-aws-3tier-app-deployment-project/client/src/pages/config.js`

Ensure the active line is:

```javascript
// const API_BASE_URL = "http://3.84.145.194:84";
 const API_BASE_URL = "http://yaswanth.aluru.site";
// export default API_BASE_URL;
// const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || "http://backend";
// export default API_BASE_URL;
// const API_BASE_URL = "REACT_APP_API_BASE_URL_PLACEHOLDER";
export default API_BASE_URL;

```

#### Step 2.2: Create Public Hosted Zone in Route 53

**Path:** Route 53 → Hosted Zones → **Create hosted zone**

- **Domain name:** `aluru.site`
- **Type:** Public hosted zone  
- Click **Create hosted zone**

#### Step 2.3: Update Hostinger Nameservers

**Path:** [Hostinger Panel](https://hpanel.hostinger.com/domain) → Domains → `aluru.site` → **Manage** → DNS / Nameservers

- Click **Edit Nameservers**
- Paste these NS records from Route 53:
  - `ns-865.awsdns-84.net`
  - `ns-1995.awsdns-97.co.uk`
  - `ns-1418.awsdns-59.org`
  - `ns-265.awsdns-73.com`
- Click **Save**

#### Step 2.4: Create A Record for Frontend Access

**Path:** Route 53 → Hosted Zones → `aluru.site` → **Create record**

- **Record name:** `yaswanth`
- **Type:** A - IPv4 address
- **Routing policy:** Simple
- **Alias:** Yes
- **Route traffic to:** Alias to Application and Classic Load Balancer
- US East (N. Virginia)
- **Alias target:** `dualstack.backend-alb-195130194.us-east-1.elb.amazonaws.com`
- Click **Create record**

---



## 🔒 Step 3: Configure HTTPS with ACM and ALB

### Step 3.1: Request HTTPS Certificate using ACM

**Path:** AWS Certificate Manager → Request Certificate

- Select: **Request a public certificate**
- Click **Next**
- **Fully qualified domain name:** `*.aluru.site`
- **Validation method:** DNS validation (recommended)
- Click **Request**

### Step 3.2: Validate Domain in Route 53

**Path:** AWS Certificate Manager → Certificates → Domains → Create records in Route 53

- Under the domain, click **Create DNS record in Amazon Route 53**
- **Hosted zone:** `aluru.site`
- Click **Create record**
- Wait a few minutes for validation to complete

### Step 3.3: Add HTTPS Listener to ALB

**Path:** EC2 → Load Balancers → `backend-alb` → Listeners → **Add listener**

- **Protocol:** HTTPS  
- **Port:** 443  
- **Default action:** Forward to target group  
- **Target group:** `backend-tg`  
- **Security policy:** ELBSecurityPolicy-2021-06 (or latest)  
- **Certificate source:** From ACM  
- **Certificate:** `*.aluru.site`  
- Click **Add**

---

## 🛠️ Step 4: Insert Initial Records in RDS via Bastion Host

### Note:
Remember this what I am trying to say my database inside when you can access frontend in load balance so you are able to see first few records from the database later onwards after that you can insert a record so initial when you accessing frontend load balance you have to see your few records in that case you need to connect this database Insert records to access first time to see this records in that case connect RDS and insert your records while accessing time you can see those records and after that you can insert  the  to frontend and backend API methods only.  Initially dashboard we need required.


### Steps:

```bash
# Connect to Bastion Host
sudo -i

# Clone the project
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git

cd Terraform-aws-3tier-app-deployment-project/backend
ls

# Install MySQL Client
apt install mysql-client-core-8.0

# Verify MySQL Client
mysql --version

# Import SQL Data into RDS
mysql -h book.rds.com -u admin -p < test.sql
```

### Verify Data in RDS

```bash
mysql -h book.rds.com -u admin -p
# Enter password: yaswanth

SHOW DATABASES;
USE test;
SHOW TABLES;
SELECT * FROM books;
```

---

### 🔁 Backend and Frontend Routing Flow

- Even you can check  **backend load balancer** it will respond hello backend is working fine 
- Let's access fronend load balance
- **frontend load balancer**  I am accessing request will go to  frontend server frontend server inside config.js in config .js in route 53 record I have given route 53 is redirecting into backend load balance and backend load balance redirecting to back in server and back and server inside . env file is there that is directing into private hosted zone in route 53 from there to RDS

---

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy --auto-approve
```
