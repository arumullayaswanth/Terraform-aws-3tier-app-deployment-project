
# Creating a security group for Bastion Host
resource "aws_security_group" "bastion-host" {
  name        = "appserver-SG"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier ]

  # Inbound rule allowing SSH access (port 22) from anywhere (0.0.0.0/0)
 ingress {
    description     = "Allow traffic from web layer"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-host-server-sg"
  }
  
}

# Creating a security group for the frontend ALB (Application Load Balancer)
resource "aws_security_group" "alb-frontend-sg" {
  name        = "alb-frontend-sg"
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier ]

# Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
 ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound rule allowing HTTPS (port 443) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-frontend-sg"
  }
  
}


# Creating a security group for the backend ALB (Application Load Balancer)
resource "aws_security_group" "alb-backend-sg" {
  name        = "alb-backend-sg"
  description = "Allow inbound traffic ALB"
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier ]

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
 ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule allowing HTTPS (port 443) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-backend-sg"
  }

}

# Creating a security group for the frontend server
resource "aws_security_group" "frontend-server-sg" {
  name        = "frontend-server-sg"
  description = "Allow inbound traffic "
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier,aws_security_group.alb-frontend-sg ]

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
 ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound rule allowing SSH (port 22) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "frontend-server-sg"
  }

}


# Creating a security group for the backend server
resource "aws_security_group" "backend-server-sg" {
  name        = "backend-server-sg"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier,aws_security_group.alb-backend-sg ]

  # Inbound rule allowing HTTP (port 80) traffic from anywhere (0.0.0.0/0)
 ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound rule allowing SSH (port 22) traffic from anywhere (0.0.0.0/0)
  ingress {
    description     = "ssh"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend-server-sg"
  }
}


# Creating a security group for the RDS (database)
resource "aws_security_group" "book-rds-sg" {
  name        = "book-rds-sg"
  description = "Allow inbound "
  vpc_id      = aws_vpc.three-tier.id
  depends_on = [ aws_vpc.three-tier ]

 ingress {
    description     = "mysql/aroura"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
 }
  # Outbound rule allowing all traffic (0.0.0.0/0) to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "book-rds-sg"
  }

}
