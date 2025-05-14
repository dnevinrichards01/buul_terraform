resource "aws_db_instance" "postgres" {
  identifier              = "${var.environment}db"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.small"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted = true
  multi_az                = true
  db_name                 = "${var.environment}db"
  username                = var.db_username_final
  password                = var.db_password_final
  port                    = 5432
  publicly_accessible     = false
  deletion_protection     = false//true
  vpc_security_group_ids  = [var.data_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.postgres.name
  backup_retention_period = 7
  backup_window            = "06:00-07:00"

  skip_final_snapshot = true

  //lifecycle {
  //  prevent_destroy = true
  //}
}
resource "aws_db_subnet_group" "postgres" {
  name       = "${var.environment}-postgres-subnet-group"
  subnet_ids = var.data_subnet_ids
}


resource "aws_db_instance" "proxy" {
  identifier              = "${var.environment}proxydb"
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.small"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted = true
  multi_az                = true
  db_name                 = "${var.environment}proxydb"
  username                = var.proxy_db_user_username
  password                = var.proxy_db_user_password
  port                    = 5432
  publicly_accessible     = false
  deletion_protection     = false//true
  vpc_security_group_ids  = [var.data_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.proxy.name
  backup_retention_period = 7
  backup_window            = "06:00-07:00"

  skip_final_snapshot = true

  //lifecycle {
  //  prevent_destroy = true
  //}
}
resource "aws_db_subnet_group" "proxy" {
  name       = "${var.environment}-proxy-subnet-group"
  subnet_ids = var.data_subnet_ids
}


resource "aws_dms_endpoint" "source" {
  endpoint_id               = "${var.environment}-proxy-dms-source"
  endpoint_type             = "source"
  engine_name               = "postgres"
  server_name               = local.db_name_port_host["host"]
  port                      = local.db_name_port_host["port"]
  database_name             = local.db_name_port_host["name"]
  username                  = var.db_username_final
  password                  = var.db_password_final
}
resource "aws_dms_endpoint" "target" { // create the db here
  endpoint_id               = "${var.environment}-proxy-dms-target"
  endpoint_type             = "target"
  engine_name               = "postgres"
  server_name               = local.proxy_db_name_port_host["host"]
  port                      = local.proxy_db_name_port_host["port"]
  database_name             = local.proxy_db_name_port_host["name"]
  username                  = var.proxy_db_user_username
  password                  = var.proxy_db_user_password
}

resource "aws_dms_replication_instance" "proxy" {
  replication_instance_id        = "${var.environment}-proxy-dms"
  replication_instance_class     = "dms.t3.micro"
  allocated_storage              = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  publicly_accessible            = false
  multi_az                       = false
  //availability_zone            = "us-west-1a"
  network_type = "DUAL"
  replication_subnet_group_id = aws_dms_replication_subnet_group.proxy.id

  depends_on = [
    aws_iam_role_policy_attachment.proxy_dms
  ]
} 
resource "aws_dms_replication_subnet_group" "proxy" {
  replication_subnet_group_description = "replication subnet group"
  replication_subnet_group_id          = "${var.environment}-proxy-dms-subnet-group"
  subnet_ids = var.data_subnet_ids
}


resource "aws_iam_role" "proxy_dms_vpc_role" {
  name = "${var.environment}-proxy-dms-vpc-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [{
      Effect = "Allow",
      Principal = {
        Service = "dms.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "proxy_dms" {
  role       = aws_iam_role.proxy_dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}


resource "aws_dms_replication_task" "example" {
  replication_task_id          = "${var.environment}-main-to-proxy-db"
  migration_type               = "cdc"
  replication_instance_arn     = aws_dms_replication_instance.proxy.replication_instance_arn
  source_endpoint_arn          = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn          = aws_dms_endpoint.target.endpoint_arn
  // replication_task_settings    = file("dms-settings.json")

  table_mappings = jsonencode({
    rules: [
      {
        "rule-type"    = "selection"
        "rule-id"      = "1"
        "rule-name"    = "1"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "api_plaiditem"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "2"
        "rule-name"    = "2"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "robin_stocks_userrobinhoodinfo"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "3"
        "rule-name"    = "3"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "api_plaidcashbacktransaction"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "4"
        "rule-name"    = "4"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "api_deposit"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "5"
        "rule-name"    = "5"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "api_investment"
        }
        "rule-action" = "include"
      }
    ]
  })
}

