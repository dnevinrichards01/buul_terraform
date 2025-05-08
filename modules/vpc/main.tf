// resources needed for all subnets

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block  = true 
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
  igw_id = aws_internet_gateway.igw.id
  vpc_ipv6_cidr_block = aws_vpc.vpc.ipv6_cidr_block
  vpc_cidr_block = aws_vpc.vpc.cidr_block
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
  ipv6_cidr_blocks = ["::/0"]
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
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "app_to_smtp" {
  type              = "egress"
  description       = "Allow app to send emails"
  from_port         = 587
  to_port           = 587
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
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


// security group analytics data

resource "aws_security_group" "analyticsdb" {
  name   = "${var.environment}-sg-analyticsdb"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-analyticsdb"
  }
}
resource "aws_security_group_rule" "analyticsdb_accepts_analytics" {
  type                     = "ingress"
  description              = "Allow analyticsdb ec2 to accept requests from analytics ec2"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.analytics.id
  security_group_id        = aws_security_group.analyticsdb.id
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
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.analytics.id
}
resource "aws_security_group_rule" "analytics_to_internet_http" {
  type              = "egress"
  description       = "Allow analytics ec2 to send requests to internet with HTTPS"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  security_group_id = aws_security_group.analytics.id
}
resource "aws_security_group_rule" "analytics_to_ssm" {
  type                     = "egress"
  description              = "Allow ssm"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpce_ssm.id
  security_group_id        = aws_security_group.analytics.id
}
resource "aws_security_group_rule" "analytics_to_analyticsdb" {
  type                     = "egress"
  description              = "Allow analytics ec2 to send psql requests to analyticsdb"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.analyticsdb.id
  security_group_id        = aws_security_group.analytics.id
}

// security group VPCE

resource "aws_security_group" "vpce" {
  name   = "${var.environment}-sg-vpce"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-vpce"
  }
}
resource "aws_security_group_rule" "vpce_accepts_app_requests" {
  type                     = "ingress"
  description              = "Allow vpce to respond to app"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce.id
  source_security_group_id = aws_security_group.app.id
}


// security group VPCE SSM
 
resource "aws_security_group" "vpce_ssm" {
  name   = "${var.environment}-sg-vpce_ssm"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-sg-vpce_ssm"
  }
}
resource "aws_security_group_rule" "vpce_ssm_accepts_app_requests" {
  type                     = "ingress"
  description              = "Allow vpce_ssm to respond to app"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce_ssm.id
  source_security_group_id = aws_security_group.app.id
}
resource "aws_security_group_rule" "vpce_ssm_accepts_analytics_requests" {
  type                     = "ingress"
  description              = "Allow vpce_ssm to respond to analytics"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vpce_ssm.id
  source_security_group_id = aws_security_group.analytics.id
} 


// VPCEs

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_services)

  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.data_subnet_ids
  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
  tags = {
    Name = "${var.environment}-${each.value}-vpce"
  }
}
resource "aws_vpc_endpoint" "interface_ssm" {
  for_each = toset(local.ssm_interface_services)

  vpc_id             = aws_vpc.vpc.id
  service_name       = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.data_subnet_ids
  security_group_ids = [aws_security_group.vpce_ssm.id]

  private_dns_enabled = true
  tags = {
    Name = "${var.environment}-${each.value}-vpce"
  }
}

