# Service modules. Generated; manual edits may be overwritten.

module "svc_responder" {
  source = "./services/_responder"
}

output "svc_responder_role_arn" {
  value = module.svc_responder.responder_role_arn
}
