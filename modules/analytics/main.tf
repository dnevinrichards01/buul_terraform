resource "aws_key_pair" "my_key" {
  key_name   = "${var.environment}-analytics_ec2"
  public_key = file("~/.ssh/test-analytics-ec2.pub")
}
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "analytics" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.app_subnet_id
  vpc_security_group_ids      = [var.sg_analytics_id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = false 
  iam_instance_profile = aws_iam_instance_profile.ec2_analytics.name

  metadata_options {
    http_endpoint               = "enabled"   # enable metadata service
    http_tokens                 = "required"  # require IMDSv2
    http_put_response_hop_limit = 2           # optional: controls response forwarding
  }

  tags = {
    Name = "${var.environment}-analytics-ec2"
  }
}
resource "aws_iam_instance_profile" "ec2_analytics" {
  name = "${var.environment}-ec2-analytics-profile"
  role = var.ec2_analytics_role_name
}


resource "aws_db_instance" "analytics" {
  identifier              = local.db_name
  engine                  = "postgres"
  engine_version          = "16.4"
  instance_class          = "db.t3.small"
  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_type            = "gp2"
  storage_encrypted = true
  multi_az                = false
  db_name                 = local.db_name
  username                = var.analytics_db_master_username
  password                = var.analytics_db_master_password
  port                    = 5432
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false//true
  vpc_security_group_ids  = [var.sg_analyticsdb_id]
  db_subnet_group_name    = aws_db_subnet_group.analytics.name
  backup_retention_period = 7
  backup_window            = "06:00-07:00"

  //sg?

  //lifecycle {
  //  prevent_destroy = true
  //}
}
resource "aws_db_subnet_group" "analytics" {
  name       = "${var.environment}-analytics-subnet-group"
  subnet_ids = var.data_subnet_ids
}


resource "aws_dms_replication_instance" "analytics" {
  replication_instance_id        = "${var.environment}-dms"
  replication_instance_class     = "dms.t3.micro"
  allocated_storage              = 20
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  publicly_accessible            = false
  multi_az                       = false
  //availability_zone            = "us-west-1a"
  network_type = "DUAL"
  replication_subnet_group_id = aws_dms_replication_subnet_group.ec2_analytics.id

  depends_on = [
    aws_iam_role_policy_attachment.analytics_dms
  ]
} 
resource "aws_dms_replication_subnet_group" "ec2_analytics" {
  replication_subnet_group_description = "replication subnet group"
  replication_subnet_group_id          = "${var.environment}-analytics-dms-subnet-group-tf"
  subnet_ids = var.data_subnet_ids
}
resource "aws_iam_role" "analytics_dms_vpc_role" {
  name = "dms-vpc-role"

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
resource "aws_iam_role_policy_attachment" "analytics_dms" {
  role       = aws_iam_role.analytics_dms_vpc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

resource "aws_dms_endpoint" "source" {
  endpoint_id               = "${var.environment}-dms-source"
  endpoint_type             = "source"
  engine_name               = "postgres"
  server_name               = var.db_name_port_host["host"]
  port                      = var.db_name_port_host["port"]
  database_name             = var.db_name_port_host["name"]
  username                  = var.analytics_db_user_username
  password                  = var.analytics_db_user_password
}
resource "aws_dms_endpoint" "target" { // create the db here
  endpoint_id               = "${var.environment}-dms-target"
  endpoint_type             = "target"
  engine_name               = "postgres"
  server_name               = aws_db_instance.analytics.address
  port                      = 5432
  database_name             = local.db_name
  username                = var.analytics_db_master_username
  password                = var.analytics_db_master_password
}
resource "aws_dms_replication_task" "example" {
  replication_task_id          = "${var.environment}-main-to-analytics-db"
  migration_type               = "cdc"
  replication_instance_arn     = aws_dms_replication_instance.analytics.replication_instance_arn
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
          "table-name"  = "api_loganon"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "2"
        "rule-name"    = "2"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "rh_loganon"
        }
        "rule-action" = "include"
      },
      {
        "rule-type"    = "selection"
        "rule-id"      = "3"
        "rule-name"    = "3"
        "object-locator" = {
          "schema-name" = "public"
          "table-name"  = "api_loganoninvestments"
        }
        "rule-action" = "include"
      }
    ]
  })
}

