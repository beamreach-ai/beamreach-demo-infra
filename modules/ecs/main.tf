resource "aws_security_group" "alb" {
  name        = "${var.env}-demo-alb"
  description = "Allow internet traffic to the demo ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

resource "aws_security_group" "node" {
  name        = "${var.env}-demo-tasks"
  description = "Allow ALB traffic to ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "app" {
  length  = 16
  special = true
}

resource "aws_secretsmanager_secret" "app" {
  name        = "${var.env}/demo/app"
  description = "Application configuration for the demo ECS task"
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({ apiKey = random_password.app.result })
}

resource "aws_cloudwatch_log_group" "demo" {
  name              = "/ecs/${var.env}-demo"
  retention_in_days = 30
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.env}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "demo_cluster" {
  name = "${var.env}-cluster"
}

# FINOPS: Commented out - ALB has no healthy targets (finding: finops:kosty:loadbalancer:682684724085:us-east-1:no-healthy-targets:public-demo-demo-alb)
# Estimated savings: ~$16.43/month (~$197/year). Uncomment to re-enable when needed.
# resource "aws_lb" "demo" {
#   name               = "${var.env}-demo-alb"
#   load_balancer_type = "application"
#   internal           = false
#   security_groups    = [aws_security_group.alb.id]
#   subnets            = var.public_subnet_ids
# }

# FINOPS: Commented out - Target group unused (ALB disabled due to no healthy targets)
# resource "aws_lb_target_group" "demo" {
#   name        = "${var.env}-demo-tg"
#   port        = var.container_port
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
#     matcher             = "200-399"
#   }
# }

# FINOPS: Commented out - Listener unused (ALB disabled due to no healthy targets)
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

resource "aws_ecs_task_definition" "demo_task" {
  family                   = "${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "demo-container"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      secrets = [
        {
          name      = "APP_CONFIG"
          valueFrom = aws_secretsmanager_secret.app.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.demo.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "demo"
        }
      }
    }
  ])
}

data "aws_region" "current" {}

resource "aws_ecs_service" "demo_service" {
  name            = "${var.env}-demo-service"
  cluster         = aws_ecs_cluster.demo_cluster.id
  task_definition = aws_ecs_task_definition.demo_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.node.id]
    assign_public_ip = false
  }

  # FINOPS: Load balancer attachment removed - ALB disabled due to no healthy targets
  # To re-enable, uncomment the ALB resources above and restore this block:
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.demo.arn
  #   container_name   = "demo-container"
  #   container_port   = var.container_port
  # }
  # depends_on = [aws_lb_listener.http]
}

resource "aws_sns_topic" "service_alerts" {
  name = "${var.env}-demo-service-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.alarm_emails)
  topic_arn = aws_sns_topic.service_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "service_cpu" {
  alarm_name          = "${var.env}-demo-service-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alert when the demo ECS service CPU stays above 70%"
  alarm_actions       = [aws_sns_topic.service_alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.demo_cluster.name
    ServiceName = aws_ecs_service.demo_service.name
  }
}
