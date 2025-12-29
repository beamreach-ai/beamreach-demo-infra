variable "env" {
  description = "Environment name for tagging."
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for alarms."
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for alarms."
  type        = string
}
