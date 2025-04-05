locals {
  alb_dns_names = {
    us-west-1 = contains(var.regions, "us-west-1") ? module.region_us_west_1[0].alb_dns_name : null,
    us-west-2 = contains(var.regions, "us-west-2") ? module.region_us_west_2[0].alb_dns_name : null,
  }
  alb_zone_ids = {
    us-west-1 = contains(var.regions, "us-west-1") ? module.region_us_west_1[0].alb_zone_id : null,
    us-west-2 = contains(var.regions, "us-west-2") ? module.region_us_west_2[0].alb_zone_id : null,
  }
}