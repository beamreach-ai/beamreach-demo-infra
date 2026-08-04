# Roles GitHub Actions assumes to plan and apply this environment.
#
# Two roles rather than one, because plan and apply do not deserve the same
# trust. A plan runs on every pull request, including from branches nobody has
# reviewed; an apply changes live infrastructure and should only ever run from
# main.
#
# The pre-existing `github-radio-user-role` is not reused: it grants ECR push
# for the image build workflows and nothing else, so it could never have applied
# Terraform. The deploy workflow pointed at a role of that name in the *control
# plane* account, which is why every run failed.

locals {
  github_repo = "beamreach-ai/beamreach-demo-infra"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# ── Plan: any branch, read-only ───────────────────────────────────────────────

data "aws_iam_policy_document" "tf_plan_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Any ref in this repository — a plan on a pull request is the point.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "terraform_plan" {
  name               = "beamreach-demo-terraform-plan"
  description        = "Read-only Terraform plan from GitHub Actions"
  assume_role_policy = data.aws_iam_policy_document.tf_plan_assume.json
}

resource "aws_iam_role_policy_attachment" "terraform_plan_readonly" {
  role       = aws_iam_role.terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# A plan still needs to write: it reads and writes the state lock, and stores
# the refreshed state. ReadOnlyAccess alone cannot, so grant exactly that.
data "aws_iam_policy_document" "tf_state_access" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::beamreach-public-demo-tf-states",
      "arn:aws:s3:::beamreach-public-demo-tf-states/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = ["arn:aws:dynamodb:${local.aws_region}:${local.account}:table/public-demo-tf-locks"]
  }

  # AWS's ReadOnlyAccess grants DescribeSecret but deliberately not
  # GetSecretValue, and this configuration holds `aws_secretsmanager_secret_version`
  # resources that a plan must refresh. Without this, plan fails outright.
  #
  # Scoped to the two secrets this environment owns rather than granted broadly:
  # the plan role is assumable from any branch, so anything it can read, an
  # unreviewed pull request can read. That is an acceptable trade for a demo
  # account's own application config and would not be for anything real — an
  # environment holding genuine credentials should pin the plan role's trust to
  # protected branches as well.
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:secretsmanager:${local.aws_region}:${local.account}:secret:public-demo/demo/app-*",
      "arn:aws:secretsmanager:${local.aws_region}:${local.account}:secret:demo/app-config-*",
    ]
  }
}

resource "aws_iam_role_policy" "terraform_plan_state" {
  name   = "terraform-state-access"
  role   = aws_iam_role.terraform_plan.id
  policy = data.aws_iam_policy_document.tf_state_access.json
}

# ── Apply: main only ──────────────────────────────────────────────────────────

data "aws_iam_policy_document" "tf_apply_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Pinned to main. `repo:...:*` — which the existing ECR role uses — would
    # let any branch in the repository assume an apply role, so a pull request
    # could change live infrastructure without review.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "terraform_apply" {
  name               = "beamreach-demo-terraform-apply"
  description        = "Terraform apply from GitHub Actions, main branch only"
  assume_role_policy = data.aws_iam_policy_document.tf_apply_assume.json
}

# This environment manages IAM roles, VPCs, ECS, S3, DynamoDB and Secrets
# Manager, so a meaningfully narrower policy would be a near-copy of the whole
# surface and would break on every new resource type. The narrowing that
# actually matters is on *who can assume it* — main only, plus the required
# reviewer on the GitHub Environment — rather than on what it can do once
# assumed. Revisit if this account ever holds anything but demo material.
resource "aws_iam_role_policy_attachment" "terraform_apply_admin" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "terraform_plan_role_arn" {
  value = aws_iam_role.terraform_plan.arn
}

output "terraform_apply_role_arn" {
  value = aws_iam_role.terraform_apply.arn
}
