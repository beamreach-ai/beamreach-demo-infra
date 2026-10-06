locals {
  cover = "ci-artifacts-reader"
}

# Deny-all service account: a stolen key can do nothing except reveal the thief.
resource "aws_iam_user" "user" {
  name = "ci-artifacts-reader"
  path = "/service/"

  tags = {
    "cost-center" = "40c704ec"
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
  description = "Access key id for ci-artifacts-reader."
}

output "secret_access_key" {
  value       = aws_iam_access_key.key.secret
  description = "Secret access key for ci-artifacts-reader."
  sensitive   = true
}

# Read-only management events (e.g. sts:GetCallerIdentity) only reach a rule in
# this state.
resource "aws_cloudwatch_event_rule" "rule" {
  name        = "ci-artifacts-reader-activity"
  description = "API activity for ci-artifacts-reader"
  state       = "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"

  event_pattern = jsonencode({
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      userIdentity = {
        type     = ["IAMUser"]
        userName = ["ci-artifacts-reader"]
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
  "token_id": "de95097d-2f7d-49a8-a8a3-a9d6ed83182e",
  "workspace_id": "beamreach-demo",
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
