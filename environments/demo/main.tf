```
terraform {
  backend "s3" {
    bucket         = "beamreach-tf-states"
    key            = "demo123/terraform-123.tfstate"
    region         = "us-east-1"
    profile        = "beamreach"
    dynamodb_table = "demo123-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = local.aws_region
  profile = "beamreach"
}

locals {
  env        = "demo123"
  aws_region = "eu-central-1"
  account    = "662863386798"
  vpc_name = "beamreach-demo-vpc"
}


module "beamreach-demo-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "172.99.0.0/16"

  azs             = ["${local.aws_region}a", "${local.aws_region}b"]
  private_subnets = ["172.99.2.0/24", "172.99.4.0/24"]
  public_subnets  = ["172.99.1.0/24", "172.99.3.0/24"]

  enable_ipv6            = false
  enable_nat_gateway     = true
  single_nat_gateway     = true

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

resource "aws_db_subnet_group" "beamreach_demo" {
  name       = "beamreach-demo-subnet-group"
  subnet_ids = module.beamreach-demo-vpc.private_subnets

  tags = {
    Name        = "beamreach-demo-subnet-group"
    Environment = local.env
  }
}

resource "aws_security_group" "beamreach_demo_rds" {
  name        = "beamreach-demo-rds-sg"
  description = "Security group for beamreach-demo RDS instance"
  vpc_id      = module.beamreach-demo-vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [module.beamreach-demo-vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "beamreach-demo-rds-sg"
    Environment = local.env
  }
}

resource "aws_db_instance" "beamreach_demo" {
  identifier = "beamreach-demo"
  
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true
  
  db_name  = "beamreach"
  username = "postgres"
  manage_master_user_password = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  db_subnet_group_name   = aws_db_subnet_group.beamreach_demo.name
  vpc_security_group_ids = [aws_security_group.beamreach_demo_rds.id]
  
  skip_final_snapshot = true
  deletion_protection = false
  
  tags = {
    Name        =