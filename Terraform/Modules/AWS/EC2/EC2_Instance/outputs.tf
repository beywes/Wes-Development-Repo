output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.ec2_logs.name
}

output "system_check_alarm_arn" {
  description = "ARN of the system status check alarm"
  value       = aws_cloudwatch_metric_alarm.system_check_failed.arn
}

output "instance_check_alarm_arn" {
  description = "ARN of the instance status check alarm"
  value       = aws_cloudwatch_metric_alarm.instance_check_failed.arn
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_high.arn
}
