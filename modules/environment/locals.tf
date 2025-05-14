locals {
  alb_dns_names = {
    us-west-1 = contains(var.regions, "us-west-1") ? module.region_us_west_1[0].alb_dns_name : null,
    us-west-2 = contains(var.regions, "us-west-2") ? module.region_us_west_2[0].alb_dns_name : null,
  }
  alb_zone_ids = {
    us-west-1 = contains(var.regions, "us-west-1") ? module.region_us_west_1[0].alb_zone_id : null,
    us-west-2 = contains(var.regions, "us-west-2") ? module.region_us_west_2[0].alb_zone_id : null,
  }
  interface_services = [
    "kms", "secretsmanager", "ssm", //"ecr.api", "ecr.dkr"
    "ssmmessages", "ec2messages"
  ]
  vpce_ids = {
    for service in local.interface_services :
    service => compact([
      contains(var.regions, "us-west-1") ? module.region_us_west_1[0].vpce_ids[service] : null,
      contains(var.regions, "us-west-2") ? module.region_us_west_2[0].vpce_ids[service] : null,
    ])
  }
  ssm_kms_ids = compact([
    contains(var.regions, "us-west-1") ? module.region_us_west_1[0].ssm_kms_id : null,
    contains(var.regions, "us-west-2") ? module.region_us_west_2[0].ssm_kms_id : null,
  ])
  secret_kms_ids = compact([
    contains(var.regions, "us-west-1") ? module.region_us_west_1[0].secret_kms_id : null,
    contains(var.regions, "us-west-2") ? module.region_us_west_2[0].secret_kms_id : null,
  ])
  ecs_kms_arns = compact(flatten([
    contains(var.regions, "us-west-1") ? module.region_us_west_1[0].ecs_kms_arns : null,
    contains(var.regions, "us-west-2") ? module.region_us_west_2[0].ecs_kms_arns : null,
  ]))


  proxy_secret_kms_ids = compact([
    contains(var.regions, "us-west-1") ? module.region_us_west_1[0].proxy_secret_kms_id : null,
    contains(var.regions, "us-west-2") ? module.region_us_west_2[0].proxy_secret_kms_id : null,
  ])
  proxy_ssm_kms_ids = compact([
    contains(var.regions, "us-west-1") ? module.region_us_west_1[0].proxy_ssm_kms_id : null,
    contains(var.regions, "us-west-2") ? module.region_us_west_2[0].proxy_ssm_kms_id : null,
  ])
}