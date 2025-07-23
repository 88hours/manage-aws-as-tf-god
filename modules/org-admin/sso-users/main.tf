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
data "aws_ssoadmin_instances" "this" {}

resource "aws_identitystore_group" "dev_group" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  display_name      = "Developers"
}

resource "aws_identitystore_group_membership" "dev_group" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  group_id          = aws_identitystore_group.dev_group.group_id

  for_each = {
    for user in var.dev_users : user.user_name => user
  }

  member_id = aws_identitystore_user.sso_users[each.key].user_id
}

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


resource "aws_ssoadmin_permission_set" "dev_access" {
  name             = var.permission_set_name
  description      = var.permission_set_description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = "PT4H"
}

resource "aws_ssoadmin_managed_policy_attachment" "dev_policy" {
  for_each = toset(local.policies)

  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.dev_access.arn
  managed_policy_arn = each.key
}

resource "aws_ssoadmin_account_assignment" "assign_devs" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.dev_access.arn
  principal_id       = aws_identitystore_group.dev_group.group_id
  principal_type     = "GROUP"
  target_id          = var.target_account_id
  target_type        = "AWS_ACCOUNT"

}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  
}


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
        Effect = "Allow",
        Action = [
          "iam:DetachRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:TagRole","iam:ListPolicyVersions",
          "iam:ListInstanceProfilesForRole","iam:DeleteRole", "iam:RemoveRoleFromInstanceProfile"
        ],
        Resource = [
          #"arn:aws:iam::${var.target_account_id}:role/eks-cluster-*",
          #"arn:aws:iam::${var.target_account_id}:role/default-eks-node-group-*"
          "arn:aws:iam::${var.target_account_id}:role/*"
        ]
      },
    {
      Effect   = "Allow",
      Action   = ["iam:CreatePolicy",
                  "iam:DeletePolicy",
                  "iam:ListPolicies",
                  "iam:GetPolicy",
                  "iam:GetPolicyVersion",
                  "iam:ListAttachedRolePolicies",
                  "iam:ListRolePolicies",
                  "iam:GetRolePolicy",
                  "iam:ListRoles", "iam:ListPolicyVersions","iam:RemoveRoleFromInstanceProfile"],
      Resource = [
        #"arn:aws:iam::684273075367:policy/eks*"
        "arn:aws:iam::${var.target_account_id}:policy/*"
        ]
    },{
      "Sid": "EKSCore",
      "Effect": "Allow",
      "Action": [
        "eks:*"
      ],
      "Resource": "*"
    },
    {
  "Sid": "IAMForEKSAndOIDC",
  "Effect": "Allow",
  "Action": [
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
  "Resource": "*"
},
{
  "Sid": "OIDCTaggingPermission",
  "Effect": "Allow",
  "Action": [
    "iam:TagOpenIDConnectProvider"
  ],
  "Resource": "arn:aws:iam::${var.target_account_id}:oidc-provider/*"
},
    {
      "Sid": "EC2ForWorkerNodes",
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "ec2messages:*",
        "ssm:*",
        "ssmmessages:*",
        "ecr:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchAndLogging",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*",
        "events:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VPCNetworking",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:CreateTags",
        "ec2:DeleteSecurityGroup"
      ],
      "Resource": "*"
    }
  ]
  })
}



resource "aws_iam_policy" "allow_passrole_ecs_task_execution_role_for_admin" {
  name        = "AllowPassRoleEcsTaskExecutionRoleForAdmin"
  description = "Allow iam:PassRole on ecsTaskExecutionRole for admin user"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["iam:PassRole"],
      Resource = "arn:aws:iam::${var.target_account_id}:role/ecsTaskExecutionRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "attach_passrole_admin" {
  name       = "attach-passrole-to-admin"
  policy_arn = aws_iam_policy.allow_passrole_ecs_task_execution_role_for_admin.arn
  users      = ["88HoursOrgAdmin"] # admin user name here
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachments" {
  for_each = toset(local.eks_node_policies)

  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = each.value
}