# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "sg-0472e74ec4e695698"
resource "aws_security_group" "public_demo_finops_idle_alb" {
  description = "Internal security group for the idle ALB FinOps demo."
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["172.99.0.0/16"]
    description      = "Allow HTTP from within the VPC"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
  }]
  name                   = "public-demo-finops-idle-alb"
  region                 = local.aws_region
  tags = {
    Demo        = "finops"
    Environment = local.env
    ManagedBy   = "terraform"
    Name        = "public-demo-finops-idle-alb"
  }
  tags_all = {
    Demo        = "finops"
    Environment = local.env
    ManagedBy   = "terraform"
    Name        = "public-demo-finops-idle-alb"
  }
  vpc_id = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform from "sg-088ea337212bde08e"
resource "aws_security_group" "prowler_open_ssh_public_demo" {
  description = "Security group with SSH open to the world for demo purposes"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "SSH from anywhere"
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  }]
  name                   = "prowler-open-ssh-public-demo"
  region                 = local.aws_region
  tags = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  tags_all = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  vpc_id = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform from "sg-0b76178d978eabd39"
resource "aws_security_group" "public_demo_demo_alb" {
  description = "Allow internet traffic to the demo ALB"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "HTTP"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 80
    }, {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "HTTPS"
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 443
  }]
  name                   = "public-demo-demo-alb"
  region                 = local.aws_region
  tags                   = {}
  tags_all               = {}
  vpc_id                 = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform from "/aws/lambda/public-demo-map-publisher"
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_publisher" {
  deletion_protection_enabled = false
  log_group_class             = "STANDARD"
  name                        = "/aws/lambda/public-demo-map-publisher"
  region                      = local.aws_region
  retention_in_days           = 7
  skip_destroy                = false
  tags = {
    Environment = local.env
    ManagedBy   = "terraform"
  }
  tags_all = {
    Environment = local.env
    ManagedBy   = "terraform"
  }
}

# __generated__ by Terraform from "/aws/lambda/public-demo-map-stream-consumer"
resource "aws_cloudwatch_log_group" "aws_lambda_public_demo_map_stream_consumer" {
  deletion_protection_enabled = false
  log_group_class             = "STANDARD"
  name                        = "/aws/lambda/public-demo-map-stream-consumer"
  region                      = local.aws_region
  retention_in_days           = 7
  skip_destroy                = false
  tags = {
    Environment = local.env
    ManagedBy   = "terraform"
  }
  tags_all = {
    Environment = local.env
    ManagedBy   = "terraform"
  }
}

# __generated__ by Terraform from "/ecs/public-demo-demo"
resource "aws_cloudwatch_log_group" "ecs_public_demo_demo" {
  deletion_protection_enabled = false
  log_group_class             = "STANDARD"
  name                        = "/ecs/public-demo-demo"
  region                      = local.aws_region
  retention_in_days           = 30
  skip_destroy                = false
  tags                        = {}
  tags_all                    = {}
}

# __generated__ by Terraform from "sg-0ee4127458f5295a0"
resource "aws_security_group" "public_demo_demo_tasks" {
  description = "Allow ALB traffic to ECS tasks"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = []
    description      = ""
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = ["sg-0b76178d978eabd39"]
    self             = false
    to_port          = 80
  }]
  name                   = "public-demo-demo-tasks"
  region                 = local.aws_region
  tags                   = {}
  tags_all               = {}
  vpc_id                 = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform from "sg-05ad3f1c2828feddf"
resource "aws_security_group" "prowler_open_rdp_public_demo" {
  description = "Security group with RDP exposed to the world"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 3389
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 3389
  }]
  name                   = "prowler-open-rdp-public-demo"
  region                 = local.aws_region
  tags = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  tags_all = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  vpc_id = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform from "sg-0addb073d402399d1"
resource "aws_security_group" "prowler_open_all_public_demo" {
  description = "Security group with all ports open to the world"
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = ""
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  name                   = "prowler-open-all-public-demo"
  region                 = local.aws_region
  tags = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  tags_all = {
    Environment = local.env
    Purpose     = "prowler-demo"
  }
  vpc_id = module.beamreach-demo-vpc.vpc_id
}

# __generated__ by Terraform
resource "aws_dynamodb_table" "public_demo_tf_locks" {
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "LockID"
  name                        = "public-demo-tf-locks"
  read_capacity               = 0
  region                      = local.aws_region
  stream_enabled              = false
  table_class                 = "STANDARD"
  tags                        = {}
  tags_all                    = {}
  write_capacity              = 0
  attribute {
    name = "LockID"
    type = "S"
  }
  point_in_time_recovery {
    enabled                 = false
  }
  ttl {
    enabled        = false
  }
}
