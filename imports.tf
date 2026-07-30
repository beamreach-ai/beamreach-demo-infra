# Terraform import blocks (requires Terraform >= 1.5)
# After merging this PR, run: terraform plan -generate-config-out=generated.tf

import {
  to = module.environments.module.demo.aws_dynamodb_stream.public_demo_map_events
  id = "arn:aws:dynamodb:us-east-1:682684724085:table/public-demo-map-events/stream/2025-12-23T22:50:25.152"
}

import {
  to = module.environments.module.demo.aws_dynamodb_table.public_demo_tf_locks
  id = "arn:aws:dynamodb:us-east-1:682684724085:table/public-demo-tf-locks"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.aws_lambda_public_demo_map_publisher
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/aws/lambda/public-demo-map-publisher:*"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.aws_lambda_public_demo_map_stream_consumer
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/aws/lambda/public-demo-map-stream-consumer:*"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.ecs_public_demo_demo
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/ecs/public-demo-demo:*"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_finops_idle_alb
  id = "sg-0472e74ec4e695698"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_rdp_public_demo
  id = "sg-05ad3f1c2828feddf"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_ssh_public_demo
  id = "sg-088ea337212bde08e"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_all_public_demo
  id = "sg-0addb073d402399d1"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_demo_alb
  id = "sg-0b76178d978eabd39"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_demo_tasks
  id = "sg-0ee4127458f5295a0"
}
