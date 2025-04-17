# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "k8s_cluster_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name                                  = "K8s-cluster-vpc"
    "kubernetes.io/cluster/kubernetes"   = "owned"
  }
}

# Subnet
resource "aws_subnet" "k8s_cluster_subnet" {
  vpc_id                  = aws_vpc.k8s_cluster_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                  = "K8s-cluster-net"
    "kubernetes.io/cluster/kubernetes"   = "owned"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id

  tags = {
    Name                                  = "k8s-cluster-igw"
    "kubernetes.io/cluster/kubernetes"   = "owned"
  }
}

# Route Table
resource "aws_route_table" "k8s_route_table" {
  vpc_id = aws_vpc.k8s_cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name                                  = "K8s-cluster-rtb"
    "kubernetes.io/cluster/kubernetes"   = "owned"
  }
}

# Route Table Association
resource "aws_route_table_association" "k8s_rtb_association" {
  subnet_id      = aws_subnet.k8s_cluster_subnet.id
  route_table_id = aws_route_table.k8s_route_table.id
}

# Security Group
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-cluster-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.k8s_cluster_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-cluster-sg"
  }
}

# EC2 Instance (Master Node)
resource "aws_instance" "k8s_master" {
  ami                    = "ami-0f9de6e2d2f067fca"  # Replace with your desired AMI ID (e.g., Ubuntu)
  instance_type          = "t2.medium"     # Adjust as necessary
  subnet_id              = aws_subnet.k8s_cluster_subnet.id
  key_name               = "k8"  # Replace with your actual key pair name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "K8s-Master"
  }
}

