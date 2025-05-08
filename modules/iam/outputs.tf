output "codebuild_role_arn" {
    value = aws_iam_role.codebuild_role.arn
}

output "ecs_task_role_arns" {
    value = local.ecs_task_role_arns
}

//output "ec2_analytics_role_name" {
//    value = aws_iam_role.analytics_ec2.name
//}

//output "analytics_ec2_role_arn" {
//    value = aws_iam_role.analytics_ec2.arn
//}

