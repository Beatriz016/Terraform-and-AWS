provider "aws" {
    region = "us-east-1"
    access_key = "raindrops" 
    secret_key = "cumulonimbus"
    # Necessary for LocalStack
    skip_credentials_validation = true         
    skip_metadata_api_check     = true         
    skip_requesting_account_id  = true         

    # LocalStack endpoints
    endpoints {
    sts = "http://localhost:4566"           
    ec2 = "http://localhost:4566"           
  }
}


# 1. Create VPC 
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# 3. Create public route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}
