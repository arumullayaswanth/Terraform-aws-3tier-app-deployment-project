How to deploy frontend AMI and backend AMI now you can see how I am deploying ( You can do this process in manually )

Create two public servers one frontend server and backend server and deploy 



Later you can take AMI and delete Everything From that AMI you can run a terraform script






## PART 1: Create EC2 Instances (Frontend server)

Go to AWS EC2 console--->Instances--->Launch an instance


Name : frontend-server
Application and OS Images (Amazon Machine Image) : Ubuntu Server 24.04 LTS
Instance type : t2.micro
Select project-vpc and a public subnet

Enable Auto-assign Public IP

Add a Security Group with:

HTTP (80)

SSH (22)

HTTPS (443)

Configure storage : Add storage (default is fine)

Launch frontend-server instances 



## PART 2: Create EC2 Instances (Backend server)

Go to AWS EC2 console--->Instances--->Launch an instance

Name : Backend-server
Application and OS Images (Amazon Machine Image) : Ubuntu Server 24.04 LTS
Instance type : t2.micro
Select project-vpc and a public subnet

Enable Auto-assign Public IP

Add a Security Group with:

HTTP (80)

SSH (22)

HTTPS (443)

Configure storage : Add storage (default is fine)

Launch Backend-server instances 



## 🖥️ BACKEND SERVER CONFIGURATION

### ✅ Step 1: Install Dependencies

connect your frontend-server

```
sudo apt update -y
```
```
sudo apt upgrade -y
```
```
sudo -i
```

1.On the backend EC2, create a shell script:

```
vim test.sh
```

2.Paste this script:
  
```
bash
#!/bin/bash
```
sudo apt update -y
```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
```
sudo apt-get install -y nodejs -y
```
```
sudo npm install -g corepack -y
```
corepack enable
corepack prepare yarn@stable --activate
```
sudo npm install -g pm2
```
```


3.Run the script:

```
chmod +x test.sh
```
./test.sh




### ✅ Step 2: Clone Repo & Setup .env


1. Clone the repo:
    
    git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git

2. Navigate to the client directory:
  ls
  cd Terraform-aws-3tier-app-deployment-project
  ls
  cd backend
  ls
  cat .env
  
  DB_HOST=book.rds.com
  DB_USERNAME=admin
  DB_PASSWORD="yaswanth"
  PORT=3306

3. Create or edit .env:
   
   vi .env

4. Add this content (change values accordingly):


  DB_HOST=book.rds.com
  DB_USERNAME=admin
  DB_PASSWORD="yaswanth"
  PORT=3306


### ✅ Step 3: Install & Start App with PM2
Run:

npm install
npm install dotenv
```
sudo pm2 start index.js --name "backendApi"
```


### ✅ Step 4: Install MySQL on Ubuntu

```
sudo apt install mysql-server -y
```
```
sudo systemctl start MySQL
```
```
sudo systemctl enable mysql
```
```
sudo systemctl status mysql
```
```
mysql --version
```



now your frontend-server done


  





## 🖥️ FRONTEND SERVER CONFIGURATION

connect your frontend-server

```
sudo apt update -y
```
```
sudo apt upgrade -y
```
```
sudo -i
```

### ✅ Step 1: Install Dependencies

1.On the frontend EC2, create a shell script:

```
vim test.sh
```

2.Paste this script:


```
bash
#!/bin/bash
```
sudo apt update -y
```
```
sudo apt install apache2 -y
```
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
```
sudo apt-get install -y nodejs -y
```
```
sudo npm install -g corepack -y
```
corepack enable
corepack prepare yarn@stable --activate
```

3.Run the script:

```
chmod +x test.sh
```
./test.sh




### ✅ Step 2: Clone Git Repo & Edit config.js


1. Clone the repo:
    
    git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git

2. Navigate to the client directory:
  ls
  cd Terraform-aws-3tier-app-deployment-project
  ls
  cd client
  ls
  cd src
  ls
  cd pages
  ls
  cat config.js

3.Edit config.js:

    vim config.js
    

   // const API_BASE_URL = "http://3.84.145.194:84";
 const API_BASE_URL = "http://yaswanth.aluru.site";
