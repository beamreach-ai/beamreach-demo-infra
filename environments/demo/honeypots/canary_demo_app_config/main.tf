# Beamreach Honeypot — IAM Canary Key
# asset_id: 6fb8121d-d9e1-42af-baef-d54fc5a5e755
# The credentials below are a security canary. Any API call using them triggers
# an immediate critical alert. The user carries a deny-all policy so a stolen
# key can never do anything except reveal the thief.

resource "aws_iam_user" "honeypot_canary_demo_app_config" {
  name = "svc-canary_demo_app_config"
  path = "/service/"

  tags = {
    "beamreach:managed"     = "true"
    "beamreach:feature"     = "honeypot"
    "beamreach:asset-id"    = "6fb8121d-d9e1-42af-baef-d54fc5a5e755"
    "beamreach:asset-class" = "iam_canary"
  }
}

resource "aws_iam_user_policy" "honeypot_canary_demo_app_config_deny_all" {
  name = "DenyAll"
  user = aws_iam_user.honeypot_canary_demo_app_config.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
    }]
  })
}

# Real access key material — Terraform mints it and surfaces it as an output so
# the operator can plant it. (Any use of it is unauthorized.)
resource "aws_iam_access_key" "honeypot_canary_demo_app_config" {
  user = aws_iam_user.honeypot_canary_demo_app_config.name
}

output "honeypot_canary_demo_app_config_access_key" {
  value       = aws_iam_access_key.honeypot_canary_demo_app_config.id
  description = "Canary access key id for canary_demo_app_config — plant this where an attacker would find it."
}

output "honeypot_canary_demo_app_config_secret_key" {
  value       = aws_iam_access_key.honeypot_canary_demo_app_config.secret
  description = "Canary secret access key for canary_demo_app_config."
  sensitive   = true
}

# CloudTrail alert for any API call using this IAM user
resource "aws_cloudwatch_event_rule" "honeypot_canary_demo_app_config_usage" {
  name        = "beamreach-hp-canary_demo_app_config-usage"
  description = "Alert on any API call by a monitored principal"

  event_pattern = jsonencode({
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      userIdentity = {
        type     = ["IAMUser"]
        userName = ["svc-canary_demo_app_config"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "honeypot_canary_demo_app_config_target" {
  rule      = aws_cloudwatch_event_rule.honeypot_canary_demo_app_config_usage.name
  target_id = "beamreach-hp-canary_demo_app_config"
  arn       = var.beamreach_honeypot_receiver_lambda_arn

  input_transformer {
    input_paths = {
      "sourceIPAddress" = "$.detail.sourceIPAddress"
      "userAgent"       = "$.detail.userAgent"
      "eventName"       = "$.detail.eventName"
    }
    input_template = <<TEMPLATE
{
  "asset_id": "6fb8121d-d9e1-42af-baef-d54fc5a5e755",
  "workspace_id": "beamreach-demo",
  "source_ip": "<sourceIPAddress>",
  "user_agent": "<userAgent>",
  "service": "<eventName>"
}
TEMPLATE
  }
}
