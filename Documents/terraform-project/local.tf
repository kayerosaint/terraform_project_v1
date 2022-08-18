locals {
  full_project_name = "${var.environment}-${var.project_name}"
  project_owner     = "${var.owner} owner of ${var.project_name}"
}

locals {
  country = "Russia"
  city    = "Neftekamsk"
  #join list in string (“,”)
  az_list  = join(",", data.aws_availability_zones.available.names)
  region   = data.aws_region.current.description
  location = "In ${local.region} there are Av.Zones: ${local.az_list}"
}
