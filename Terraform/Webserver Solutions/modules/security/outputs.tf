output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "webserver_security_group_id" {
  description = "ID of the webserver security group"
  value       = aws_security_group.webserver.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}
