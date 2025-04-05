resource "aws_route53_record" "alb_regional_routing" {
  for_each = toset(var.regions)

  zone_id = var.hosted_zone_id
  name    = "${var.environment}.${var.domain}" 
  set_identifier = "${var.environment}-${each.value}-alb" // becomes the record id 'tag'
  type    = "A"

  alias {
    name                   = var.alb_dns_names[each.value]
    zone_id                = var.alb_zone_ids[each.value]
    evaluate_target_health = true
  }

  latency_routing_policy {
    region = each.value
  }
}