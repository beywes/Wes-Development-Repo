output "volume_id" {
  description = "The ID of the created EBS volume"
  value       = aws_ebs_volume.this.id
}

output "volume_arn" {
  description = "The ARN of the created EBS volume"
  value       = aws_ebs_volume.this.arn
}

output "attachment_id" {
  description = "The ID of the volume attachment"
  value       = try(aws_volume_attachment.this[0].id, null)
}

output "volume_tags" {
  description = "The tags of the created EBS volume"
  value       = aws_ebs_volume.this.tags
}
