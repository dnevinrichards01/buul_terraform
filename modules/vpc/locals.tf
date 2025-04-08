locals {
  az_map = zipmap(range(length(var.azs)), var.azs)
  alb_subnet_ids = [
    for index, az in var.azs :
    module.subnets_by_az[tostring(index)].alb_subnet_id
  ]
  app_subnet_ids = [
    for index, az in var.azs :
    module.subnets_by_az[tostring(index)].app_subnet_id
  ]
  data_subnet_ids = [
    for index, az in var.azs :
    module.subnets_by_az[tostring(index)].data_subnet_id
  ]
  interface_services = ["kms", "secretsmanager", "ecr.api", "ecr.dkr", "sqs"]
  ssm_interface_services = ["ssm", "ssmmessages", "ec2messages"]
  vpce_ids = merge(
    {
      for key, ep in aws_vpc_endpoint.interface :
      key => ep.id
    }, 
    {
      for key, ep in aws_vpc_endpoint.interface_ssm :
      key => ep.id
    }
  )
}

