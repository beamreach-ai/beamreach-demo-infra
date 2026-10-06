# Event forwarding role.
# EventBridge needs a role in this account to put events on a cross-account queue.

resource "aws_iam_role" "alert_delivery" {
  name = "svc-event-forwarder"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "alert_delivery" {
  name = "send-to-queue"
  role = aws_iam_role.alert_delivery.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sqs:SendMessage"
      Resource = var.alert_queue_arn
    }]
  })
}

output "alert_delivery_role_arn" {
  value = aws_iam_role.alert_delivery.arn
}
