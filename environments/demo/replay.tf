# Replay workload: a plain Next.js service in the private subnets, with ECS
# Exec enabled, reading its configuration from production-looking secrets.
#
# The task definition is defined here, at the root, so that other root-level
# modules can feed values into its environment.

module "replay" {
  source                  = "../../modules/replay"
  env                     = local.env
  vpc_id                  = module.beamreach-demo-vpc.vpc_id
  vpc_cidr_block          = "172.99.0.0/16"
  private_subnet_ids      = module.beamreach-demo-vpc.private_subnets
  private_route_table_ids = module.beamreach-demo-vpc.private_route_table_ids
  aws_region              = local.aws_region

  tags = {
    Environment = local.env
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "${local.env}-web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.replay.execution_role_arn
  task_role_arn            = module.replay.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "${module.replay.web_repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      linuxParameters = {
        initProcessEnabled = true
      }
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT", value = "3000" },
        { name = "NEXT_PUBLIC_APP_NAME", value = "storefront" },
        { name = "AWS_REGION", value = local.aws_region },
        { name = "UPLOADS_BUCKET", value = module.replay.bucket_names[0] }
      ]
      secrets = [
        { name = "DATABASE_URL", valueFrom = module.replay.secret_arns["prod/db-main"] },
        { name = "STRIPE_API_KEY", valueFrom = module.replay.secret_arns["prod/stripe-api-key"] },
        { name = "JWT_SIGNING_SECRET", valueFrom = module.replay.secret_arns["prod/jwt-signing"] }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = module.replay.web_log_group
          "awslogs-region"        = local.aws_region
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])

  tags = {
    Environment = local.env
    env         = "replay"
  }
}

resource "aws_ecs_service" "web" {
  name                   = "web"
  cluster                = module.replay.cluster_arn
  task_definition        = aws_ecs_task_definition.web.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [module.beamreach-demo-vpc.private_subnets[0]]
    security_groups  = [module.replay.web_security_group_id]
    assign_public_ip = false
  }

  tags = {
    Environment = local.env
    env         = "replay"
  }
}

output "replay" {
  value = {
    cluster_arn              = module.replay.cluster_arn
    service_arn              = aws_ecs_service.web.id
    task_definition          = aws_ecs_task_definition.web.arn
    task_role_arn            = module.replay.task_role_arn
    web_repository_url       = module.replay.web_repository_url
    db_backup_repository_url = module.replay.db_backup_repository_url
  }
}
