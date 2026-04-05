output "finops_demo_inventory" {
  description = "FinOps demo resources created for the demo environment."
  value       = module.finops_demo.inventory
}

output "finops_demo_s3_seed_note" {
  description = "Operational note for populating the S3 inefficiency demo."
  value       = module.finops_demo.s3_seed_note
}
