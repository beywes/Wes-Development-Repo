# Example 1: Windows Server 2022 with CloudWatch monitoring
module "windows_server_2022" {
  source = "./modules/aws/ec2/EC2_Instance"

  # Instance Configuration
  instance_name = "win2022-iis-server"
  operating_system = "Windows Server 2022"
  instance_type    = "t3.large"
  
  # Network Configuration
  aws_region         = "us-east-1"
  subnet_id          = "subnet-12345678" # Replace with your subnet ID
  security_group_ids = ["sg-12345678"]   # Replace with your security group ID
  key_name           = "my-key-pair"     # Replace with your key pair name

  # Storage Configuration
  root_volume_size      = 100
  root_volume_type      = "gp3"
  root_volume_encrypted = true

  # Monitoring Configuration
  install_cloudwatch_agent  = true
  cloudwatch_dashboard_name = "win2022-server-dashboard"
  enable_sns_notifications = true
  notification_email      = "admin@example.com"
  
  # Custom metrics monitoring
  custom_metrics_monitoring = {
    cpu = {
      metric_name         = "CPUUtilization"
      threshold          = 85
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
    memory = {
      metric_name         = "Memory % Committed Bytes In Use"
      threshold          = 90
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
    disk = {
      metric_name         = "LogicalDisk % Free Space"
      threshold          = 15
      comparison_operator = "LessThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
    network = {
      metric_name         = "NetworkIn"
      threshold          = 10000000 # 10MB/s
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
  }

  # Tags
  common_tags = {
    Environment = "Production"
    Department  = "IT"
    Project     = "Infrastructure"
    Terraform   = "true"
  }
}

# Example 2: Amazon Linux 2 Web Server
module "amazon_linux_2_web" {
  source = "./modules/aws/ec2/EC2_Instance"

  # Instance Configuration
  instance_name = "al2-web-server"
  operating_system = "Amazon Linux 2"
  instance_type    = "t3.medium"
  
  # Network Configuration
  aws_region         = "us-west-2"
  subnet_id          = "subnet-87654321" # Replace with your subnet ID
  security_group_ids = ["sg-87654321"]   # Replace with your security group ID
  key_name           = "web-key-pair"    # Replace with your key pair name

  # Storage Configuration
  root_volume_size      = 50
  root_volume_type      = "gp3"
  root_volume_encrypted = true

  # Monitoring Configuration
  install_cloudwatch_agent  = true
  cloudwatch_dashboard_name = "al2-web-dashboard"
  enable_sns_notifications = true
  notification_email      = "webops@example.com"
  
  # Custom metrics monitoring - Web server specific
  custom_metrics_monitoring = {
    cpu = {
      metric_name         = "CPUUtilization"
      threshold          = 75
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
    memory = {
      metric_name         = "Memory % Committed Bytes In Use"
      threshold          = 80
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
    connections = {
      metric_name         = "NetworkPacketsIn"
      threshold          = 100000
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
  }

  # Tags
  common_tags = {
    Environment = "Development"
    Department  = "WebOps"
    Project     = "WebApp"
    Terraform   = "true"
  }
}

# Example 3: Ubuntu Server for Development
module "ubuntu_dev_server" {
  source = "./modules/aws/ec2/EC2_Instance"

  # Instance Configuration
  instance_name = "ubuntu-dev-server"
  operating_system = "Ubuntu"
  instance_type    = "t3.small"
  
  # Network Configuration
  aws_region         = "eu-west-1"
  subnet_id          = "subnet-abcdef12" # Replace with your subnet ID
  security_group_ids = ["sg-abcdef12"]   # Replace with your security group ID
  key_name           = "dev-key-pair"    # Replace with your key pair name

  # Storage Configuration
  root_volume_size      = 30
  root_volume_type      = "gp3"
  root_volume_encrypted = true

  # Monitoring Configuration - Minimal for Dev
  install_cloudwatch_agent  = true
  cloudwatch_dashboard_name = "ubuntu-dev-dashboard"
  enable_sns_notifications = true
  notification_email      = "dev-team@example.com"
  
  # Custom metrics monitoring - Development environment
  custom_metrics_monitoring = {
    cpu = {
      metric_name         = "CPUUtilization"
      threshold          = 90
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
    disk = {
      metric_name         = "LogicalDisk % Free Space"
      threshold          = 10
      comparison_operator = "LessThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
  }

  # Tags
  common_tags = {
    Environment = "Development"
    Department  = "Engineering"
    Project     = "DevTools"
    Terraform   = "true"
  }
}

# Example 4: RHEL Database Server
module "rhel_db_server" {
  source = "./modules/aws/ec2/EC2_Instance"

  # Instance Configuration
  instance_name = "rhel-db-server"
  operating_system = "RHEL"
  instance_type    = "r5.xlarge"
  
  # Network Configuration
  aws_region         = "ap-southeast-1"
  subnet_id          = "subnet-98765432" # Replace with your subnet ID
  security_group_ids = ["sg-98765432"]   # Replace with your security group ID
  key_name           = "db-key-pair"     # Replace with your key pair name

  # Storage Configuration
  root_volume_size      = 200
  root_volume_type      = "io2"
  root_volume_encrypted = true

  # Monitoring Configuration - Database specific
  install_cloudwatch_agent  = true
  cloudwatch_dashboard_name = "rhel-db-dashboard"
  enable_sns_notifications = true
  notification_email      = "dba-team@example.com"
  
  # Custom metrics monitoring - Database server specific
  custom_metrics_monitoring = {
    cpu = {
      metric_name         = "CPUUtilization"
      threshold          = 80
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
    memory = {
      metric_name         = "Memory % Committed Bytes In Use"
      threshold          = 85
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
    disk = {
      metric_name         = "LogicalDisk % Free Space"
      threshold          = 20
      comparison_operator = "LessThanThreshold"
      evaluation_periods = 2
      period            = 300
      statistic         = "Average"
      namespace         = "CWAgent"
      enabled           = true
    }
    disk_iops = {
      metric_name         = "DiskWriteOps"
      threshold          = 1000
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 3
      period            = 300
      statistic         = "Average"
      namespace         = "AWS/EC2"
      enabled           = true
    }
  }

  # Tags
  common_tags = {
    Environment = "Production"
    Department  = "Database"
    Project     = "CoreDB"
    Terraform   = "true"
    Backup      = "Daily"
  }
}
