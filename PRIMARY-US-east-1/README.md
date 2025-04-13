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



### 🖥 Initialization Scripts

| File | Description |
|------|-------------|
| `frontend-lt.sh` | User data script to initialize front-end EC2 instances (e.g., install web server). |
| `backend-lt.sh` | User data script to initialize back-end EC2 instances (e.g., install backend services). |


## backend-lt.sh

```bash
#!/bin/bash   # This is the shebang line that indicates the script should be run using the Bash shell.
sudo apt update -y   # Updates the list of available packages and their versions from the repositories. The '-y' flag automatically confirms the action.
sudo pm2 startup   # Sets up the system to automatically start the PM2 process manager on boot.
sudo pm2 save   # Saves the current PM2 process list so that it can be restored on system restart.

```
---

## frontend-lt.sh

```bash
#!/bin/bash   # This is the shebang line that indicates the script should be run using the Bash shell.
sudo apt update -y   # Updates the list of available packages and their versions from the repositories. The '-y' flag automatically confirms the action.
sleep 90   # Pauses the script for 90 seconds. This might be used to wait for system processes or dependencies to finish updating before starting Apache.
sudo systemctl start apache2.service   # Starts the Apache2 service, which is the web server software.
sudo systemctl enable apache2.service   # Configures Apache2 to start automatically on system boot.

```
---
### 🛠 Core Configuration

| File | Description |
|------|-------------|
| `provider.tf` | Cloud provider setup (e.g., AWS region, credentials). |
| `variable.tf` | Input variables used throughout the infrastructure. |

## provider.tf

```hcl
provider "aws" {  
  region = "us-east-1"  # This is the default AWS provider configuration. All resources that don't specify a provider will be created in the us-east-1 (N. Virginia) region.
}

provider "aws" {
  alias  = "secondary"     # This is a secondary (aliased) provider.
  region = "us-west-2"     # Resources using 'provider = aws.secondary' will be created in the us-west-2 (Oregon) region.
}

```

## variable.tf

```hcl
# Define the RDS password variable
variable "rds-password" {
  description = "RDS password"       # Description of the variable's purpose
  type        = string               # This variable is a string
  default     = "srivardhan"         # Default password value (not secure for production!)
  # sensitive = true                 # (Optional) Uncomment to hide this value in CLI output
}

# Define the RDS username variable
variable "rds-username" {
  description = "RDS username"       # Description of the variable
  type        = string               # String type
  default     = "admin"              # Default username for the RDS instance
}

# Define the AMI ID variable for launching EC2 instances
variable "ami" {
  description = "AMI ID for EC2 instances"  # Amazon Machine Image ID
  type        = string                      # String type
  default     = "ami-02f624c08a83ca16f"     # Default AMI ID
}

# Define the EC2 instance type variable
variable "instance-type" {
  description = "EC2 instance type"  # Instance size/type (e.g., t2.micro)
  type        = string               # String type
  default     = "t2.micro"           # Default instance type
}

# Define the EC2 key pair name variable
variable "key-name" {
  description = "EC2 key pair name"    # Key name used for SSH access
  type        = string                 # String type
  default     = "my-Key pair"          # Must match an existing AWS key pair name
}

# Define the backup retention period for RDS
variable "backup-retention" {
  description = "Number of days to retain RDS backups"   # Backup retention period
  type        = number                                   # Number type
  default     = 7                                        # Default is 7 days
}
```
---
### 🌐 Networking

| File | Description |
|------|-------------|
| `vpc.tf` | Virtual Private Cloud (VPC), subnets, route tables, internet/NAT gateways. |
| `security_group.tf` | Security group rules for controlling traffic between components. |

## vpc.tf

