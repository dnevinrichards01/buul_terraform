resource "aws_ecr_repository" "repos" {
  for_each = toset(local.repos)
  name     = "${var.environment}-${each.value}"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  // may want to add environment and region tags everywhere to track costs by region and environment
  tags = {
    Name        = "${var.environment}-${each.value}"
    Environment = var.environment
    Image = each.value
  }
} 
data "aws_iam_policy_document" "resource_policy" {
  for_each      = toset(local.repos)
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    //condition {
    //  test     = "StringEquals"
    //  variable = "aws:sourceVpce"
    //  values   = [var.vpce_ids["ecr_api"], var.vpce_ids["ecr_dkr"]]
    //}
    resources = ["arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository:${var.environment}-${each.key}"]
  }
}

data "aws_caller_identity" "current" {}