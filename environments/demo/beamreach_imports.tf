# Terraform import blocks (requires Terraform >= 1.5)
# Resource blocks for these imports are in beamreach_imported.tf.
# Once `terraform apply` has completed the import, this file can be deleted;
# keep beamreach_imported.tf.

import {
  to = aws_s3_bucket.public_demo_prod_backups_682684724085
  id = "public-demo-prod-backups-682684724085"
}

import {
  to = aws_s3_bucket.public_demo_prod_exports_682684724085
  id = "public-demo-prod-exports-682684724085"
}
