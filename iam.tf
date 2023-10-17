resource "aws_iam_role" "patch_approval_sfn" {
  count = var.approval_process_schedule != "" ? 1 : 0
  name  = "${var.name}-patch-approval-sfn-role"
  path  = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "custom-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:DescribeLogGroups",
            "ssm:PutParameter",
            "ssm:GetParameter",
            "ssm:UpdateMaintenanceWindow",
            "lambda:InvokeFunction",
            "sns:Publish",
            "states:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "patch_approval_scheduler" {
  count = var.approval_process_schedule != "" ? 1 : 0
  name  = "${var.name}-patch-approval-scheduler-role"
  path  = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "custom-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "states:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "patch_approval_lambda" {
  count               = var.approval_process_schedule != "" ? 1 : 0
  name                = "${var.name}-patch-approval-lambda-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  path                = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "custom-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:DescribeLogGroups",
            "ssm:PutParameter",
            "ssm:GetParameter",
            "ssm:UpdateMaintenanceWindow",
            "lambda:InvokeFunction",
            "sns:Publish",
            "states:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}