```hcl
# Creating a Virtual Private Cloud (VPC)
resource "aws_vpc" "three-tier" {
    cidr_block = "172.20.0.0/16"  # Define the IP address range for the VPC.
    enable_dns_hostnames = true  # Enable DNS hostnames for instances in the VPC.
    tags = {
        Name = "3-tier-vpc"  # Name tag for the VPC.
    }
}

# Subnet for frontend load balancer in availability zone us-east-1a
resource "aws_subnet" "pub1" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.1.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1a"  # Availability zone for this subnet.
    map_public_ip_on_launch = true  # Automatically assign public IP to instances in this subnet.
    tags = {
    Name = "pub-1a"  # Name tag for the subnet.
  }
}

# Subnet for frontend load balancer in availability zone us-east-1b
resource "aws_subnet" "pub2" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.2.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1b"  # Availability zone for this subnet.
    map_public_ip_on_launch = true  # Automatically assign public IP to instances in this subnet.
    tags = {
    Name = "pub-2b"  # Name tag for the subnet.
  }
}

# Subnet for frontend server in availability zone us-east-1a
resource "aws_subnet" "prvt3" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.3.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1a"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-3a"  # Name tag for the subnet.
  }
}

# Subnet for frontend server in availability zone us-east-1b
resource "aws_subnet" "prvt4" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.4.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1b"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-4b"  # Name tag for the subnet.
  }
}

# Subnet for backend server in availability zone us-east-1a
resource "aws_subnet" "prvt5" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.5.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1a"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-5a"  # Name tag for the subnet.
  }
}

# Subnet for backend server in availability zone us-east-1b
resource "aws_subnet" "prvt6" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.6.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1b"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-6b"  # Name tag for the subnet.
  }
}

# Subnet for RDS instance in availability zone us-east-1a
resource "aws_subnet" "prvt7" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.7.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1a"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-7a"  # Name tag for the subnet.
  }
}

# Subnet for RDS instance in availability zone us-east-1b
resource "aws_subnet" "prvt8" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the created VPC.
    cidr_block = "172.20.8.0/24"  # IP range for the subnet.
    availability_zone = "us-east-1b"  # Availability zone for this subnet.
    tags = {
    Name = "prvt-8b"  # Name tag for the subnet.
  }
}

# Creating an Internet Gateway to allow internet access for the public subnet
resource "aws_internet_gateway" "three-tier-ig" {
    vpc_id = aws_vpc.three-tier.id  # Attach the IGW to the VPC.
    tags = {
        Name = "3-tier-ig"  # Name tag for the Internet Gateway.
    }
}

# Creating a public route table to route traffic to the Internet Gateway
resource "aws_route_table" "three-tier-pub-rt" {
    vpc_id = aws_vpc.three-tier.id  # Associate with the VPC.
    tags = {
      Name = "3-tier-pub-rt"  # Name tag for the route table.
    }
  route {
    cidr_block = "0.0.0.0/0"  # Define a route for all internet traffic.
    gateway_id = aws_internet_gateway.three-tier-ig.id  # Route traffic through the IGW.
  }
}

# Associating pub-1a subnet with the public route table
resource "aws_route_table_association" "public-1a" {
    route_table_id = aws_route_table.three-tier-pub-rt.id  # Reference the public route table.
    subnet_id = aws_subnet.pub1.id  # Associate with the pub-1a subnet.
}

# Associating pub-2b subnet with the public route table
resource "aws_route_table_association" "public-2b" {
    route_table_id = aws_route_table.three-tier-pub-rt.id  # Reference the public route table.
    subnet_id = aws_subnet.pub2.id  # Associate with the pub-2b subnet.
}

# Creating an Elastic IP (EIP) for the NAT Gateway
resource "aws_eip" "eip" {
  # Elastic IP for the NAT Gateway; no configuration needed here.
}

# Creating a NAT Gateway for private subnet internet access
resource "aws_nat_gateway" "cust-nat" {
  subnet_id = aws_subnet.pub1.id  # Place NAT Gateway in the public subnet.
  connectivity_type = "public"  # Ensure it's publicly accessible.
  allocation_id = aws_eip.eip.id  # Attach the Elastic IP to the NAT Gateway.
  tags = {
    Name = "3-tier-nat"  # Name tag for the NAT Gateway.
  }
}

# Creating an Internet Gateway to allow internet access for the public subnet
resource "aws_internet_gateway" "three-tier-ig" {
    vpc_id = aws_vpc.three-tier.id  # Attach the Internet Gateway (IGW) to the VPC we created earlier.
    tags = {
        Name = "3-tier-ig"  # Tag the IGW with a name for easy identification.
    }
}

# Creating a public route table to allow routing internet traffic through the Internet Gateway
resource "aws_route_table" "three-tier-pub-rt" {
    vpc_id = aws_vpc.three-tier.id  # Attach the route table to the VPC created earlier.
    tags = {
      Name = "3-tier-pub-rt"  # Tag the route table with a name for easy identification.
    }

  # Define a route in the public route table to send all internet-bound traffic (0.0.0.0/0) through the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"  # This is a route for all internet traffic.
    gateway_id = aws_internet_gateway.three-tier-ig.id  # Use the created Internet Gateway for routing traffic to the internet.
  }
}


# Associating prvt-3a subnet with the private route table
resource "aws_route_table_association" "prvivate-3a" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt3.id  # Associate with the prvt-3a subnet.
}

# Associating prvt-4b subnet with the private route table
resource "aws_route_table_association" "prvivate-4b" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt4.id  # Associate with the prvt-4b subnet.
}

# Associating prvt-5a subnet with the private route table
resource "aws_route_table_association" "prvivate-5a" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt5.id  # Associate with the prvt-5a subnet.
}

# Associating prvt-6b subnet with the private route table
resource "aws_route_table_association" "prvivate-6b" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt6.id  # Associate with the prvt-6b subnet.
}

# Associating prvt-7a subnet with the private route table
resource "aws_route_table_association" "prvivate-7a" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt7.id  # Associate with the prvt-7a subnet.
}

# Associating prvt-8b subnet with the private route table
resource "aws_route_table_association" "prvivate-8b" {
    route_table_id = aws_route_table.three-tier-prvt-rt.id  # Reference the private route table.
    subnet_id = aws_subnet.prvt8.id  # Associate with the prvt-8b subnet.
}
```

