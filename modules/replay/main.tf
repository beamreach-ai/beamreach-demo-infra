# Replay environment: the plumbing a realistic private workload needs in this
# VPC, which has no NAT gateway.
#
#   * interface endpoints so a task can pull its image, write logs, use SSM
#     session channels (ECS Exec), call STS/Secrets Manager/SQS;
#   * an S3 gateway endpoint for the image layers;
#   * a CloudTrail trail (the account had none; management events reach
#     EventBridge only through a logging trail);
#   * an ECR pull-through cache so public images can be pulled privately;
#   * a handful of production-looking secrets and buckets for the workload's
#     task role to be allowed to read, so "what can this role reach" has real
#     answers.
#
# The workload itself (task definition + service) lives in the root module
# (environments/demo/replay.tf) so that other root-level modules can feed it.

data "aws_caller_identity" "current" {}

locals {
  name = "${var.env}-replay"
  tags = merge(var.tags, { env = "replay" })
}

# ── Endpoints ────────────────────────────────────────────────────────────────

resource "aws_security_group" "endpoints" {
  name        = "${local.name}-endpoints"
  description = "Interface endpoints: HTTPS from the VPC"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(local.tags, { Name = "${local.name}-endpoints" })
}

locals {
  interface_endpoints = ["ssmmessages", "ecr.api", "ecr.dkr", "logs", "sts", "secretsmanager", "sqs"]
}

resource "aws_vpc_endpoint" "interface" {
  for_each          = toset(local.interface_endpoints)
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type = "Interface"
  # One AZ: interface endpoints bill per AZ and the replay runs in one.
  subnet_ids          = [var.private_subnet_ids[0]]
  security_group_ids  = [aws_security_group.endpoints.id]
  private_dns_enabled = true
  tags                = merge(local.tags, { Name = "${local.name}-${each.key}" })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids
  tags              = merge(local.tags, { Name = "${local.name}-s3" })
}

# ── CloudTrail ───────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "trail" {
  bucket        = "${local.name}-trail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = local.tags
}

data "aws_iam_policy_document" "trail_bucket" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.name}"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${var.aws_region}:${data.aws_caller_identity.current.account_id}:trail/${local.name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = data.aws_iam_policy_document.trail_bucket.json
}

resource "aws_cloudtrail" "replay" {
  name                          = local.name
  s3_bucket_name                = aws_s3_bucket.trail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  tags                          = local.tags

  depends_on = [aws_s3_bucket_policy.trail]
}

# ── Images ───────────────────────────────────────────────────────────────────

resource "aws_ecr_pull_through_cache_rule" "public" {
  ecr_repository_prefix = "ecr-public"
  upstream_registry_url = "public.ecr.aws"
}

resource "aws_ecr_repository" "web" {
  name         = "demo-web"
  force_delete = true
  tags         = local.tags
}

# The decoy database image (published under a neutral name).
resource "aws_ecr_repository" "db_backup" {
  name         = "db-backup"
  force_delete = true
  tags         = local.tags
}

# ── Production-looking data the workload may read ────────────────────────────

locals {
  secrets = {
    "prod/db-main"        = { username = "app", password = "not-a-real-password", host = "db-main.internal", port = 5432 }
    "prod/stripe-api-key" = { api_key = "sk_live_placeholder_000000000000" }
    "prod/jwt-signing"    = { kid = "2026-10", secret = "placeholder-signing-secret" }
    "prod/smtp"           = { host = "smtp.internal", username = "mailer", password = "placeholder" }
  }
  buckets = ["prod-uploads", "prod-exports", "prod-backups"]
}

resource "aws_secretsmanager_secret" "prod" {
  for_each                = local.secrets
  name                    = each.key
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "prod" {
  for_each      = local.secrets
  secret_id     = aws_secretsmanager_secret.prod[each.key].id
  secret_string = jsonencode(each.value)
}

resource "aws_s3_bucket" "prod" {
  for_each      = toset(local.buckets)
  bucket        = "${var.env}-${each.key}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = local.tags
}

# ── Roles ────────────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${local.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_extra" {
  name = "pull-through-and-secrets"
  role = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:BatchImportUpstreamImage"]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/ecr-public/*"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [for s in aws_secretsmanager_secret.prod : s.arn]
      },
    ]
  })
}

# The workload's task role: what a credential found inside the container can
# use. Read access to the production-looking data, plus the SSM channels that
# ECS Exec needs.
resource "aws_iam_role" "task" {
  name               = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "task" {
  name = "app"
  role = aws_iam_role.task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadProdSecrets"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:prod/*"
      },
      {
        Sid      = "ReadProdBuckets"
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = flatten([for b in aws_s3_bucket.prod : [b.arn, "${b.arn}/*"]])
      },
      {
        Sid    = "EcsExec"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ]
        Resource = "*"
      },
    ]
  })
}

# ── Cluster and logs ─────────────────────────────────────────────────────────

resource "aws_ecs_cluster" "replay" {
  name = local.name
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/${local.name}/web"
  retention_in_days = 14
  tags              = local.tags
}

resource "aws_security_group" "web" {
  name        = "${local.name}-web"
  description = "Replay workload: egress to the VPC only"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(local.tags, { Name = "${local.name}-web" })
}
