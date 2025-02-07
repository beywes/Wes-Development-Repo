# Data source for latest WordPress AMI
data "aws_ami" "wordpress" {
  most_recent = true
  owners      = ["amazon"]  # Amazon's AMI

  filter {
    name   = "name"
    values = ["bitnami-wordpress-*-linux-debian-11-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Public Webserver Instances
resource "aws_instance" "webserver" {
  count         = 3
  ami           = data.aws_ami.wordpress.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[count.index]

  vpc_security_group_ids = var.security_group_ids
  key_name              = var.key_name

  user_data = templatefile("${path.module}/wordpress_config.sh", {
    db_host     = aws_instance.database[count.index].private_ip
    db_name     = "wordpress"
    db_user     = "wordpress"
    db_password = random_password.db_password.result
  })

  tags = {
    Name        = "${var.environment}-webserver-${count.index + 1}"
    Environment = var.environment
  }
}

# Database Instances
resource "aws_instance" "database" {
  count         = 3
  ami           = data.aws_ami.wordpress.id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index]

  vpc_security_group_ids = [var.db_security_group_id]
  key_name              = var.key_name

  user_data = templatefile("${path.module}/mysql_config.sh", {
    db_name     = "wordpress"
    db_user     = "wordpress"
    db_password = random_password.db_password.result
  })

  tags = {
    Name        = "${var.environment}-database-${count.index + 1}"
    Environment = var.environment
  }
}

# Generate random password for database
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Register webservers with ALB target group
resource "aws_lb_target_group_attachment" "webserver" {
  count            = 3
  target_group_arn = var.target_group_arns[0]
  target_id        = aws_instance.webserver[count.index].id
  port             = 80
}
