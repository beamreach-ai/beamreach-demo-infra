# DynamoDB table: public-demo-tf-locks
resource "aws_dynamodb_table" "public_demo_tf_locks" {
  name         = "public-demo-tf-locks"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# CloudWatch Log Group: /aws/lambda/public-demo-map-publisher
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_publisher" {
  name              = "/aws/lambda/public-demo-map-publisher"
  retention_in_days = 7
}

# CloudWatch Log Group: /aws/lambda/public-demo-map-stream-consumer
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_stream_consumer" {
  name              = "/aws/lambda/public-demo-map-stream-consumer"
  retention_in_days = 7
}

# CloudWatch Log Group: /ecs/public-demo-demo
resource "aws_cloudwatch_log_group" "ecs_public_demo_demo" {
  name              = "/ecs/public-demo-demo"
  retention_in_days = 30
}

# Security Group: public-demo-finops-idle-alb
resource "aws_security_group" "public_demo_finops_idle_alb" {
  name        = "public-demo-finops-idle-alb"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-rdp-public-demo
resource "aws_security_group" "prowler_open_rdp_public_demo" {
  name        = "prowler-open-rdp-public-demo"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-ssh-public-demo
resource "aws_security_group" "prowler_open_ssh_public_demo" {
  name        = "prowler-open-ssh-public-demo"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-all-public-demo
resource "aws_security_group" "prowler_open_all_public_demo" {
  name        = "prowler-open-all-public-demo"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}

# Security Group: public-demo-demo-alb
resource "aws_security_group" "public_demo_demo_alb" {
  name        = "public-demo-demo-alb"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}

# Security Group: public-demo-demo-tasks
resource "aws_security_group" "public_demo_demo_tasks" {
  name        = "public-demo-demo-tasks"
  description = "Managed by Terraform"
  vpc_id      = "vpc-0e040db1f49390291"
}