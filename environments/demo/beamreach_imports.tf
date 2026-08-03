# Terraform import blocks (requires Terraform >= 1.5)
# Resource blocks for these imports are in beamreach_imported.tf.
# Once `terraform apply` has completed the import, this file can be deleted;
# keep beamreach_imported.tf.

import {
  to = aws_dynamodb_table.public_demo_tf_locks
  id = "public-demo-tf-locks"
}

import {
  to = aws_cloudwatch_log_group.aws_lambda_public_demo_map_publisher
  id = "/aws/lambda/public-demo-map-publisher"
}

import {
  to = aws_cloudwatch_log_group.aws_lambda_public_demo_map_stream_consumer
  id = "/aws/lambda/public-demo-map-stream-consumer"
}

import {
  to = aws_cloudwatch_log_group.ecs_public_demo_demo
  id = "/ecs/public-demo-demo"
}

import {
  to = aws_security_group.public_demo_finops_idle_alb
  id = "sg-0472e74ec4e695698"
}

import {
  to = aws_security_group.prowler_open_rdp_public_demo
  id = "sg-05ad3f1c2828feddf"
}

import {
  to = aws_security_group.prowler_open_ssh_public_demo
  id = "sg-088ea337212bde08e"
}

import {
  to = aws_security_group.prowler_open_all_public_demo
  id = "sg-0addb073d402399d1"
}

import {
  to = aws_security_group.public_demo_demo_alb
  id = "sg-0b76178d978eabd39"
}

import {
  to = aws_security_group.public_demo_demo_tasks
  id = "sg-0ee4127458f5295a0"
}
