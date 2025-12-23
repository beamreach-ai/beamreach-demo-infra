variable "env" {
  description = "Environment name used for tagging."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the resources reside."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the Application Load Balancer."
  type        = list(string)
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret."
  type        = string
  default     = "demo/app-config"
}

variable "secret_payload" {
  description = "JSON payload stored in the secret."
  type        = string
  default     = "{\"env\":\"demo\"}"
}

variable "cluster_name" {
  description = "ECS cluster name."
  type        = string
  default     = "demo-map-cluster"
}

variable "task_family" {
  description = "Family name for the ECS task definition."
  type        = string
  default     = "demo-map-api"
}

variable "service_name" {
  description = "Name of the ECS service."
  type        = string
  default     = "demo-map-api-svc"
}

variable "container_image" {
  description = "Container image for the demo service."
  type        = string
  default     = "public.ecr.aws/nginx/nginx:latest"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer."
  type        = string
  default     = "demo-map-alb"
}

variable "target_group_name" {
  description = "Name of the ALB target group."
  type        = string
  default     = "demo-map-tg"
}

variable "alb_security_group_name" {
  description = "Name of the ALB security group."
  type        = string
  default     = "sg-demo-map-alb"
}

variable "ecs_security_group_name" {
  description = "Name of the ECS tasks security group."
  type        = string
  default     = "sg-demo-map-ecs"
}
