resource "aws_key_pair" "my_key" {
  key_name   = "${var.environment}-analytics_ec2"
  public_key = file("~/.ssh/analytics-ec2.pub")
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_instance" "analytics" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.app_subnet_id
  vpc_security_group_ids      = [var.analytics_sg_id]
  key_name                    = aws_key_pair.my_key.key_name
  associate_public_ip_address = true 

  tags = {
    Name = "${var.environment}-analytics-ec2"
  }
}

