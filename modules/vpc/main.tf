// resources needed for all subnets

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-rt-public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-rt-private"
  }
}


// generate subnets

module "subnets_by_az" {
  source = "../subnets"

  providers = {
    aws = aws
  }
  environment = var.environment

  for_each = local.az_map
  az       = each.value
  az_index = each.key

  vpc_id        = aws_vpc.vpc.id
  rt_public_id  = aws_route_table.public.id
  rt_private_id = aws_route_table.private.id
}


// security group alb

resource "aws_security_group" "alb" {
  name   = "${var.environment}-sg-alb"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-alb"
  }
}
resource "aws_security_group_rule" "alb_accepts_internet" {
  type              = "ingress"
  description       = "Allow alb to recieve requests from internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}
resource "aws_security_group_rule" "alb_to_app" {
  type                     = "egress"
  description              = "Allow alb to send requests to app"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.alb.id
}


// security group app

resource "aws_security_group" "app" {
  name   = "${var.environment}-sg-app"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-app"
  }
}
resource "aws_security_group_rule" "app_accepts_alb" {
  type                     = "ingress"
  description              = "Allow app to recieve requests from alb"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.app.id
}
resource "aws_security_group_rule" "app_to_internet" {
  type              = "egress"
  description       = "Allow app to send requests to internet with HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "app_to_redis" {
  type                     = "egress"
  description              = "Allow app to send requests to redis cache"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.data.id
  security_group_id        = aws_security_group.app.id
}
resource "aws_security_group_rule" "app_to_postgres" {
  type                     = "egress"
  description              = "Allow app to send requests to psql db"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.data.id
  security_group_id        = aws_security_group.app.id
}
// remove
resource "aws_security_group_rule" "app_accepts_ssh" {
  type                     = "ingress"
  description              = "Allow ssh"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.app.id
}


// security group data

resource "aws_security_group" "data" {
  name   = "${var.environment}-sg-data"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-data"
  }
}
resource "aws_security_group_rule" "data_accepts_redis_app" {
  type                     = "ingress"
  description              = "Allow redis cache to respond to app"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data.id
  source_security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "data_accepts_psql_app" {
  type                     = "ingress"
  description              = "Allow psql db to respond to app"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data.id
  source_security_group_id = aws_security_group.app.id
}
// maybe remove this later
resource "aws_security_group_rule" "data_accepts_psql_analytics" {
  type                     = "ingress"
  description              = "Allow psql db to respond to analytics ec2"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.data.id
  source_security_group_id = aws_security_group.analytics.id
}


// security group analytics

resource "aws_security_group" "analytics" {
  name        = "${var.environment}-sg-analytics_ec2"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-analytics_ec2"
  }
}
resource "aws_security_group_rule" "analytics_to_internet_https" {
  type              = "egress"
  description       = "Allow analytics ec2 to send requests to internet with HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.analytics.id
}
resource "aws_security_group_rule" "analytics_accepts_internet_http" {
  type              = "egress"
  description       = "Allow analytics ec2 to send requests to internet with HTTPS"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.analytics.id
}
resource "aws_security_group_rule" "analytics_accepts_ssh" {
  type                     = "ingress"
  description              = "Allow ssh"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.analytics.id
}
// maybe change this later to access a different sg with replica
resource "aws_security_group_rule" "analytics_to_postgres" {
  type                     = "egress"
  description              = "Allow analytics ec2 to send requests to psql db"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.data.id
  security_group_id        = aws_security_group.analytics.id
}



