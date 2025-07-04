// CodeBuild → Settings → Source credentials → Connect GitHub
// sets up the OAuth token AWS CodeBuild uses to access GitHub. 
// You only need to do it once per region/account.

resource "aws_codebuild_project" "project" {
  for_each = toset(local.containers)

  name          = "${var.environment}-${each.key}-codebuild"
  build_timeout = 7
  service_role  = var.role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/dnevinrichards01/accumate_backend.git"
    buildspec = "build_files/buildspec_${each.key}.yml"
    auth {
      type     = "CODECONNECTIONS"
      resource = aws_codestarconnections_connection.github.arn
    }
  }

  source_version = "prod"

  tags = {
    Environment = var.environment
    Container   = each.value
  }
}

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.environment}-github-connection"
  provider_type = "GitHub"
}