## security_group.tf

```hcl
# Creating a security group for Bastion Host
resource "aws_security_group" "bastion-host" {
  name        = "appserver-SG"  # The name of the security group.
  description = "Allow inbound traffic from ALB"  # Description of the security group.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the previously created VPC.
  depends_on = [ aws_vpc.three-tier ]  # Ensure VPC is created before security group.

  # Inbound rule allowing SSH access (port 22) from anywhere (0.0.0.0/0)
  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 22  # Port for SSH
    to_port         = 22  # Port for SSH
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allows SSH from any IP
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "bastion-host-server-sg"  # Tag the security group for easy identification.
  }
}

# Creating a security group for the frontend ALB (Application Load Balancer)
resource "aws_security_group" "alb-frontend-sg" {
  name        = "alb-frontend-sg"  # Name of the security group.
  description = "Allow inbound traffic from ALB"  # Describes the security group’s purpose.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the VPC.
  depends_on = [ aws_vpc.three-tier ]  # Ensure VPC is created before security group.

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "http"
    from_port       = 80  # Port for HTTP
    to_port         = 80  # Port for HTTP
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  # Inbound rule allowing HTTPS (port 443) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "https"
    from_port       = 443  # Port for HTTPS
    to_port         = 443  # Port for HTTPS
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "alb-frontend-sg"  # Tag the security group for easy identification.
  }
}

# Creating a security group for the backend ALB (Application Load Balancer)
resource "aws_security_group" "alb-backend-sg" {
  name        = "alb-backend-sg"  # Name of the security group.
  description = "Allow inbound traffic ALB"  # Describes the security group’s purpose.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the VPC.
  depends_on = [ aws_vpc.three-tier ]  # Ensure VPC is created before security group.

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "http"
    from_port       = 80  # Port for HTTP
    to_port         = 80  # Port for HTTP
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  # Inbound rule allowing HTTPS (port 443) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "https"
    from_port       = 443  # Port for HTTPS
    to_port         = 443  # Port for HTTPS
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "alb-backend-sg"  # Tag the security group for easy identification.
  }
}

# Creating a security group for the frontend server
resource "aws_security_group" "frontend-server-sg" {
  name        = "frontend-server-sg"  # Name of the security group.
  description = "Allow inbound traffic"  # Describes the security group’s purpose.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the VPC.
  depends_on = [ aws_vpc.three-tier, aws_security_group.alb-frontend-sg ]  # Ensure VPC and ALB SG are created before.

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "http"
    from_port       = 80  # Port for HTTP
    to_port         = 80  # Port for HTTP
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  # Inbound rule allowing SSH (port 22) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "ssh"
    from_port       = 22  # Port for SSH
    to_port         = 22  # Port for SSH
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic from anywhere
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "frontend-server-sg"  # Tag the security group for easy identification.
  }
}

# Creating a security group for the backend server
resource "aws_security_group" "backend-server-sg" {
  name        = "backend-server-sg"  # Name of the security group.
  description = "Allow inbound traffic"  # Describes the security group’s purpose.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the VPC.
  depends_on = [ aws_vpc.three-tier, aws_security_group.alb-backend-sg ]  # Ensure VPC and ALB SG are created before.

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "http"
    from_port       = 80  # Port for HTTP
    to_port         = 80  # Port for HTTP
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  # Inbound rule allowing SSH (port 22) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "ssh"
    from_port       = 22  # Port for SSH
    to_port         = 22  # Port for SSH
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH traffic from anywhere
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "backend-server-sg"  # Tag the security group for easy identification.
  }
}

# Creating a security group for the RDS (database)
resource "aws_security_group" "book-rds-sg" {
  name        = "book-rds-sg"  # Name of the security group.
  description = "Allow inbound"  # Describes the security group’s purpose.
  vpc_id      = aws_vpc.three-tier.id  # Attach the security group to the VPC.
  depends_on = [ aws_vpc.three-tier ]  # Ensure VPC is created before security group.

  # Inbound rule allowing MySQL/Aurora traffic (port 3306) from anywhere (0.0.0.0/0)
  ingress {
    description     = "mysql/aroura"
    from_port       = 3306  # Port for MySQL/Aurora
    to_port         = 3306  # Port for MySQL/Aurora
    protocol        = "tcp"  # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]  # Allow MySQL traffic from anywhere
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allows all outbound traffic
  }

  tags = {
    Name = "book-rds-sg"  # Tag the security group for easy identification.
  }
}

```
---
### 🚀 Compute & Autoscaling

