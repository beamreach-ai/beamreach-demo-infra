variable "env" {
  description = "Deployment environment identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier used for security group placement"
  type        = string
}

variable "insecure_task_image" {
  description = "Container image used by the intentionally insecure ECS task definition"
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:latest"
}
