# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "public-demo-prod-exports-682684724085"
resource "aws_s3_bucket" "public_demo_prod_exports_682684724085" {
  bucket              = "public-demo-prod-exports-682684724085"
  bucket_namespace    = "global"
  force_destroy       = false
  object_lock_enabled = false
  region              = local.aws_region
  tags = {
    Environment = local.env
    env         = "replay"
  }
  tags_all = {
    Environment = local.env
    env         = "replay"
  }
}

# __generated__ by Terraform from "public-demo-prod-backups-682684724085"
resource "aws_s3_bucket" "public_demo_prod_backups_682684724085" {
  bucket              = "public-demo-prod-backups-682684724085"
  bucket_namespace    = "global"
  force_destroy       = false
  object_lock_enabled = false
  region              = local.aws_region
  tags = {
    Environment = local.env
    env         = "replay"
  }
  tags_all = {
    Environment = local.env
    env         = "replay"
  }
}
