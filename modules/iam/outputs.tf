output "codebuild_role_arn" {
    value = aws_iam_role.codebuild_role.arn
}

output "secret_policy_doc_json" { 
    value = data.aws_iam_policy_document.secret_policy_doc.json
}

output "ecs_task_role_arns" {
    value = local.ecs_task_role_arns
}
output "sqs_access_policy_doc_json" { 
    value = local.queue_policy_jsons
}