// export default API_BASE_URL;
// const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || "http://backend";
// export default API_BASE_URL;
// const API_BASE_URL = "REACT_APP_API_BASE_URL_PLACEHOLDER";
export default API_BASE_URL;


4.Find and update this line:
 
const API_BASE_URL = "http://yaswanth.aluru.site";

Replace to this

### ✅ Step 3: Build and Deploy App

From client folder, run:

root@ip-172-31-81-171:~/Terraform-aws-3tier-app-deployment-project/client/src/pages# : cd ..
root@ip-172-31-81-171:~/Terraform-aws-3tier-app-deployment-project/client/src# : cd ..
root@ip-172-31-81-171:~/Terraform-aws-3tier-app-deployment-project/client# ls
npm install
npm run build
```
sudo cp -r build/* /var/www/html
```
systemctl status apache2

now your frontend-server done




### 💾 STEP 4: Create AMIs (Optional but recommended)
Go to EC2 → Select each server → Actions → Image → Create image

Name them: frontend-ami
Create image


### 💾 STEP 5: Create AMIs (Optional but recommended)
Go to EC2 → Select each server → Actions → Image → Create image

Name them: backend-ami
Create image



 Step-by-Step: Terminate EC2 Instances (Frontend & Backend)
⚠️ WARNING: This action is irreversible. All data on the instances (unless backed up via AMIs, snapshots, or EBS) will be permanently lost.

### ✅ Step 1: Login to AWS Console
Open browser and go to:
https://console.aws.amazon.com

Sign in to your AWS account.

### ✅ Step 2: Navigate to EC2 Dashboard
In the AWS Console, search for EC2 in the top search bar.

Click on EC2 service → This opens the EC2 Dashboard.

### ✅ Step 3: Select the Instances
In the left menu, click on Instances (under Instances section).

You’ll see a list of all running EC2 instances.

Select the checkbox next to:

Your Frontend instance

Your Backend instance

💡 Use instance names to identify them, such as frontend-server and backend-server.



------------------------------------------------------------------------------------------------------
If you want to use my  Terraform code you have to change these things and you can use directly my code


 

change -1


Terraform-aws-3tier-app-deployment-project/PRIMARY-US-east-1
/launctemp.tf




  filter {
    name   = "name"
    values = ["frontend-ami"] # Use your AMI name pattern (replace your AMI Name)
  }
}


  filter {
    name   = "name"
    values = ["backend-ami"] # Use your AMI name pattern  (replace your AMI Name)
  }
}




change -2

Create a keypair manually and update keypair name in code

Terraform-aws-3tier-app-deployment-project/PRIMARY-US-east-1
/variable.tf

