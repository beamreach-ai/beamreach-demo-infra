variable "env" {
  description = "Deployment environment (e.g., dev, prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the demo services"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the demo services"
  type        = list(string)
}