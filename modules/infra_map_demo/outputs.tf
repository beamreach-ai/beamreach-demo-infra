output "secret_arn" {
  description = "ARN of the demo application secret."
  value       = aws_secretsmanager_secret.app_config.arn
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster."
  value       = aws_ecs_cluster.demo.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.demo.name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.api.name
}

# COMMENTED OUT: ALB is disabled - see finops:kosty:loadbalancer:682684724085:us-east-1:no-healthy-targets:demo-map-alb
# Uncomment when restoring ALB infrastructure
# output "alb_dns_name" {
#   description = "DNS name of the Application Load Balancer."
#   value       = aws_lb.demo.dns_name
# }

output "security_group_ids" {
  description = "Security group IDs for ECS tasks (ALB security group removed)."
  value = {
    # ALB security group removed since ALB is disabled
    # alb = aws_security_group.alb.id
    ecs = aws_security_group.ecs_tasks.id
  }
}
