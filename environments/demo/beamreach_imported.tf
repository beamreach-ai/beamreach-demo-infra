# Resource blocks for 10 resource(s) imported by Beamreach Compass.
# Paired with the import blocks in beamreach_imports.tf.
# Review the attributes below against the live resources before applying.
#
# Not imported:
#   - public-demo-map-events (dynamodb_stream): DynamoDB streams have no standalone Terraform resource; they are configured via stream_enabled/stream_view_type on the aws_dynamodb_table that owns them

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "public_demo_tf_locks" {
  name         = "public-demo-tf-locks"
  billing_mode = "PAY_PER_REQUEST"

  # TODO: hash_key — not present in scanned attributes
  # TODO: attribute — not present in scanned attributes
}

# CloudWatch log group for map-publisher Lambda
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_publisher" {
  name              = "/aws/lambda/public-demo-map-publisher"
  retention_in_days = 7
}

# CloudWatch log group for map-stream-consumer Lambda
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_stream_consumer" {
  name              = "/aws/lambda/public-demo-map-stream-consumer"
  retention_in_days = 7
}

# CloudWatch log group for ECS demo
resource "aws_cloudwatch_log_group" "ecs_public_demo_demo" {
  name              = "/ecs/public-demo-demo"
  retention_in_days = 30
}

# Security group for finops idle ALB
resource "aws_security_group" "public_demo_finops_idle_alb" {
  name   = "public-demo-finops-idle-alb"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}

# Security group for prowler open RDP
resource "aws_security_group" "prowler_open_rdp_public_demo" {
  name   = "prowler-open-rdp-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}

# Security group for prowler open SSH
resource "aws_security_group" "prowler_open_ssh_public_demo" {
  name   = "prowler-open-ssh-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}

# Security group for prowler open all
resource "aws_security_group" "prowler_open_all_public_demo" {
  name   = "prowler-open-all-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}

# Security group for demo ALB
resource "aws_security_group" "public_demo_demo_alb" {
  name   = "public-demo-demo-alb"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}

# Security group for demo tasks
resource "aws_security_group" "public_demo_demo_tasks" {
  name   = "public-demo-demo-tasks"
  vpc_id = "vpc-0e040db1f49390291"
  # TODO: description — not present in scanned attributes
  # TODO: ingress — not present in scanned attributes
  # TODO: egress — not present in scanned attributes
}