| File | Description |
|------|-------------|
| `autoscalling.tf` | Auto Scaling Group configuration for managing EC2 instance scaling. |
| `launctemp.tf` | EC2 Launch Templates (recommended to rename to `launchtemplate.tf`). |
| `bastionserver.tf` | Bastion host setup for secure SSH into private instances. |


## autoscalling.tf

```hcl
# Autoscaling Group for Frontend Servers
resource "aws_autoscaling_group" "frontend-asg" {
  name_prefix = "frontend-asg"  # The prefix for the Auto Scaling Group's name.
  desired_capacity   = 1  # The initial number of instances to be launched (1 instance).
  max_size           = 1  # The maximum number of instances allowed in the ASG.
  min_size           = 1  # The minimum number of instances that should be running in the ASG.
  
  # VPC Subnets in which the instances should be launched.
  vpc_zone_identifier = [aws_subnet.prvt3.id, aws_subnet.prvt4.id]  # Subnets for the Auto Scaling Group.

  # Target Group for the Load Balancer to route traffic to the instances.
  target_group_arns = [aws_lb_target_group.front_end.arn]  # Target Group ARN for frontend instances.
  
  health_check_type = "EC2"  # Health check type for Auto Scaling. EC2 health checks are used here.
  
  # Launch Template defines the configuration for the instances.
  launch_template {
    id      = aws_launch_template.frontend.id  # The launch template for the frontend instances.
    version = aws_launch_template.frontend.latest_version  # The latest version of the launch template.
  }

  # Instance Refresh settings help apply changes to the Auto Scaling Group.
  instance_refresh {
    strategy = "Rolling"  # The refresh strategy (Rolling means replacing instances gradually).
    preferences {
      min_healthy_percentage = 50  # Minimum percentage of healthy instances during a refresh.
    }
    triggers = [ /*"launch_template",*/ "desired_capacity" ]  # Trigger an instance refresh when the desired capacity changes.
  }
  
  # Tagging the Auto Scaling Group with the Name 'frontend-asg' for identification.
  tag {
    key                 = "Name"  # Tag key.
    value               = "frontend-asg"  # Tag value.
    propagate_at_launch = true  # Propagate this tag to the instances created by this ASG.
  }
}

#####################################################################
# Autoscaling Group for Backend Servers
resource "aws_autoscaling_group" "backend-asg" {
  name_prefix = "backend-asg"  # The prefix for the Auto Scaling Group's name.
  desired_capacity   = 1  # The initial number of instances to be launched (1 instance).
  max_size           = 1  # The maximum number of instances allowed in the ASG.
  min_size           = 1  # The minimum number of instances that should be running in the ASG.
  
  # VPC Subnets in which the instances should be launched.
  vpc_zone_identifier = [aws_subnet.prvt5.id, aws_subnet.prvt6.id]  # Subnets for the Auto Scaling Group.
  
  # Target Group for the Load Balancer to route traffic to the instances.
  target_group_arns = [aws_lb_target_group.back_end.arn]  # Target Group ARN for backend instances.

  health_check_type = "EC2"  # Health check type for Auto Scaling. EC2 health checks are used here.
  
  # Launch Template defines the configuration for the instances.
  launch_template {
    id      = aws_launch_template.backend.id  # The launch template for the backend instances.
    version = aws_launch_template.backend.latest_version  # The latest version of the launch template.
  }

  # Instance Refresh settings help apply changes to the Auto Scaling Group.
  instance_refresh {
    strategy = "Rolling"  # The refresh strategy (Rolling means replacing instances gradually).
    preferences {
      min_healthy_percentage = 50  # Minimum percentage of healthy instances during a refresh.
    }
    triggers = [ /*"launch_template",*/ "desired_capacity" ]  # Trigger an instance refresh when the desired capacity changes.
  }

  # Tagging the Auto Scaling Group with the Name 'backend-asg' for identification.
  tag {
    key                 = "Name"  # Tag key.
    value               = "backend-asg"  # Tag value.
    propagate_at_launch = true  # Propagate this tag to the instances created by this ASG.
  }
}
```


