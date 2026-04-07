output "inventory" {
  description = "Inventory of the FinOps demo resources."
  value = {
    ebs = {
      orphan_gp2_volume_id = aws_ebs_volume.orphan_gp2.id
      orphan_gp2_size_gb   = aws_ebs_volume.orphan_gp2.size
      snapshot_ids         = [for snapshot in aws_ebs_snapshot.orphan_gp2 : snapshot.id]
    }
    s3 = {
      waste_bucket = aws_s3_bucket.waste.bucket
      good_bucket  = aws_s3_bucket.good.bucket
    }
    # alb output removed - idle ALB resources were deleted (FinOps finding: no healthy targets)
    fargate = var.create_fargate_demo ? {
      cluster_name = aws_ecs_cluster.fargate[0].name
      service_name = aws_ecs_service.fargate[0].name
    } : null
  }
}

output "s3_seed_note" {
  description = "Operational note for the S3 waste demo."
  value       = "Seed 1-5 GB of dummy objects after apply outside Terraform so large object payloads do not end up in state or plans."
}
