output "repo_arns" {
  value = {
    for repo in local.repos :
    repo => aws_ecr_repository.repos[repo].arn
  }
}

output "repo_names" {
  value = {
    for repo in local.repos :
    repo => aws_ecr_repository.repos[repo].name
  }
}