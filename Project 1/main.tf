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


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
