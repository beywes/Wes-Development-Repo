output "webserver_ids" {
  description = "IDs of the webserver instances"
  value       = aws_instance.webserver[*].id
}

output "webserver_public_ips" {
  description = "Public IPs of the webserver instances"
  value       = aws_instance.webserver[*].public_ip
}

output "database_ids" {
  description = "IDs of the database instances"
  value       = aws_instance.database[*].id
}

output "database_private_ips" {
  description = "Private IPs of the database instances"
  value       = aws_instance.database[*].private_ip
}

output "db_password" {
  description = "Generated database password"
  value       = random_password.db_password.result
  sensitive   = true
}
