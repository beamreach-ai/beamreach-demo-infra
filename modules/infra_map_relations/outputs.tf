output "sns_topic_arn" {
  value       = aws_sns_topic.demo.arn
  description = "ARN of the demo SNS topic."
}

output "sqs_queue_url" {
  value       = aws_sqs_queue.demo.id
  description = "URL of the demo SQS queue."
}

output "state_machine_arn" {
  value       = aws_sfn_state_machine.pipeline.arn
  description = "ARN of the Step Functions state machine."
}
