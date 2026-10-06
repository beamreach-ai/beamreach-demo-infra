output "cluster_arn" {
  value = aws_ecs_cluster.replay.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.replay.name
}

output "execution_role_arn" {
  value = aws_iam_role.execution.arn
}

output "task_role_arn" {
  value = aws_iam_role.task.arn
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "web_log_group" {
  value = aws_cloudwatch_log_group.web.name
}

output "web_repository_url" {
  value = aws_ecr_repository.web.repository_url
}

output "db_backup_repository_url" {
  value = aws_ecr_repository.db_backup.repository_url
}

output "secret_arns" {
  value = { for k, s in aws_secretsmanager_secret.prod : k => s.arn }
}

output "bucket_names" {
  value = [for b in aws_s3_bucket.prod : b.bucket]
}

output "trail_arn" {
  value = aws_cloudtrail.replay.arn
}
