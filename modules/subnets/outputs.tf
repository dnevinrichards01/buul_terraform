output "alb_subnet_id" {
  value = aws_subnet.alb.id
}

output "app_subnet_id" {
  value = aws_subnet.app.id
}

output "data_subnet_id" {
  value = aws_subnet.data.id
}