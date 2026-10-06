# Operations responder role (auto-generated; edit the enabled actions
# in the console instead of this file).

resource "aws_iam_role" "responder" {
  name               = "svc-ops-responder"
  path               = "/service/"
  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": [
              "arn:aws:iam::662863386798:role/radio-task-beamreach-demo"
            ]
          },
          "Action": "sts:AssumeRole",
          "Condition": {
            "StringEquals": {
              "sts:ExternalId": "ops-f725cfa958fadf34fab6c2fc"
            }
          }
        }
      ]
    }
  POLICY
}

resource "aws_iam_role_policy" "responder" {
  name   = "ops"
  role   = aws_iam_role.responder.id
  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "StopTasksOfScopedServices",
          "Effect": "Allow",
          "Action": [
            "ecs:StopTask"
          ],
          "Resource": [
            "arn:aws:ecs:us-east-1:682684724085:task/public-demo-replay/*"
          ],
          "Condition": {
            "ArnEquals": {
              "ecs:cluster": [
                "arn:aws:ecs:us-east-1:682684724085:cluster/public-demo-replay"
              ]
            }
          }
        },
        {
          "Sid": "ReadScopedServices",
          "Effect": "Allow",
          "Action": [
            "ecs:DescribeServices"
          ],
          "Resource": [
            "arn:aws:ecs:us-east-1:682684724085:service/public-demo-replay/web"
          ]
        },
        {
          "Sid": "ReadTasksOfScopedClusters",
          "Effect": "Allow",
          "Action": [
            "ecs:DescribeTasks",
            "ecs:ListTasks"
          ],
          "Resource": "*",
          "Condition": {
            "ArnEquals": {
              "ecs:cluster": [
                "arn:aws:ecs:us-east-1:682684724085:cluster/public-demo-replay"
              ]
            }
          }
        },
        {
          "Sid": "ReadTaskDefinitionsAndNetwork",
          "Effect": "Allow",
          "Action": [
            "ecs:DescribeTaskDefinition",
            "ec2:DescribeNetworkInterfaces"
          ],
          "Resource": "*"
        },
        {
          "Sid": "DeactivateScopedKeys",
          "Effect": "Allow",
          "Action": [
            "iam:UpdateAccessKey",
            "iam:ListAccessKeys"
          ],
          "Resource": [
            "arn:aws:iam::682684724085:user/service/*"
          ]
        }
      ]
    }
  POLICY
}

output "responder_role_arn" {
  value = aws_iam_role.responder.arn
}
