# Beamreach Honeypot — shared input variables (auto-generated).
variable "beamreach_honeypot_receiver_lambda_arn" {
  type        = string
  description = "ARN of the Beamreach honeypot receiver Lambda (deployed by the receiver stack)."
}

variable "beamreach_workspace_id" {
  type        = string
  description = "Beamreach workspace id, forwarded with every alert."
}

variable "beamreach_api_url" {
  type        = string
  description = "Beamreach API base URL for callback-based canaries."
  default     = ""
}
