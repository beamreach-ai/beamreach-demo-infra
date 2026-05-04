locals {
  tags = {
    Environment = var.env
    ManagedBy   = "terraform"
  }

  container_name = "api"
}

resource "aws_secretsmanager_secret" "app_config" {
  name        = var.secret_name
  description = "Dummy application config used by the infra map demo service."
  tags        = local.tags
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id     = aws_secretsmanager_secret.app_config.id
  secret_string = var.secret_payload
}

# COMMENTED OUT: ALB has no healthy targets - see finops:kosty:loadbalancer:682684724085:us-east-1:no-healthy-targets:demo-map-alb
# Uncomment to restore the ALB infrastructure
# resource "aws_security_group" "alb" {
#   name        = var.alb_security_group_name
#   description = "Allow public web traffic to the infra map demo ALB."
#   vpc_id      = var.vpc_id
#
#   ingress {
#     description = "Allow HTTP from anywhere"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     description = "Allow HTTPS from anywhere"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = merge(local.tags, { Name = var.alb_security_group_name })
# }

resource "aws_security_group" "ecs_tasks" {
  name        = var.ecs_security_group_name
  description = "Security group for the infra map demo ECS tasks."
  vpc_id      = var.vpc_id

  # COMMENTED OUT: ALB ingress rule removed since ALB is disabled
  # Uncomment when restoring ALB infrastructure
  # ingress {
  #   description     = "Allow HTTP from ALB"
  #   from_port       = 80
  #   to_port         = 80
  #   protocol        = "tcp"
  #   security_groups = [aws_security_group.alb.id]
  # }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = var.ecs_security_group_name })
}

# COMMENTED OUT: ALB has no healthy targets - see finops:kosty:loadbalancer:682684724085:us-east-1:no-healthy-targets:demo-map-alb
# Uncomment to restore the ALB infrastructure
# resource "aws_lb" "demo" {
#   name               = var.alb_name
#   load_balancer_type = "application"
#   internal           = false
#   security_groups    = [aws_security_group.alb.id]
#   subnets            = var.public_subnet_ids
#   tags               = local.tags
# }

# COMMENTED OUT: Target group for disabled ALB
# Uncomment to restore the ALB infrastructure
# resource "aws_lb_target_group" "demo" {
#   name        = var.target_group_name
#   port        = 80
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = var.vpc_id
#
#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#     interval            = 30
#     timeout             = 5
#     matcher             = "200"
#   }
#
#   tags = local.tags
# }

# COMMENTED OUT: Listener for disabled ALB
# Uncomment to restore the ALB infrastructure
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.demo.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.demo.arn
#   }
# }

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.env}-map-demo-ecs-task-execution"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "demo" {
  name = var.cluster_name
  tags = local.tags
}

resource "aws_ecs_task_definition" "api" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      secrets = [
        {
          name      = "APP_SECRET"
          valueFrom = aws_secretsmanager_secret.app_config.arn
        }
      ]
    }
  ])

  tags = local.tags
}

resource "aws_ecs_service" "api" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.demo.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  # COMMENTED OUT: ALB integration removed since ALB is disabled
  # Uncomment when restoring ALB infrastructure
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.demo.arn
  #   container_name   = local.container_name
  #   container_port   = 80
  # }
  #
  # depends_on = [aws_lb_listener.http]

  tags = local.tags
}
