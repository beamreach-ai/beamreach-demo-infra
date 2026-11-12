# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "acceptance-report-exporter"
resource "aws_iam_role" "acceptance_report_exporter" {
  assume_role_policy    = "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"lambda.amazonaws.com\"}}],\"Version\":\"2012-10-17\"}"
  description           = "Created by hand for the acceptance run (not in Terraform)"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "acceptance-report-exporter"
  path                  = "/"
  tags = {
    Project = "compass-acceptance"
  }
  tags_all = {
    Project = "compass-acceptance"
  }
}
