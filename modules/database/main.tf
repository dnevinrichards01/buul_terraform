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
  skip_final_snapshot     = true
  deletion_protection     = true
  vpc_security_group_ids  = [var.data_security_group_id]
  db_subnet_group_name    = aws_db_subnet_group.postgres.name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${var.environment}-postgres-subnet-group"
  subnet_ids = var.data_subnet_ids
}