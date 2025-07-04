output "codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "ecs_task_role_arns" {
  value = local.ecs_task_role_arns
}

output "flow_logs_role_arn" {
  value = aws_iam_role.flow_logs_role.arn
}

output "firehose_delivery_role_arn" {
  value = aws_iam_role.firehose_delivery_role.arn
}

//output "ec2_analytics_role_name" {
//    value = aws_iam_role.analytics_ec2.name
//}

//output "analytics_ec2_role_arn" {
//    value = aws_iam_role.analytics_ec2.arn
//}

