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

# IAM role: MapperRole
resource "aws_iam_role" "mapperrole" {
  name                 = "MapperRole"
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM role: OrganizationAccountAccessRole
resource "aws_iam_role" "organizationaccountaccessrole" {
  name                 = "OrganizationAccountAccessRole"
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::682684724085:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM role: mcp-aws-read-beamreach-demo
resource "aws_iam_role" "mcp_aws_read_beamreach_demo" {
  name                 = "mcp-aws-read-beamreach-demo"
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM role: mcp-aws-write-beamreach-demo
resource "aws_iam_role" "mcp_aws_write_beamreach_demo" {
  name                 = "mcp-aws-write-beamreach-demo"
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
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

# Network Interface: eni-01188bd96787615d8
resource "aws_network_interface" "eni_01188bd96787615d8" {
  subnet_id = "subnet-0d064794175b690ba"
}

# Network Interface: eni-01b7c98a54285aa49
resource "aws_network_interface" "eni_01b7c98a54285aa49" {
  subnet_id = "subnet-0d5dff17354aa4deb"
}

# Network Interface: eni-02165ad2a44f3d6c2
resource "aws_network_interface" "eni_02165ad2a44f3d6c2" {
  subnet_id = "subnet-0d064794175b690ba"
}

# Network Interface: eni-067e370b81022b197
resource "aws_network_interface" "eni_067e370b81022b197" {
  subnet_id = "subnet-06722548578133122"
}

# Network Interface: eni-097a1804d33df3f3a
resource "aws_network_interface" "eni_097a1804d33df3f3a" {
  subnet_id = "subnet-0d064794175b690ba"
}

# Network Interface: eni-0a66fbb4f629a8d6f
resource "aws_network_interface" "eni_0a66fbb4f629a8d6f" {
  subnet_id = "subnet-0d064794175b690ba"
}

# Network Interface: eni-0fde66dde4682f3b8
resource "aws_network_interface" "eni_0fde66dde4682f3b8" {
  subnet_id = "subnet-0d5dff17354aa4deb"
}

# Security Group: default
resource "aws_security_group" "default" {
  name   = "default"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: demo-map-alb-sg
resource "aws_security_group" "demo_map_alb_sg" {
  name   = "demo-map-alb-sg"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: public-demo-finops-idle-alb
resource "aws_security_group" "public_demo_finops_idle_alb" {
  name   = "public-demo-finops-idle-alb"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-rdp-public-demo
resource "aws_security_group" "prowler_open_rdp_public_demo" {
  name   = "prowler-open-rdp-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-ssh-public-demo
resource "aws_security_group" "prowler_open_ssh_public_demo" {
  name   = "prowler-open-ssh-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: prowler-open-all-public-demo
resource "aws_security_group" "prowler_open_all_public_demo" {
  name   = "prowler-open-all-public-demo"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: public-demo-demo-alb
resource "aws_security_group" "public_demo_demo_alb" {
  name   = "public-demo-demo-alb"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: demo-map-ecs-sg
resource "aws_security_group" "demo_map_ecs_sg" {
  name   = "demo-map-ecs-sg"
  vpc_id = "vpc-0e040db1f49390291"
}

# Security Group: public-demo-demo-tasks
resource "aws_security_group" "public_demo_demo_tasks" {
  name   = "public-demo-demo-tasks"
  vpc_id = "vpc-0e040db1f49390291"
}