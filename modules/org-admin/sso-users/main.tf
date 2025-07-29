
data "aws_ssoadmin_instances" "this" {}

locals {
  policies = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  ]
}

locals {
  eks_node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
}

# Developer Group
resource "aws_identitystore_group" "dev_group" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  display_name      = var.dev_group_name
}

# Developer Users
resource "aws_identitystore_user" "sso_users" {
  for_each = { for user in var.dev_users : user.user_name => user }

  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = each.value.user_name
  display_name      = each.value.display_name

  name {
    given_name  = each.value.display_name
    family_name = each.value.display_name
    formatted   = each.value.display_name
  }

  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }
}

# Add Users to Developer Group
resource "aws_identitystore_group_membership" "dev_group" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  group_id          = aws_identitystore_group.dev_group.group_id

  for_each = {
    for user in var.dev_users : user.user_name => user
  }

  member_id = aws_identitystore_user.sso_users[each.key].user_id
}

# Permission Set for Developers
resource "aws_ssoadmin_permission_set" "dev_access" {
  name             = var.permission_set_name
  description      = var.permission_set_description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT4H"
}

# Attach AWS Managed Policies
resource "aws_ssoadmin_managed_policy_attachment" "dev_policy" {
  for_each = toset(local.policies)

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.dev_access.arn
  managed_policy_arn = each.key
}

# Assign Developers Group to Target Account
resource "aws_ssoadmin_account_assignment" "assign_devs" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.dev_access.arn
  principal_id       = aws_identitystore_group.dev_group.group_id
  principal_type     = "GROUP"
  target_id          = var.target_account_id
  target_type        = "AWS_ACCOUNT"
}

# Inline Policy for Extra Permissions
resource "aws_ssoadmin_permission_set_inline_policy" "combined_inline_policy" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.dev_access.arn

  inline_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["iam:PassRole"],
        Resource = "arn:aws:iam::${var.target_account_id}:role/ecsTaskExecutionRole"
      },
      {
        Effect   = "Allow",
        Action   = ["iam:*"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "iam:DetachRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:TagRole",
          "iam:ListPolicyVersions",
          "iam:ListInstanceProfilesForRole",
          "iam:DeleteRole",
          "iam:RemoveRoleFromInstanceProfile"
        ],
        Resource = ["arn:aws:iam::${var.target_account_id}:role/*"]
      },
      {
        Sid      = "EKSCore",
        Effect   = "Allow",
        Action   = ["eks:*"],
        Resource = "*"
      },
      {
        Sid      = "IAMForEKSAndOIDC",
        Effect   = "Allow",
        Action   = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ],
        Resource = "*"
      },
      {
        Sid      = "EC2ForWorkerNodes",
        Effect   = "Allow",
        Action   = [
          "ec2:*",
          "autoscaling:*",
          "elasticloadbalancing:*",
          "ec2messages:*",
          "ssm:*",
          "ssmmessages:*",
          "ecr:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
