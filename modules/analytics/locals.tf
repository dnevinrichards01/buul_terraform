locals {
    db_name = "${var.environment}analyticsdb"
    analytics_db_name_port_host = {
        name = local.db_name
        port = 5432
        host = aws_db_instance.analytics.address
    }
}