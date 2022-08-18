data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

#for data source find
data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_vpcs" "my_vpcs" {}
data "aws_vpc" "prod_vpc" {
  tags = {
    Name = "prod"
  }
}

#look for ami
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#take pass from ssm output
// password from SSM Parameter Store
data "aws_ssm_parameter" "my_rds_password" {
  name       = "/prod/mysql"
  depends_on = [aws_ssm_parameter.rds_password]
}
