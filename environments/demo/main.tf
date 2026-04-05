terraform {
  backend "s3" {
    bucket         = "beamreach-public-demo-tf-states"
    key            = "public-demo/terraform-public-demo.tfstate"
    region         = "us-east-1"
    profile        = "public-demo"
    dynamodb_table = "public-demo-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = local.aws_region
  profile = "public-demo"
}

locals {
  env        = "public-demo"
  aws_region = "us-east-1"
  account    = "682684724085"
  vpc_name   = "beamreach-demo-vpc"
  docker_images = {
    multistage = {
      repo_name  = "demo-multistage"
      dockerfile = "dockerfiles/Dockerfile.multistage"
    }
    versions = {
      repo_name  = "demo-versions"
      dockerfile = "dockerfiles/Dockerfile.versions"
    }
    secrets = {
      repo_name  = "demo-secrets"
      dockerfile = "dockerfiles/Dockerfile.secrets"
    }
  }
}

resource "aws_ecr_repository" "docker_images" {
  for_each = local.docker_images

  name                 = each.value.repo_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = local.env
    Dockerfile  = each.value.dockerfile
  }
}


module "beamreach-demo-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "172.99.0.0/16"

  azs             = ["${local.aws_region}a", "${local.aws_region}b"]
  private_subnets = ["172.99.2.0/24", "172.99.4.0/24"]
  public_subnets  = ["172.99.1.0/24", "172.99.3.0/24"]

  enable_ipv6        = false
  enable_nat_gateway = false
  single_nat_gateway = false

  public_subnet_tags = {
    Name = "${local.env}-public"
  }

  private_subnet_tags = {
    Name = "${local.env}-private"
  }

  tags = {
    Environment = local.env
  }

  vpc_tags = {
    Name = local.vpc_name
  }
}

module "finops_demo" {
  source = "../../modules/finops_demo"

  env                 = local.env
  vpc_id              = module.beamreach-demo-vpc.vpc_id
  vpc_cidr_block      = "172.99.0.0/16"
  public_subnet_ids   = module.beamreach-demo-vpc.public_subnets
  private_subnet_ids  = module.beamreach-demo-vpc.private_subnets
  create_fargate_demo = false
}


module "demo-services" {
  source            = "../../modules/ecs"
  env               = local.env
  subnet_ids        = module.beamreach-demo-vpc.private_subnets
  public_subnet_ids = module.beamreach-demo-vpc.public_subnets
  vpc_id            = module.beamreach-demo-vpc.vpc_id
  container_image   = "${aws_ecr_repository.docker_images["multistage"].repository_url}:latest"
  alarm_emails      = ["alerts@example.com"]
}

module "infra_map_demo" {
  source             = "../../modules/infra_map_demo"
  env                = local.env
  vpc_id             = module.beamreach-demo-vpc.vpc_id
  private_subnet_ids = module.beamreach-demo-vpc.private_subnets
  public_subnet_ids  = module.beamreach-demo-vpc.public_subnets
  container_image    = "${aws_ecr_repository.docker_images["versions"].repository_url}:latest"
}

module "infra_map_relations" {
  source           = "../../modules/infra_map_relations"
  env              = local.env
  ecs_cluster_name = module.infra_map_demo.ecs_cluster_name
  ecs_service_name = module.infra_map_demo.ecs_service_name
}

module "iam" {
  source = "../../modules/iam"
  env    = local.env
}


module "prowler_findings" {
  source              = "../../modules/prowler_findings"
  env                 = local.env
  vpc_id              = module.beamreach-demo-vpc.vpc_id
  insecure_task_image = "${aws_ecr_repository.docker_images["secrets"].repository_url}:latest"
}

resource "aws_iam_role" "beamreach_compass" {
  name = "BeamreachCompassRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::662863386798:root"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "sts:ExternalId" = "beamreach-compass-qwmTsJGDdnga5iqcSwRWpGIy"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "beamreach_compass_readonly" {
  role       = aws_iam_role.beamreach_compass.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's trusted root CA
}
