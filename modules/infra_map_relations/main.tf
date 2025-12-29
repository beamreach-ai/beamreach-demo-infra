locals {
  prefix = "${var.env}-map"
  tags = {
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

resource "aws_sns_topic" "demo" {
  name = "${local.prefix}-topic"
  tags = local.tags
}

resource "aws_sqs_queue" "demo" {
  name                       = "${local.prefix}-queue"
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 30
  tags                       = local.tags
}

resource "aws_sqs_queue_policy" "allow_sns" {
  queue_url = aws_sqs_queue.demo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.demo.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.demo.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "queue" {
  topic_arn = aws_sns_topic.demo.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.demo.arn
}

resource "aws_iam_role" "publisher" {
  name = "${local.prefix}-publisher-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "publisher" {
  role = aws_iam_role.publisher.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.demo.arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = aws_dynamodb_table.events.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "publisher" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src/publisher"
  output_path = "${path.module}/build/publisher.zip"
}

resource "aws_lambda_function" "publisher" {
  function_name = "${local.prefix}-publisher"
  role          = aws_iam_role.publisher.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.publisher.output_path
  source_code_hash = data.archive_file.publisher.output_base64sha256

  timeout = 10

  environment {
    variables = {
      SNS_TOPIC_ARN  = aws_sns_topic.demo.arn
      DDB_TABLE_NAME = aws_dynamodb_table.events.name
    }
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "publisher" {
  name              = "/aws/lambda/${aws_lambda_function.publisher.function_name}"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_cloudwatch_event_rule" "publisher_schedule" {
  name                = "${local.prefix}-schedule"
  schedule_expression = "rate(30 minutes)"
  tags                = local.tags
}

resource "aws_cloudwatch_event_target" "publisher" {
  rule      = aws_cloudwatch_event_rule.publisher_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.publisher.arn
}

resource "aws_lambda_permission" "events" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.publisher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.publisher_schedule.arn
}

resource "aws_dynamodb_table" "events" {
  name         = "${local.prefix}-events"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "pk"
  range_key = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  tags = local.tags
}

resource "aws_iam_role" "stream_consumer" {
  name = "${local.prefix}-stream-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "stream_consumer" {
  role = aws_iam_role.stream_consumer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Resource = aws_dynamodb_table.events.stream_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "stream_consumer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src/stream_consumer"
  output_path = "${path.module}/build/stream_consumer.zip"
}

resource "aws_lambda_function" "stream_consumer" {
  function_name = "${local.prefix}-stream-consumer"
  role          = aws_iam_role.stream_consumer.arn
  handler       = "main.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.stream_consumer.output_path
  source_code_hash = data.archive_file.stream_consumer.output_base64sha256

  timeout = 30

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "stream_consumer" {
  name              = "/aws/lambda/${aws_lambda_function.stream_consumer.function_name}"
  retention_in_days = 7
  tags              = local.tags
}

resource "aws_lambda_event_source_mapping" "stream" {
  event_source_arn  = aws_dynamodb_table.events.stream_arn
  function_name     = aws_lambda_function.stream_consumer.arn
  starting_position = "LATEST"
}

resource "aws_iam_role" "sfn" {
  name = "${local.prefix}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "sfn" {
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "lambda:InvokeFunction"
        Resource = aws_lambda_function.publisher.arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "pipeline" {
  name     = "${local.prefix}-pipeline"
  role_arn = aws_iam_role.sfn.arn
  type     = "EXPRESS"

  definition = jsonencode({
    StartAt = "InvokePublisher"
    States = {
      InvokePublisher = {
        Type     = "Task"
        Resource = aws_lambda_function.publisher.arn
        End      = true
      }
    }
  })

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${local.prefix}-ecs-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alerts when the demo ECS service CPU exceeds 70%"
  alarm_actions       = [aws_sns_topic.demo.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = local.tags
}
