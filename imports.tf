# Terraform import blocks (requires Terraform >= 1.5)
# After merging this PR, run: terraform plan -generate-config-out=generated.tf

import {
  to = aws_cloudwatch_log_group.aws_lambda_public_demo_map_publisher
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/aws/lambda/public-demo-map-publisher:*"
}
