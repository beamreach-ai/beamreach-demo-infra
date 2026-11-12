# Terraform import blocks (requires Terraform >= 1.5)
# Resource blocks for these imports are in beamreach_imported.tf.
# Once `terraform apply` has completed the import, this file can be deleted;
# keep beamreach_imported.tf.

import {
  to = aws_iam_role.acceptance_report_exporter
  id = "acceptance-report-exporter"
}
