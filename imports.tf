# Terraform import blocks (requires Terraform >= 1.5)
# After merging this PR, run: terraform plan -generate-config-out=generated.tf

import {
  to = module.environments.module.demo.aws_dynamodb_stream.public_demo_map_events
  id = "arn:aws:dynamodb:us-east-1:682684724085:table/public-demo-map-events/stream/2025-12-23T22:50:25.152"
}

import {
  to = module.environments.module.demo.aws_dynamodb_table.public_demo_tf_locks
  id = "arn:aws:dynamodb:us-east-1:682684724085:table/public-demo-tf-locks"
}

import {
  to = module.environments.module.demo.aws_iam_role.mapperrole
  id = "arn:aws:iam::682684724085:role/MapperRole"
}

import {
  to = module.environments.module.demo.aws_iam_role.organizationaccountaccessrole
  id = "arn:aws:iam::682684724085:role/OrganizationAccountAccessRole"
}

import {
  to = module.environments.module.demo.aws_iam_role.awsserviceroleforecs
  id = "arn:aws:iam::682684724085:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
}

import {
  to = module.environments.module.demo.aws_iam_role.awsserviceroleforelasticloadbalancing
  id = "arn:aws:iam::682684724085:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
}

import {
  to = module.environments.module.demo.aws_iam_role.awsservicerolefororganizations
  id = "arn:aws:iam::682684724085:role/aws-service-role/organizations.amazonaws.com/AWSServiceRoleForOrganizations"
}

import {
  to = module.environments.module.demo.aws_iam_role.awsserviceroleforsupport
  id = "arn:aws:iam::682684724085:role/aws-service-role/support.amazonaws.com/AWSServiceRoleForSupport"
}

import {
  to = module.environments.module.demo.aws_iam_role.awsservicerolefortrustedadvisor
  id = "arn:aws:iam::682684724085:role/aws-service-role/trustedadvisor.amazonaws.com/AWSServiceRoleForTrustedAdvisor"
}

import {
  to = module.environments.module.demo.aws_iam_role.mcp_aws_read_beamreach_demo
  id = "arn:aws:iam::682684724085:role/mcp-aws-read-beamreach-demo"
}

import {
  to = module.environments.module.demo.aws_iam_role.mcp_aws_write_beamreach_demo
  id = "arn:aws:iam::682684724085:role/mcp-aws-write-beamreach-demo"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.aws_lambda_public_demo_map_publisher
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/aws/lambda/public-demo-map-publisher:*"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.aws_lambda_public_demo_map_stream_consumer
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/aws/lambda/public-demo-map-stream-consumer:*"
}

import {
  to = module.environments.module.demo.aws_cloudwatch_log_group.ecs_public_demo_demo
  id = "arn:aws:logs:us-east-1:682684724085:log-group:/ecs/public-demo-demo:*"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_01188bd96787615d8
  id = "eni-01188bd96787615d8"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_01b7c98a54285aa49
  id = "eni-01b7c98a54285aa49"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_02165ad2a44f3d6c2
  id = "eni-02165ad2a44f3d6c2"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_067e370b81022b197
  id = "eni-067e370b81022b197"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_097a1804d33df3f3a
  id = "eni-097a1804d33df3f3a"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_0a66fbb4f629a8d6f
  id = "eni-0a66fbb4f629a8d6f"
}

import {
  to = module.environments.module.demo.aws_ec2_network_interface.eni_0fde66dde4682f3b8
  id = "eni-0fde66dde4682f3b8"
}

import {
  to = module.environments.module.demo.aws_security_group.default
  id = "sg-01baf76b9559278e2"
}

import {
  to = module.environments.module.demo.aws_security_group.demo_map_alb_sg
  id = "sg-01d5324103b5990f8"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_finops_idle_alb
  id = "sg-0472e74ec4e695698"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_rdp_public_demo
  id = "sg-05ad3f1c2828feddf"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_ssh_public_demo
  id = "sg-088ea337212bde08e"
}

import {
  to = module.environments.module.demo.aws_security_group.prowler_open_all_public_demo
  id = "sg-0addb073d402399d1"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_demo_alb
  id = "sg-0b76178d978eabd39"
}

import {
  to = module.environments.module.demo.aws_security_group.demo_map_ecs_sg
  id = "sg-0d3904c0516eed8fe"
}

import {
  to = module.environments.module.demo.aws_security_group.public_demo_demo_tasks
  id = "sg-0ee4127458f5295a0"
}
