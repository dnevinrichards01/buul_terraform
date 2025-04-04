locals {
  db_name_port_host = {
    name = aws_db_instance.postgres.db_name
    port = aws_db_instance.postgres.port
    host = aws_db_instance.postgres.address
  }
}