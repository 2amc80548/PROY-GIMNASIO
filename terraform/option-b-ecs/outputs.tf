output "alb_dns_name" {
  description = "URL pública del ALB par ael front."
  value       = aws_lb.main.dns_name
}

output "ecr_members_repository_url" {
  description = "URL del repo ECR para members."
  value       = aws_ecr_repository.members.repository_url
}

output "ecr_billing_repository_url" {
  description = "URL del repo ECR para billing."
  value       = aws_ecr_repository.billing.repository_url
}

output "ecr_access_control_repository_url" {
  description = "URL del repo ECR para access-control."
  value       = aws_ecr_repository.access_control.repository_url
}

output "ecr_login_command" {
  description = "Comando para autenticar Docker contra ECR."
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_registry}"
}

output "cluster_name" {
  description = "Nombre del cluster ECS."
  value       = aws_ecs_cluster.main.name
}

output "service_discovery_namespace" {
  description = "Namespace DNS interno."
  value       = aws_service_discovery_private_dns_namespace.main.name
}

output "mysql_endpoint" {
  description = "Host y puerto de la base de datos MySQL (RDS)."
  value       = aws_db_instance.mysql.endpoint
}