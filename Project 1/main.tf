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

# 3. Create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# 4. Create subnets
resource "aws_subnet" "subnet-01" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# 5. Assciate  subnet with Route Table
resource "aws_route_table_association" "art" {
  subnet_id = aws_subnet.subnet-01.id
  route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22, 80 and 443 
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id     = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" # any prtocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a Network Interface with an IP address in the subnet that was created
resource "aws_network_interface" "web-server-01" {
  subnet_id = " aws_subnet.subnet-01.id"
  private_ips = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  }

# 8. Assign an Elastic IP address to the Network Interface 
resource "aws_eip" "es" {
  network_interface = "aws_network_interface.web-server-01.id"
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

# 9. Create Ubuntu Servet and  install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami = "ami-df5de72bdb3b"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-01.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo web server > /var/www/html/index.html'
              EOF

  tags = {
    Name = "web-server"
  }
}

