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

variable "public_subnet_ids" {
  description = "List of public subnet IDs used for the service load balancer"
  type        = list(string)
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 80
}

variable "container_image" {
  description = "Fully qualified container image (including tag) to deploy in the ECS task"
  type        = string

  validation {
    condition     = length(trimspace(var.container_image)) > 0
    error_message = "container_image must be a non-empty string such as 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest."
  }
}

variable "alarm_emails" {
  description = "Optional list of email addresses to subscribe to the service SNS topic"
  type        = list(string)
  default     = []
}