## launctemp.tf

```hcl
# ------------------------- Frontend AMI Data Source -------------------------
data "aws_ami" "example" { 
  most_recent = true  # Fetch the most recent AMI.
  owners      = ["self"]  # Fetch AMIs owned by your account.

  filter {
    name   = "name"  # Filter by name.
    values = ["frontend-ami"]  # Look for AMIs with the name pattern "frontend-ami".
  }
}

# ------------------------- Frontend Launch Template -------------------------
resource "aws_launch_template" "frontend" {
  name        = "frontend-terraform"  # Name of the frontend launch template.
  description = "frontend-terraform"  # Description of the template.
  image_id    = data.aws_ami.example.id  # Reference the fetched AMI ID.
  instance_type = "t2.micro"  # Type of EC2 instance.
  vpc_security_group_ids = [aws_security_group.frontend-server-sg.id]  # Security group ID.
  key_name = "us-east-1"  # SSH key pair name.
  user_data = filebase64("${path.module}/frontend-lt.sh")  # Base64-encoded user data.
  update_default_version = true  # Set this as the default version of the launch template.

  tag_specifications {
    resource_type = "instance"  # Apply tags to EC2 instances.
    tags = {
      Name = "frontend-terraform"  # Set the "Name" tag to "frontend-terraform".
    }
  }
}

# ------------------------- Backend AMI Data Source -------------------------
data "aws_ami" "example1" {
  most_recent = true  # Fetch the most recent AMI.
  owners      = ["self"]  # Fetch AMIs owned by your account.

  filter {
    name   = "name"  # Filter by name.
    values = ["backend-ami"]  # Look for AMIs with the name pattern "backend-ami".
  }
}

# ------------------------- Backend Launch Template -------------------------
resource "aws_launch_template" "backend" {
  name        = "backend-terraform"  # Name of the backend launch template.
  description = "backend-terraform"  # Description of the template.
  image_id    = data.aws_ami.example1.id  # Reference the fetched AMI ID for the backend.
  instance_type = "t2.micro"  # Type of EC2 instance.
  vpc_security_group_ids = [aws_security_group.backend-server-sg.id]  # Security group ID.
  key_name = "us-east-1"  # SSH key pair name.
  user_data = filebase64("${path.module}/backend-lt.sh")  # Base64-encoded user data for backend instances.
  update_default_version = true  # Set this as the default version of the launch template.

  tag_specifications {
    resource_type = "instance"  # Apply tags to EC2 instances.
    tags = {
      Name = "backend-terraform"  # Set the "Name" tag to "backend-terraform".
    }
  }
}

```


## bastionserver.tf

