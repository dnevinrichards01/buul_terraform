resource "aws_elasticache_replication_group" "redis_no_cluster" {
  replication_group_id          = "${var.environment}-redis-no-cluster"
  description = "primary cluster with replication for all AZs"
  node_type                     = "cache.t3.small"
  num_cache_clusters         = length(data.aws_availability_zones.available.names)
  automatic_failover_enabled    = true
  multi_az_enabled              = true

  engine                        = "redis"
  engine_version                = "7.1"
  parameter_group_name          = "default.redis7"
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis_no_cluster.name
  security_group_ids            = [var.data_security_group_id]

  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = true

  //lifecycle {
  // prevent_destroy = true
  //}
}

resource "aws_elasticache_subnet_group" "redis_no_cluster" {
  name       = "${var.environment}-redis-no-cluster-subnets"
  subnet_ids = var.data_subnet_ids
}

data "aws_availability_zones" "available" {
  state = "available"
}
