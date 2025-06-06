resource "aws_security_group" "node" {
  name        = "demo-node-open"
  description = "Allow inbound access for nodejs app"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

resource "aws_ecs_task_definition" "demo_task" {
  family                   = "${var.env}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions    = jsonencode([
    {
      name      = "demo-container"
      image     = "amazonlinux"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "demo_service" {
  name            = "${var.env}-demo-service"
  cluster         = aws_ecs_cluster.demo_cluster.id
  task_definition = aws_ecs_task_definition.demo_task.arn
  launch_type     = "FARGATE"
  desired_count   = 0

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [] # Add security group IDs if available
    assign_public_ip = true
  }
}

resource "aws_ecr_repository" "default" {
  name = "demo-multistage"
}

resource "aws_ecr_repository" "secrets" {
  name = "demo-secrets"
}

resource "aws_ecr_repository" "versions" {
  name = "demo-versions"
}