terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

resource "random_pet" "suffix" {
  length = 2
}

resource "aws_s3_bucket" "public_demo" {
  bucket        = "beamreach-${var.env}-${random_pet.suffix.id}"
  force_destroy = true

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_s3_bucket_public_access_block" "public_demo" {
  bucket                  = aws_s3_bucket.public_demo.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.public_demo.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowPublicRead",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = ["${aws_s3_bucket.public_demo.arn}/*"]
      }
    ]
  })
}

resource "aws_security_group" "open_ssh" {
  name        = "prowler-open-ssh-${var.env}"
  description = "Security group with SSH open to the world for demo purposes"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from anywhere"
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

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_iam_user" "over_permissive" {
  name          = "prowler-overpermissive-${var.env}"
  force_destroy = true

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_iam_user_policy" "wildcard" {
  name = "prowler-wildcard-${var.env}"
  user = aws_iam_user.over_permissive.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowAllActions",
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_account_password_policy" "weak" {
  minimum_password_length        = 6
  require_lowercase_characters   = false
  require_numbers                = false
  require_uppercase_characters   = false
  require_symbols                = false
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 0
  password_reuse_prevention      = 0
}

resource "aws_s3_bucket" "website" {
  bucket        = "beamreach-${var.env}-website-${random_pet.suffix.id}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = var.env
    Purpose     = "prowler-website-demo"
  }
}

resource "aws_security_group" "open_all_ports" {
  name        = "prowler-open-all-${var.env}"
  description = "Security group with all ports open to the world"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_security_group_rule" "open_all_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.open_all_ports.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "open_rdp" {
  name        = "prowler-open-rdp-${var.env}"
  description = "Security group with RDP exposed to the world"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_security_group_rule" "open_rdp_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.open_rdp.id
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_iam_role" "assume_any" {
  name = "prowler-assume-any-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.env
    Purpose     = "prowler-demo"
  }
}

resource "aws_iam_role_policy" "assume_any_policy" {
  name = "prowler-assume-any-policy-${var.env}"
  role = aws_iam_role.assume_any.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowEverything",
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_group" "legacy_admins" {
  name = "prowler-legacy-admins-${var.env}"
  path = "/"
}

resource "aws_iam_group_policy" "legacy_admins_policy" {
  name  = "prowler-legacy-admins-policy-${var.env}"
  group = aws_iam_group.legacy_admins.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "LegacyAdminWildcard",
        Effect   = "Allow",
        Action   = "*",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_group_membership" "over_permissive_membership" {
  user  = aws_iam_user.over_permissive.name
  groups = [
    aws_iam_group.legacy_admins.name
  ]
}

resource "aws_ssm_parameter" "plaintext_secret" {
  name        = "/demo/${var.env}/db_password"
  description = "Hardcoded plaintext password for demo"
  type        = "String"
  value       = "PlainTextPassword123!"

  tags = {
    Environment = var.env
    ManagedBy   = "prowler-demo"
  }
}

resource "aws_ecs_task_definition" "insecure" {
  family                   = "${var.env}-insecure-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "128"
  memory                   = "256"

  container_definitions = jsonencode([
    {
      name      = "insecure-container"
      image     = "public.ecr.aws/amazonlinux/amazonlinux:latest"
      essential = true
      command   = ["sleep", "3600"]
      environment = [
        {
          name  = "HARDCODED_API_KEY"
          value = "api-key-${var.env}-123456"
        },
        {
          name  = "DB_PASSWORD"
          value = "P@ssw0rd123"
        }
      ]
    }
  ])
}
