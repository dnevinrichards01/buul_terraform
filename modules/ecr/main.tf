resource "aws_ecr_repository" "repos" {
  for_each = toset(local.repos)
  name     = "${var.environment}-${each.value}"

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
