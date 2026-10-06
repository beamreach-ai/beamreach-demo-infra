# Service modules. Generated; manual edits may be overwritten.

module "svc_account" {
  source          = "./services/_account"
  alert_queue_arn = "arn:aws:sqs:us-east-1:662863386798:beamreach-honeypot-alerts-beamreach-demo-cloud"
}

module "svc_ci_artifacts_reader" {
  source                  = "./services/ci_artifacts_reader"
  workspace_id            = "beamreach-demo"
  alert_queue_arn         = "arn:aws:sqs:us-east-1:662863386798:beamreach-honeypot-alerts-beamreach-demo-cloud"
  alert_delivery_role_arn = module.svc_account.alert_delivery_role_arn
}

module "svc_svc_backup_reporting" {
  source                  = "./services/svc_backup_reporting"
  workspace_id            = "beamreach-demo"
  alert_queue_arn         = "arn:aws:sqs:us-east-1:662863386798:beamreach-honeypot-alerts-beamreach-demo-cloud"
  alert_delivery_role_arn = module.svc_account.alert_delivery_role_arn
  vpc_id                  = "vpc-0e040db1f49390291"
  subnet_ids              = ["subnet-06722548578133122"]
  cluster_arn             = "arn:aws:ecs:us-east-1:682684724085:cluster/public-demo-replay"
  image                   = "682684724085.dkr.ecr.us-east-1.amazonaws.com/db-backup:latest"
}

output "svc_ci_artifacts_reader_access_key_id" {
  value = module.svc_ci_artifacts_reader.access_key_id
}
