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

module "svc_responder" {
  source = "./services/_responder"
}

output "svc_ci_artifacts_reader_access_key_id" {
  value = module.svc_ci_artifacts_reader.access_key_id
}

output "svc_responder_role_arn" {
  value = module.svc_responder.responder_role_arn
}
