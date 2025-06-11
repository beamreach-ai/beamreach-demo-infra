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


module "demo-services" {
  source    = "../../modules/ecs"
  env       = local.env
  subnet_ids = module.beamreach-demo-vpc.private_subnets
  vpc_id     = module.beamreach-demo-vpc.vpc_id
}

module "iam" {
  source = "../../modules/iam"
  env    = local.env
}

resource "aws_iam_role_policy_attachment" "demo_123_s3_readonly" {
  role       = "demo-123"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # GitHub's trusted root CA
}
```