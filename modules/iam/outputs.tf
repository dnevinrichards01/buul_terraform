output "codebuild_role_arn" {
    value = aws_iam_role.codebuild_role.arn
}

output "ecs_task_role_arns" {
    value = local.ecs_task_role_arns
}