```hcl

# ------------------------- Bastion Host EC2 Instance -------------------------

resource "aws_instance" "back" {
  ami           = var.ami                      # AMI ID for the instance, passed in as a variable (e.g., Amazon Linux 2 AMI).
  instance_type = var.instance-type            # EC2 instance type (e.g., t2.micro), passed as a variable.
  key_name      = var.key-name                 # Name of the SSH key pair to connect to the instance.

  subnet_id = aws_subnet.pub1.id               # The instance will be launched in the specified public subnet.

  vpc_security_group_ids = [                   # Attach security group(s) to the instance.
    aws_security_group.bastion-host.id         # Security group allowing SSH access, defined elsewhere.
  ]

  tags = {                                     # Tags to identify and manage the instance.
    Name = "bastion-server"                    # Assign a "Name" tag to the instance.
  }
}


```
---
### 🎛️ Load Balancers

| File | Description |
|------|-------------|
| `frontend-tg&lb.tf` | Load Balancer and Target Group for front-end services. |
| `backend-tg&lb.tf` | Load Balancer and Target Group for back-end services. |

## frontend-tg&lb.tf

```hcl
# ------------------------- Target Group for Frontend -------------------------
resource "aws_lb_target_group" "front_end" {
  name     = "frontend-tg"                     # Name of the target group.
  port     = 80                                # Port on which targets receive traffic (HTTP).
  protocol = "HTTP"                            # Protocol used for routing traffic.
  vpc_id   = aws_vpc.three-tier.id             # VPC in which the target group is created.
  depends_on = [ aws_vpc.three-tier ]          # Ensure the VPC is created before the target group.
}

# ------------------------- Application Load Balancer for Frontend -------------------------
resource "aws_lb" "front_end" {
  name               = "frontend-alb"                     # Name of the Application Load Balancer.
  internal           = false                              # false = internet-facing; true = internal.
  load_balancer_type = "application"                      # Type of load balancer (application = ALB).
  security_groups    = [aws_security_group.alb-frontend-sg.id]  # Attach security group allowing HTTP/HTTPS traffic.
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id] # ALB will be deployed in these public subnets.

  tags = {
    Name = "ALB-Frontend"                                 # Tag for easy identification.
  }

  depends_on = [ aws_lb_target_group.front_end ]          # Ensure target group is created before the ALB.
}

# ------------------------- Listener for Frontend ALB (Port 80 - HTTP) -------------------------
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn                # Reference to the ALB created above.
  port              = "80"                                # Listener port.
  protocol          = "HTTP"                              # Listener protocol.

  default_action {
    type             = "forward"                          # Action type: forward requests to a target group.
    target_group_arn = aws_lb_target_group.front_end.arn  # Reference to the target group.
  }

  depends_on = [ aws_lb_target_group.front_end ]          # Ensure target group exists before the listener.
}

# ------------------------- Optional HTTPS Listener (commented out) -------------------------
# resource "aws_lb_listener" "front_end2" {
#   load_balancer_arn = aws_lb.front_end.arn              # Reference to the ALB.
#   port              = "443"                              # Listener port for HTTPS.
#   protocol          = "HTTPS"                            # Protocol.
#   ssl_policy        = "ELBSecurityPolicy-2016-08"        # Security policy for SSL.
#   certificate_arn   = aws_acm_certificate.cert.arn       # ARN of the SSL certificate from ACM.
# 
#   default_action {
#     type             = "forward"                         # Forward HTTPS requests.
#     target_group_arn = aws_lb_target_group.front_end.arn# To this target group.
#   }
#   depends_on = [ aws_lb_target_group.front_end ]         # Ensure TG is created before listener.
# }

```


