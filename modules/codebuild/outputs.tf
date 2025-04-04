output "codebuild_arns" {
  value = {
    for container in local.containers : 
    container => aws_codebuild_project.project[container].arn
  }
}

output "codeconnection_arn" {
  value = aws_codestarconnections_connection.github.arn
}