variable "key-name" {
    description = "keyname"
    type = string
    default = "us-east-1"


---------------------------------------

open  VScode 
nwe Terminal

```
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
```

ls
```
cd PRIMARY-US-east-1/
```
ls





### ✅ Getting Started

Initialize Terraform:
```
terraform init
```

Preview the plan:
```
terraform plan
```

Apply the configuration:
```
terraform apply --auto-approve
```

Check the Current State
```
terraform state list
```


----------------------------------------
Once terraform created the infrastructure and next you have to do the following steps



### step -1 

Before you are creating backend Route 53 Hosted zone you have go and check the code on this path

Terraform-aws-3tier-app-deployment-project/backend /.env

DB_HOST=book.rds.com
DB_USERNAME=admin
DB_PASSWORD="yaswanth"
PORT=3306

### step-1.2

Configure Route 53 Hosted Zone for Rds endpoint

 Path: Route 53 → Hosted Zones → Create hosted zone

Domain name:rds.com
Type: Private hosted zone
VPCs to associate with the hosted zone
region : us-east-1 (US East (N Virginial)
VPC ID : (3-tietr-vpc)
Click Create hosted zone

### step-1.3

 Create A Record in Route 53
Path: Route 53 → Hosted zones → rds.com → Create record

Record name: book
Record type: CNAME - Routes traffic
Routing policy: Simple
Alias: Yes
value : book-rds.c0n8k0a0swtz.us-east-1.rds.amazonaws.com //give your book db rds end point

Click Create record



-------------------------------
 

### step-2

Before you are creating frontend Route 53 Hosted zone you have go and check the code on this path

Terraform-aws-3tier-app-deployment-project/client/src/pages
/config.js

// const API_BASE_URL = "http://3.84.145.194:84";
 const API_BASE_URL = "http://yaswanth.aluru.site";
// export default API_BASE_URL;
// const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || "http://backend";
// export default API_BASE_URL;
// const API_BASE_URL = "REACT_APP_API_BASE_URL_PLACEHOLDER";
export default API_BASE_URL;


### step-2.2

 Configure Route 53 Hosted Zone
Path: Route 53 → Hosted Zones → Create hosted zone

Domain name: aluru.site
Type: Public hosted zone
Click Create hosted zone


### Step 2.3

Update Domain Nameservers in Hostinger
Path: https://hpanel.hostinger.com/domain → Domains → aluru.site → Manage → DNS / Nameservers

Click Edit Nameservers
Paste the 4 NS records from Route 53:
ns-865.awsdns-84.net
ns-1995.awsdns-97.co.uk
ns-1418.awsdns-59.org
ns-265.awsdns-73.com
Click Save



### Step 2.4:Create A Record in Route 53

Path: Route 53 → Hosted zones → aluru.site → Create record

Record name: yaswanth
Record type: A - IPv4 address
Routing policy: Simple
Alias: Yes
Route traffic to : Alias to Application and Classic Load Balancer
Region: US East (N. Virginia)
Alias target value: dualstack.backend-alb-195130194.us-east-1.elb.amazonaws.com //backend-load balancer
Click Create record

---------------------------

 Step 3: Request HTTPS Certificate using ACM
Path: AWS Certificate Manager → Request Certificate

Select: Request a public certificate
Click Next
Fully qualified domain name: *.aluru.site
Validation method: DNS validation (recommended)
Click Request


 Step 3.2: Validate Domain in Route 53
Path: AWS Certificate Manager → Certificates --> Domains  → Create records in Route 53

Under domain, click Create DNS record in Amazon Route 53
Select your hosted zone: aluru.site
Click Create record
Wait a few minutes for validation to complete


 Step 3.3: Add HTTPS Listener to ALB
Path: EC2 → Load Balancers → backend-alb → Listeners → Add listener

Protocol: HTTPS
Port: 443
Default action:
Routing action :Forward to target groups 
Target group : backend-tg
Security policy: ELBSecurityPolicy-2021-06 (or latest)
Certificate source : From ACM
Certificate (from ACM) : *.aluru.site
Click Add


---------------------------------------




-------------------------------
### step-3

### NOTE:
Remember this what I am trying to say my database inside when you can access frontend in load balance so you are able to see first few records from the database later onwards after that you can insert a record so initial when you accessive frontend load balance you have to see your few records in that case you need to connect this database insective records to access first time to see this records in that case connect RDS and insert your records while accessing time you can see those records and after that you can insert  the  to frontend and backend API methods only.  Initially dashboard we need required.

connect to bastion-server

```
sudo -i 
```

```
git clone https://github.com/arumullayaswanth/Terraform-aws-3tier-app-deployment-project.git
```

```
cd Terraform-aws-3tier-app-deployment-project
```
ls
 
```
cd backend
```

ls

mysql

```
apt install mysql-client-core-8.0
```

```
mysql --version
```

```
mysql -h book.rds.com -u admin -p < test.sql
```


Connect your database Weather script is executed or not you can cheque it once 
```
mysql -h book.rds.com -u admin -p
```
yaswanth

SHOW DATABASES;
USE test;
SHOW TABLES;
SELECT * FROM books;

### step-4

Even you can check backend Load balancer it will respond hello backend is working fine 

Let's access fronend load balance

frontend load balancer  I am accessing request will go to  frontend server frontend server inside config.js in config .js in route 53 record I have given route 53 is redirecting into backend load balance and backend load balance redirecting to back in server and back and server inside . env file is there that is directing into private hosted zone in route 53 from there to RDS





--------------------




# Destroy resources
```
terraform destroy --auto-approve
```