## backend-tg&lb.tf
```hcl
# -------------------------- Target Group for Backend --------------------------
resource "aws_lb_target_group" "back_end" { 
  name     = "backend-tg"                         # Name of the backend target group.
  port     = 80                                   # Port that the targets will receive traffic on.
  protocol = "HTTP"                               # Protocol used for communication with targets.
  vpc_id   = aws_vpc.three-tier.id                # The VPC where the target group will be created.
  depends_on = [ aws_vpc.three-tier ]             # Make sure the VPC is created before this resource.
}

# -------------------------- Application Load Balancer for Backend --------------------------
resource "aws_lb" "back_end" {
  name               = "backend-alb"                          # Name of the ALB for backend traffic.
  internal           = false                                  # false = internet-facing; true = internal-only.
  load_balancer_type = "application"                          # Type of load balancer (ALB).
  security_groups    = [aws_security_group.alb-backend-sg.id] # Attach the security group that allows HTTP/HTTPS.
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id] # ALB spans across two public subnets.

  depends_on = [ aws_lb_target_group.back_end ]               # Ensure target group exists before ALB.

  tags = {
    Name = "ALB-backend"                                      # Tag for the ALB resource.
  }
}

# -------------------------- Listener for Backend ALB (Port 80 - HTTP) --------------------------
resource "aws_lb_listener" "back_end" {
  load_balancer_arn = aws_lb.back_end.arn                     # ARN of the ALB that this listener belongs to.
  port              = "80"                                    # Port for the listener.
  protocol          = "HTTP"                                  # Listener protocol is HTTP.

  default_action {
    type             = "forward"                              # Default action is to forward traffic.
    target_group_arn = aws_lb_target_group.back_end.arn       # Forward to the backend target group.
  }

  depends_on = [ aws_lb_target_group.back_end ]               # Ensure the target group is ready before listener.
}

# -------------------------- Optional HTTPS Listener (Commented Out) --------------------------
# resource "aws_lb_listener" "back_end2" {
#   load_balancer_arn = aws_lb.back_end.arn                   # Use the same ALB as above.
#   port              = "443"                                 # HTTPS port.
#   protocol          = "HTTPS"                               # Protocol is HTTPS.
#   ssl_policy        = "ELBSecurityPolicy-2016-08"           # SSL security policy.
#   certificate_arn   = aws_acm_certificate.cert.arn          # ACM certificate ARN for SSL termination.

#   default_action {
#     type             = "forward"                            # Forward HTTPS traffic.
#     target_group_arn = aws_lb_target_group.back_end.arn     # To backend target group.
#   }

#   depends_on = [ aws_lb_target_group.back_end ]             # Ensure TG is available before listener.
# }

```
---
### 💾 Database

| File | Description |
|------|-------------|
| `rds.tf` | AWS RDS instance provisioning (e.g., MySQL/PostgreSQL database). |

## rds.tf
```hcl
# -------------------------- RDS MySQL Database Instance --------------------------
resource "aws_db_instance" "rds" {
  allocated_storage      = 20                            # Storage size in GB.
  identifier             = "book-rds"                    # Unique name/identifier for the RDS instance.
  db_subnet_group_name   = aws_db_subnet_group.sub-grp.id # Subnet group where RDS will be deployed.
  engine                 = "mysql"                       # RDS database engine (MySQL in this case).
  engine_version         = "8.0.32"                      # Specific MySQL engine version.
  instance_class         = "db.t3.micro"                 # Instance size (suitable for small dev/test workloads).
  multi_az               = true                          # Enables Multi-AZ deployment for high availability.
  db_name                = "mydb"                        # Name of the initial database to create.
  username               = var.rds-username              # Master username (sourced from variables).
  password               = var.rds-password              # Master password (sourced from variables).
  skip_final_snapshot    = true                          # Skip final snapshot on deletion (use with caution!).
  vpc_security_group_ids = [aws_security_group.book-rds-sg.id] # Attach security group for RDS access control.
  depends_on             = [ aws_db_subnet_group.sub-grp ]     # Ensure the subnet group is created before RDS.
  publicly_accessible    = false                         # Make sure the DB is not accessible from the public internet.
  backup_retention_period = 7                            # Number of days to retain automatic backups.

  tags = {
    DB_identifier = "book-rds"                           # Tag for easy identification.
  }
}

# -------------------------- Subnet Group for RDS --------------------------
resource "aws_db_subnet_group" "sub-grp" {
  name       = "main"                                    # Name of the subnet group.
  subnet_ids = [aws_subnet.prvt7.id, aws_subnet.prvt8.id] # Private subnets for RDS placement.
  depends_on = [ aws_subnet.prvt7, aws_subnet.prvt8 ]    # Ensure the subnets exist before creating the group.

  tags = {
    Name = "My DB subnet group"                          # Tag for easier tracking in the console.
  }
}


```

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



## 📌 Notes

- ✅ Make sure AWS credentials are configured before running Terraform.
- ⚠️ File `launctemp.tf` may contain a typo — consider renaming to `launchtemplate.tf` for clarity.
- 💬 Use modularization for better reuse if the infrastructure grows.

---

## 📞 Contact

For feedback, suggestions, or questions, feel free to reach out to the project maintainer.
