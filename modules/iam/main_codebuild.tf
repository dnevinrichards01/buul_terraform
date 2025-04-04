resource "aws_iam_role" "codebuild_role" {
  name = "${var.environment}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "describe_task_definitions" {
  name        = "${var.environment}-codebuild-describe-task-definitions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = "ecs:DescribeTaskDefinition"
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_describe_task_definitions" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.describe_task_definitions.arn
}


data "aws_iam_policy_document" "codebuild_service_role_basics" {
  dynamic "statement" {
    for_each = local.container_region_pairs_map
    content {
      effect = "Allow"
      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      resources = [
        "arn:aws:logs:${statement.value.region}:${data.aws_caller_identity.current.account_id}:log-group:ecs/codebuild_${statement.value.container}",
        "arn:aws:logs:${statement.value.region}:${data.aws_caller_identity.current.account_id}:log-group:ecs/codebuild_${statement.value.container}:*",
        "arn:aws:logs:${statement.value.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.environment}-${statement.value.container}-codebuild",
        "arn:aws:logs:${statement.value.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.environment}-${statement.value.container}-codebuild:*"
      ]
    }
  }
  dynamic "statement" {
    for_each = local.container_region_pairs_map
    content {
      effect = "Allow"
      actions = [
        "codebuild:CreateReportGroup",
        "codebuild:CreateReport",
        "codebuild:UpdateReport",
        "codebuild:BatchPutTestCases",
        "codebuild:BatchPutCodeCoverages"
      ]
      resources = [
        "arn:aws:codebuild:${statement.value.region}:${data.aws_caller_identity.current.account_id}:report-group/${var.environment}-${statement.value.container}-codebuild-*"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::codepipeline-*"
    ]
  }
}
resource "aws_iam_policy" "codebuild_service_role_basics" {
  name        = "${var.environment}-codebuild-service-role-basics"
  policy = data.aws_iam_policy_document.codebuild_service_role_basics.json
}
resource "aws_iam_role_policy_attachment" "attach_codebuild_service_role_basics" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_service_role_basics.arn
}


data "aws_iam_policy_document" "codebuild_code_connection_access" {
  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:GetConnectionToken",
      "codestar-connections:GetConnection",
      "codestar-connections:UseConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection"
    ]
    resources = [
      var.codeconnection_arn,
      "arn:aws:codeconnections:us-west-1:235494798404:connection/2b213f7e-acf0-46dd-a554-a4e23ccc1248",
    ]
  }
}
resource "aws_iam_policy" "codebuild_code_connection_access" {
  name        = "${var.environment}-codebuild-code-connection-access"
  policy = data.aws_iam_policy_document.codebuild_code_connection_access.json
}
resource "aws_iam_role_policy_attachment" "codebuild_code_connection_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_code_connection_access.arn
}


resource "aws_iam_policy" "vpc_network_interface_access" {
  name        = "${var.environment}-codebuild-vpc_network_interface_access"
  description = "Policy for VPC network interface access"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Resource": "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:network-interface/*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach_vpc_network_interface_access" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.vpc_network_interface_access.arn
}


resource "aws_iam_role_policy_attachment" "codebuild_basic" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}



data "aws_caller_identity" "current" {}

