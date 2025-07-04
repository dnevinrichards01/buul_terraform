output "monitoring_logs_bucket_arn" {
  value = aws_s3_bucket.regional_logs.arn
}

output "monitoring_logs_bucket_id" {
  value = aws_s3_bucket.regional_logs.id
}
