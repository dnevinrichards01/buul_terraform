locals {
    redis_no_cluster_host_port_url = {
        host = aws_elasticache_replication_group.redis_no_cluster.primary_endpoint_address,
        port = aws_elasticache_replication_group.redis_no_cluster.port,
        url = "${aws_elasticache_replication_group.redis_no_cluster.primary_endpoint_address}:${aws_elasticache_replication_group.redis_no_cluster.port}"
    }
}