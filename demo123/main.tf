


resource "aws_iam_role" "wide_open_role" {
  name = "wide-open-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "wide-open-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = "*",
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Open security group for demo purposes"
  vpc_id      = "vpc-12345678"  # Replace with your actual VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_sns_topic" "unencrypted_topic" {
  name = "demo-unencrypted-topic"
  # No kms_master_key_id specified — this makes it unencrypted
}