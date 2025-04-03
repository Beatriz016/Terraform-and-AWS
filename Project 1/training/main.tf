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

resource "aws_subnet" "subnet-01" {
  vpc_id = aws_vpc.vpc-01.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_vpc" "vpc-01" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

resource "aws_vpc" "vpc-02" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "development"
  }
}

resource "aws_subnet" "subnet-02" {
  vpc_id = aws_vpc.vpc-02.id
  cidr_block = "10.1.1.0/24"
  tags = {
    Name = "dev-subnet"
  }
}


# resource "aws_instance" "server-01" {
#     ami = "ami-df5de72bdb3b"
#     instance_type = "t2.micro"

#      tags = {
#        # Name = "ubuntu"
#      }
# }