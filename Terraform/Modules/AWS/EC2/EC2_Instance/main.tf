provider "aws" {
  region = var.aws_region
}

# Local variables for instance configuration
locals {
  is_windows = can(regex("^Windows", var.operating_system))

  cloudwatch_agent_installation = var.install_cloudwatch_agent ? {
    windows = <<-EOF
      <powershell>
      $ErrorActionPreference = "Stop"
      $ProgressPreference = "SilentlyContinue"
      Invoke-WebRequest -Uri https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi -OutFile C:\amazon-cloudwatch-agent.msi
      Start-Process msiexec.exe -Wait -ArgumentList '/i C:\amazon-cloudwatch-agent.msi /qn'
      Remove-Item C:\amazon-cloudwatch-agent.msi
      </powershell>
    EOF
    linux = <<-EOF
      #!/bin/bash
      wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
      unzip AmazonCloudWatchAgent.zip
      ./install.sh
      rm AmazonCloudWatchAgent.zip
    EOF
  } : null

  ami_mapping = {
    "Windows 2019" = "ami-0c94855ba95c71c99"
    "Windows 2022" = "ami-0c94855ba95c71c99"
    "Ubuntu 20.04" = "ami-0c94855ba95c71c99"
    "Ubuntu 22.04" = "ami-0c94855ba95c71c99"
  }

  instance_tags = merge(
    var.common_tags,
    {
      Name = var.instance_name
      OperatingSystem = var.operating_system
      OSType = can(regex("^Windows", var.operating_system)) ? "Windows" : "Linux"
    }
  )
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = local.ami_mapping[var.operating_system]
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.security_group_ids
  key_name              = var.key_name

  user_data = var.install_cloudwatch_agent ? (
    local.is_windows ? local.cloudwatch_agent_installation.windows : local.cloudwatch_agent_installation.linux
  ) : null

  tags = local.instance_tags

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    encrypted   = var.root_volume_encrypted
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  monitoring = true
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/${var.instance_name}"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# CloudWatch Status Check Alarms

# Status Check Failed System Alarm
resource "aws_cloudwatch_metric_alarm" "system_check_failed" {
  alarm_name          = "${var.instance_name}-system-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "StatusCheckFailed_System"
  namespace          = "AWS/EC2"
  period             = "60"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "This metric monitors EC2 system status check failures"
  alarm_actions      = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = var.common_tags
}

# Status Check Failed Instance Alarm
resource "aws_cloudwatch_metric_alarm" "instance_check_failed" {
  alarm_name          = "${var.instance_name}-instance-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "StatusCheckFailed_Instance"
  namespace          = "AWS/EC2"
  period             = "60"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "This metric monitors EC2 instance status check failures"
  alarm_actions      = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = var.common_tags
}

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = "${var.instance_name}-cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_utilization_threshold
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions      = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = var.common_tags
}

# SNS Topic for CloudWatch Alarms
resource "aws_sns_topic" "cloudwatch_alarms" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = "ec2-${var.instance_name}-alarms"
  tags  = var.common_tags
}

# SNS Topic Email Subscription
resource "aws_sns_topic_subscription" "cloudwatch_alarms_email" {
  count     = var.enable_sns_notifications && var.notification_email != null ? 1 : 0
  topic_arn = aws_sns_topic.cloudwatch_alarms[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Dynamic CloudWatch Alarms based on custom metrics
resource "aws_cloudwatch_metric_alarm" "custom_alarms" {
  for_each = {
    for k, v in var.custom_metrics_monitoring : k => v
    if v.enabled && var.install_cloudwatch_agent
  }

  alarm_name          = "${var.instance_name}-${each.key}-alarm"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name        = each.value.metric_name
  namespace          = each.value.namespace
  period             = each.value.period
  statistic          = each.value.statistic
  threshold          = each.value.threshold
  alarm_description  = "This metric monitors ${each.value.metric_name} for instance ${var.instance_name}"
  
  dimensions = {
    InstanceId = aws_instance.main.id
  }

  alarm_actions = var.enable_sns_notifications ? [aws_sns_topic.cloudwatch_alarms[0].arn] : []
  ok_actions    = var.enable_sns_notifications ? [aws_sns_topic.cloudwatch_alarms[0].arn] : []

  tags = var.common_tags
}

# CloudWatch Dashboard for the instance
resource "aws_cloudwatch_dashboard" "instance" {
  count          = var.install_cloudwatch_agent && var.cloudwatch_dashboard_name != null ? 1 : 0
  dashboard_name = var.cloudwatch_dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for metric in [
              ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.main.id],
              ["AWS/EC2", "DiskReadBytes", "InstanceId", aws_instance.main.id],
              ["AWS/EC2", "DiskWriteBytes", "InstanceId", aws_instance.main.id],
              ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.main.id],
              ["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.main.id],
              ["AWS/EC2", "StatusCheckFailed", "InstanceId", aws_instance.main.id]
            ] : metric if lookup(var.custom_metrics_monitoring[metric[1]], "enabled", true)
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance Metrics - ${var.instance_name}"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for metric in [
              ["CWAgent", "Memory % Committed Bytes In Use", "InstanceId", aws_instance.main.id],
              ["CWAgent", "LogicalDisk % Free Space", "InstanceId", aws_instance.main.id],
              ["CWAgent", "Memory Available Bytes", "InstanceId", aws_instance.main.id],
              ["CWAgent", "Processor % Idle Time", "InstanceId", aws_instance.main.id]
            ] : metric if lookup(var.custom_metrics_monitoring[metric[1]], "enabled", true)
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "CloudWatch Agent Metrics - ${var.instance_name}"
        }
      }
    ]
  })
}
