variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Type of the root volume (gp2, gp3, io1, io2, etc.)"
  type        = string
  default     = "gp3"
}

variable "root_volume_encrypted" {
  description = "Whether to encrypt the root volume"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers (e.g., SNS topic)"
  type        = list(string)
  default     = []
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "install_cloudwatch_agent" {
  description = "Whether to install and configure the CloudWatch agent"
  type        = bool
  default     = false
}

variable "operating_system" {
  description = "Operating system to use for the instance. Valid values: 'Windows Server 2022', 'Windows Server 2019', 'Windows Server 2016', 'Amazon Linux 2', 'RHEL', 'Ubuntu', 'CentOS'"
  type        = string
  validation {
    condition     = contains(["Windows Server 2022", "Windows Server 2019", "Windows Server 2016", "Amazon Linux 2", "RHEL", "Ubuntu", "CentOS"], var.operating_system)
    error_message = "Invalid operating system specified. Please choose from: Windows Server 2022, Windows Server 2019, Windows Server 2016, Amazon Linux 2, RHEL, Ubuntu, or CentOS"
  }
}

variable "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard to create for the instance"
  type        = string
  default     = null
}

variable "enable_sns_notifications" {
  description = "Whether to create SNS topic and subscriptions for CloudWatch alarms"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
  default     = null
}

variable "custom_metrics_monitoring" {
  description = "Map of custom metrics to monitor with their threshold values"
  type = map(object({
    metric_name         = string
    threshold          = number
    comparison_operator = string
    evaluation_periods = number
    period            = number
    statistic         = string
    namespace         = string
    enabled           = bool
  }))
  default = {
    cpu = {
      metric_name         = "CPUUtilization"
      threshold          = 80
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
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
  }
}
