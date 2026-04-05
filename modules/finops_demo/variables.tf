variable "env" {
  description = "Environment name used in tags and resource names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the FinOps demo resources will be created."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the optional Fargate service."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "public_subnet_ids must contain at least one subnet ID."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the internal idle ALB."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "private_subnet_ids must contain at least one subnet ID."
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to FinOps demo resources."
  type        = map(string)
  default     = {}
}

variable "gp2_volume_size_gb" {
  description = "Size of the oversized GP2 volume used for waste findings."
  type        = number
  default     = 20
}

variable "snapshot_count" {
  description = "How many snapshots to create from the oversized volume."
  type        = number
  default     = 6
}

variable "create_fargate_demo" {
  description = "Whether to create the optional always-on Fargate waste demo."
  type        = bool
  default     = false
}

variable "fargate_cpu" {
  description = "CPU units for the optional Fargate task."
  type        = number
  default     = 256
}

variable "fargate_memory" {
  description = "Memory in MiB for the optional Fargate task."
  type        = number
  default     = 1024
}
