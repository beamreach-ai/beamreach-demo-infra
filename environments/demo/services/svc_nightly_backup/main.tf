locals {
  cover = "svc-nightly-backup"
}

# Deny-all service account: a stolen key can do nothing except reveal the thief.
resource "aws_iam_user" "user" {
  name = "svc-nightly-backup"
  path = "/service/"

  tags = {
    "cost-center" = "c0286ddd"
  }
}

resource "aws_iam_user_policy" "deny_all" {
  name = "DenyAll"
  user = aws_iam_user.user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Deny"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_access_key" "key" {
  user = aws_iam_user.user.name
}

output "access_key_id" {
  value       = aws_iam_access_key.key.id
  description = "Access key id for svc-nightly-backup."
}

output "secret_access_key" {
  value       = aws_iam_access_key.key.secret
  description = "Secret access key for svc-nightly-backup."
  sensitive   = true
}

# Read-only management events (e.g. sts:GetCallerIdentity) only reach a rule in
# this state.
resource "aws_cloudwatch_event_rule" "rule" {
  name        = "svc-nightly-backup-activity"
  description = "API activity for svc-nightly-backup"
  state       = "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"

  event_pattern = jsonencode({
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      userIdentity = {
        type     = ["IAMUser"]
        userName = ["svc-nightly-backup"]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "target" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = local.cover
  arn       = var.alert_queue_arn
  role_arn  = var.alert_delivery_role_arn

  input_transformer {
    input_paths = {
      "eventId"       = "$.detail.eventID"
      "eventTime"     = "$.detail.eventTime"
      "eventName"     = "$.detail.eventName"
      "region"        = "$.detail.awsRegion"
      "accessKeyId"   = "$.detail.userIdentity.accessKeyId"
      "principalArn"  = "$.detail.userIdentity.arn"
      "sourceIp"      = "$.detail.sourceIPAddress"
      "userAgent"     = "$.detail.userAgent"
      "errorCode"     = "$.detail.errorCode"
      "vpcEndpointId" = "$.detail.vpcEndpointId"
    }
    input_template = <<TEMPLATE
{
  "token_id": "4016e788-39de-4c19-80a7-c6bad395b5b3",
  "workspace_id": "local",
  "event_id": "<eventId>",
  "event_time": "<eventTime>",
  "event_name": "<eventName>",
  "region": "<region>",
  "access_key_id": "<accessKeyId>",
  "principal_arn": "<principalArn>",
  "source_ip": "<sourceIp>",
  "user_agent": "<userAgent>",
  "error_code": "<errorCode>",
  "vpc_endpoint_id": "<vpcEndpointId>",
  "service": "iam"
}
TEMPLATE
  }
}
