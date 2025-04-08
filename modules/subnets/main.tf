// subnets

resource "aws_subnet" "alb" {
  vpc_id                  = var.vpc_id
  cidr_block              = format("10.0.%d.0/24", tonumber(var.az_index) * 10 + 0)
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "${var.environment}-alb-subnet-${var.az}"
  }
}

resource "aws_subnet" "app" {
  vpc_id                  = var.vpc_id
  cidr_block              = format("10.0.%d.0/24", tonumber(var.az_index) * 10 + 1)
  availability_zone       = var.az

  tags = {
    Name = "${var.environment}-app-subnet-${var.az}"
  }
}

resource "aws_subnet" "data" {
  vpc_id            = var.vpc_id
  cidr_block        = format("10.0.%d.0/24", tonumber(var.az_index) * 10 + 3)
  availability_zone = var.az

  tags = {
    Name = "${var.environment}-data-subnet-${var.az}"
  }
}


// app subnet nat gateway set up

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.environment}-eip-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app.id 

  tags = {
    Name = "${var.environment}-${var.az}-nat-gateway"
  }
}


resource "aws_route_table" "app" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.environment}-${var.az}-rt-app"
  }
}


// route table associations

resource "aws_route_table_association" "rt-public-alb" {
  subnet_id      = aws_subnet.alb.id
  route_table_id = var.rt_public_id
}

resource "aws_route_table_association" "rt-public-app" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "rt-private-data" {
  subnet_id      = aws_subnet.data.id
  route_table_id = var.rt_private_id
}