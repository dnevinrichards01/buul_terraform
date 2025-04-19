// cluster

resource "aws_ecs_cluster" "ecs" {
  name = "${var.environment}-cluster"
}


// services

resource "aws_ecs_service" "services" {
  for_each = toset(local.services)

  name            = "${var.environment}-${each.value}"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.tasks[each.value].arn
  launch_type     = "FARGATE"
  desired_count = var.desired_counts_by_service[each.value]
  
  network_configuration {
    subnets         = var.app_subnet_ids
    security_groups = [var.app_security_group_id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value == "app" ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.ecs.arn
      container_name   = "${var.environment}-${each.value}"
      container_port   = 443
    }
  }

  depends_on = [aws_lb_listener.https]
  // force_new_deployment    = true // need to re-deploy for sg / subnet changes
  enable_execute_command = true

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}


// tasks

resource "aws_ecs_task_definition" "tasks" {
  for_each = toset(local.tasks)

  family                   = "${var.environment}-${each.value}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  network_mode             = "awsvpc"
  execution_role_arn       = each.value == "debug-current" || each.value == "debug-latest" ? var.ecs_task_role_arns["app"] : var.ecs_task_role_arns[each.value]
  task_role_arn            = each.value == "debug-current" || each.value == "debug-latest" ? var.ecs_task_role_arns["app"] : var.ecs_task_role_arns[each.value]
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode(local.task_definitions[each.value])
}


// kms

resource "aws_kms_key" "db_encryption" {
  for_each = local.kms
  description             = "encrypts ${each.value}"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}
resource "aws_kms_alias" "db_encryption" {
  for_each = local.kms
  name          = "alias/${var.environment}-${each.value}"
  target_key_id = aws_kms_key.db_encryption[each.key].key_id
}
data "aws_iam_policy_document" "db_encryption" {
  for_each = local.kms
  statement {
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = [aws_kms_key.db_encryption[each.key].arn]
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }

    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [var.vpce_ids["kms"]]
    }
  }
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = ["kms:*"]
    resources = ["*"]
}
}
resource "aws_kms_key_policy" "db_encryption" {
  for_each = local.kms
  key_id = aws_kms_key.db_encryption[each.key].key_id
  policy = data.aws_iam_policy_document.db_encryption[each.key].json
}



// alb 

resource "aws_lb" "app" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.alb_subnet_ids
}

resource "aws_lb_target_group" "ecs" {
  name     = "${var.environment}-target"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    port                = "traffic-port"
    protocol            = "HTTPS"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # or another policy
  certificate_arn   = var.acm_cert_arn 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}




data "aws_caller_identity" "current" {}