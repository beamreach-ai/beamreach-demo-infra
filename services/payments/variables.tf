variable "queue_visibility_timeout" {
  description = "How long a payment stays invisible after a worker takes it."
  type        = number
  default     = 30
}

variable "retry_limit" {
  description = "Retries before a payment goes to the dead-letter queue."
  type        = number
  default     = 3
}
