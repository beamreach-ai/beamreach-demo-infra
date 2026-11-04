# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform
resource "aws_dynamodb_table" "public_demo_tf_locks" {
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = false
  hash_key                    = "LockID"
  name                        = "public-demo-tf-locks"
  read_capacity               = 0
  region                      = "us-east-1"
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
