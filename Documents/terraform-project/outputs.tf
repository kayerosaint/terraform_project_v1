output "webserver_instance_id" {
  value = aws_instance.my_webserver.id
}
output "webserver_public_ip_address" {
  value = aws_eip.my_static_ip.public_ip
}
output "webserver_sg_ip" {
  value = aws_security_group.my_webserver.id
}
output "webserver_sg_arn" {
  value       = aws_security_group.my_webserver.arn
  description = "arn show"
}

#for data source find
output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}
output "data_aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}
output "data_aws_region_name" {
  value = data.aws_region.current.name
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}
output "aws_vpcs" {
  value = data.aws_vpcs.my_vpcs.ids
}
output "aws_vpc_id" {
  value = data.aws_vpc.prod_vpc.id
}
output "aws_vpc_cidr" {
  value = data.aws_vpc.prod_vpc.cidr_block
}

#password from ssm
output "rds_password" {
  value     = data.aws_ssm_parameter.my_rds_password.value
  sensitive = true
}
