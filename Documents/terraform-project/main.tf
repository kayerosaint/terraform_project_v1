provider "aws" {
  region = "eu-west-3"
}
#connect elastic ip to instance
resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_webserver.id #look output
  tags = {
    Name       = "Static IP"
    Owner      = var.owner
    Project    = local.full_project_name
    proj_owner = local.project_owner
    city       = local.city
    region_azs = local.az_list
    location   = local.location
  }
}

resource "aws_instance" "my_webserver" {
  #count                 = 1
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = var.instance_type
  monitoring             = var.enable_detailed_monitoring
  vpc_security_group_ids = ["aws_security_group.my_webserver.id"]
  user_data              = file("install.sh")
  #user_data = templatefile("install.sh.tftpl", { #template if needed
  #  f_name = "Maksim",
  #  l_name = "Kulikov",
  #  names  = ["Daniel", "Aynur", "Andrej"]

  tags = {
    Name  = "Web Server Terraform"
    Owner = "MaksK"
  }
  # dependencies "aws_instance" "my_server_db"
  //depends_on = [aws_instance.my_server_db]
  # new instance first
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "my_webserver" {
  name        = "WebServer Security Group"
  description = "Allow all inbound traffic"

  dynamic "ingress" {
    # ports from cycle
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #-1 any
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Web Server Terraform"
    Owner = "MaksK"
  }
}

#---------------------------------------------------

# create subnet
resource "aws_subnet" "prod_subnet_1" {
  vpc_id            = data.aws_vpc.prod_vpc.id
  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.10.1.0/24" #change it in VPC AWS
  tags = {
    name    = "Subnet in ${data.aws_availability_zones.working.names[0]}"
    account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    region  = data.aws_region.current.description
  }
}

#----------------------------------------------------
# autoscaling

resource "aws_autoscaling_group" "my_webserver" {
  name                 = "ASG-${aws_instance.my_webserver.key_name}"
  launch_configuration = aws_instance.my_webserver.key_name
  min_size             = 2 # instance count
  max_size             = 2 # instance count
  min_elb_capacity     = 2 # submit that servers is OK
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.my_webserver.name]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      Owner  = "MaksK"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
# create load_balancers

resource "aws_elb" "my_webserver" {
  name               = "WebServer-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.my_webserver.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-ELB"
  }
}

#------------------------------------------
#generate password

resource "random_string" "rds_password" {
  length  = 12
  special = true
  # override_special allowed
  override_special = "!#$&"
  # keeper - if need change password
  keepers = {
    kepeer1 = var.name
    //keperr2 = var.something
  }
}

# place for SSM Parameter STORE
resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  # SecureString - secure pass
  type  = "SecureString"
  value = random_string.rds_password.result
}

# password into RDS (database)
resource "aws_db_instance" "default" {
  identifier           = "prod-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "mydb"
  username             = "administrator"
  password             = data.aws_ssm_parameter.my_rds_password.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
}
