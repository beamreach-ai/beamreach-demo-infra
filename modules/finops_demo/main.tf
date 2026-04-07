locals {
  name_prefix      = "${var.env}-finops"
  idle_alb_subnets = var.private_subnet_ids

  tags = merge(
    {
      Environment = var.env
      ManagedBy   = "terraform"
      Demo        = "finops"
    },
    var.tags,
  )

  waste_bucket_name = lower("beamreach-${var.env}-${data.aws_caller_identity.current.account_id}-finops-waste")
  good_bucket_name  = lower("beamreach-${var.env}-${data.aws_caller_identity.current.account_id}-finops-good")
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_subnet" "private_az" {
  id = var.private_subnet_ids[0]
}

resource "aws_s3_bucket" "waste" {
  bucket        = local.waste_bucket_name
  force_destroy = true

  tags = merge(
    local.tags,
    {
      Name         = local.waste_bucket_name
      FinOpsSignal = "missing-lifecycle"
    },
  )
}

resource "aws_s3_bucket_public_access_block" "waste" {
  bucket                  = aws_s3_bucket.waste.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "good" {
  bucket        = local.good_bucket_name
  force_destroy = true

  tags = merge(
    local.tags,
    {
      Name         = local.good_bucket_name
      FinOpsSignal = "lifecycle-baseline"
    },
  )
}

resource "aws_s3_bucket_public_access_block" "good" {
  bucket                  = aws_s3_bucket.good.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "good" {
  bucket = aws_s3_bucket.good.id

  rule {
    id     = "transition-demo-objects"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_security_group" "idle_alb" {
  name        = "${local.name_prefix}-idle-alb"
  description = "Internal security group for the idle ALB FinOps demo."
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from within the VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-idle-alb" })
}

resource "aws_lb" "idle" {
  name               = "${local.name_prefix}-idle-alb"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.idle_alb.id]
  subnets            = local.idle_alb_subnets

  tags = merge(
    local.tags,
    {
      Name         = "${local.name_prefix}-idle-alb"
      FinOpsSignal = "idle-load-balancer"
    },
  )
}

resource "aws_lb_target_group" "idle" {
  name        = "${local.name_prefix}-idle-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
  }

  tags = merge(
    local.tags,
    {
      Name         = "${local.name_prefix}-idle-tg"
      FinOpsSignal = "unused-target-group"
    },
  )
}

resource "aws_lb_listener" "idle_http" {
  load_balancer_arn = aws_lb.idle.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.idle.arn
  }
}

resource "aws_security_group" "fargate" {
  count = var.create_fargate_demo ? 1 : 0

  name        = "${local.name_prefix}-fargate"
  description = "Outbound-only security group for the FinOps Fargate demo."
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "${local.name_prefix}-fargate" })
}

resource "aws_cloudwatch_log_group" "fargate" {
  count = var.create_fargate_demo ? 1 : 0

  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 14

  tags = local.tags
}

resource "aws_iam_role" "fargate_execution" {
  count = var.create_fargate_demo ? 1 : 0

  name = "${local.name_prefix}-fargate-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "fargate_execution" {
  count = var.create_fargate_demo ? 1 : 0

  role       = aws_iam_role.fargate_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "fargate" {
  count = var.create_fargate_demo ? 1 : 0

  name = "${local.name_prefix}-cluster"
  tags = local.tags
}

resource "aws_ecs_task_definition" "fargate" {
  count = var.create_fargate_demo ? 1 : 0

  family                   = "${local.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.fargate_cpu)
  memory                   = tostring(var.fargate_memory)
  execution_role_arn       = aws_iam_role.fargate_execution[0].arn

  container_definitions = jsonencode([
    {
      name      = "finops-demo"
      image     = "public.ecr.aws/docker/library/busybox:latest"
      essential = true
      command   = ["sh", "-c", "while true; do sleep 3600; done"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.fargate[0].name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(
    local.tags,
    {
      FinOpsSignal = "always-on-fargate"
    },
  )
}

resource "aws_ecs_service" "fargate" {
  count = var.create_fargate_demo ? 1 : 0

  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.fargate[0].id
  task_definition = aws_ecs_task_definition.fargate[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.fargate[0].id]
    assign_public_ip = true
  }

  tags = merge(
    local.tags,
    {
      FinOpsSignal = "scale-to-zero-candidate"
    },
  )
}
