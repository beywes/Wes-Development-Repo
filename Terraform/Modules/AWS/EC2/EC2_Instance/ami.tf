# Windows Server AMIs
data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

data "aws_ami" "windows_2019" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

data "aws_ami" "windows_2016" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base-*"]
  }
}

# Linux AMIs
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  owners      = ["309956199498"] # Red Hat's account ID

  filter {
    name   = "name"
    values = ["RHEL-9.*"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["125523088429"] # CentOS's account ID

  filter {
    name   = "name"
    values = ["CentOS Stream 9 *"]
  }
}

# Local variable for AMI mapping
locals {
  ami_mapping = {
    "Windows Server 2022" = data.aws_ami.windows_2022.id
    "Windows Server 2019" = data.aws_ami.windows_2019.id
    "Windows Server 2016" = data.aws_ami.windows_2016.id
    "Amazon Linux 2"      = data.aws_ami.amazon_linux_2.id
    "RHEL"               = data.aws_ami.rhel.id
    "Ubuntu"             = data.aws_ami.ubuntu.id
    "CentOS"            = data.aws_ami.centos.id
  }
}
