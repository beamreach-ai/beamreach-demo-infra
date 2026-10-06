variable "alert_queue_arn" {
  type        = string
  description = "ARN of the queue that receives event notifications."
}

variable "alert_delivery_role_arn" {
  type        = string
  description = "IAM role EventBridge assumes to send to the queue."
}

variable "workspace_id" {
  type        = string
  description = "Identifier forwarded with every event."
}

variable "callback_url" {
  type        = string
  description = "Endpoint that receives callback events."
  default     = ""
}
