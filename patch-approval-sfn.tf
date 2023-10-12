resource "aws_cloudwatch_log_group" "patch_approval" {
  count             = var.approval_process_schedule != "" ? 1 : 0
  name              = "/aws/sfn/${var.name}-patch-approval-logs"
  retention_in_days = 90
}

resource "aws_iam_role" "patch_approval" {
  count               = var.approval_process_schedule != "" ? 1 : 0
  name                = "${var.name}-patch-approval-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  path                = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
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
    name = "sfn-access"
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


# State machine
data "template_file" "patch_approval" {
  count    = var.approval_process_schedule != "" ? 1 : 0
  template = file("${path.module}/patch-approval/step-function.json.tpl")
  vars = {
    topic_arn          = aws_sns_topic.patch_approval[0].arn
    function_arn       = "${aws_lambda_function.patch_approval_request[0].arn}:$LATEST"
    function_url       = aws_lambda_function_url.patch_approval_run[0].function_url
    timeout_seconds    = var.approval_process_timeout
    maintenance_window = aws_ssm_maintenance_window.patch_baseline_install[0].id
  }
}

resource "aws_sfn_state_machine" "patch_approval" {
  count    = var.approval_process_schedule != "" ? 1 : 0
  name     = "${var.name}-patch-approval-sfn"
  role_arn = aws_iam_role.patch_approval[0].arn

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.patch_approval[0].arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

  definition = data.template_file.patch_approval[0].rendered
}

# Lambda functions
data "archive_file" "patch_approval_request" {
  count       = var.approval_process_schedule != "" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/patch-approval/patch-approval-request.zip"

  source {
    content  = file("${path.module}/patch-approval/lambda-request/request.py")
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "patch_approval_request" {
  count            = var.approval_process_schedule != "" ? 1 : 0
  filename         = data.archive_file.patch_approval_request[0].output_path
  function_name    = "${var.name}-patch-approval-request"
  role             = aws_iam_role.patch_approval[0].arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128
  publish          = true
  source_code_hash = data.archive_file.patch_approval_request[0].output_base64sha256
}

data "archive_file" "patch_approval_run" {
  count       = var.approval_process_schedule != "" ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/patch-approval/patch-approval-run.zip"

  source {
    content  = file("${path.module}/patch-approval/lambda-run/run.py")
    filename = "lambda_function.py"
  }

  source {
    content  = file("${path.module}/patch-approval/lambda-run/result.html")
    filename = "result.html"
  }
}

resource "aws_lambda_function" "patch_approval_run" {
  count            = var.approval_process_schedule != "" ? 1 : 0
  filename         = data.archive_file.patch_approval_run[0].output_path
  function_name    = "${var.name}-patch-approval-run"
  role             = aws_iam_role.patch_approval[0].arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128
  publish          = true
  source_code_hash = data.archive_file.patch_approval_run[0].output_base64sha256

  environment {
    variables = {
      SFN_ARN = "arn:aws:states:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.name}-patch-approval-sfn"
    }
  }
}

resource "aws_lambda_function_url" "patch_approval_run" {
  count              = var.approval_process_schedule != "" ? 1 : 0
  function_name      = aws_lambda_function.patch_approval_run[0].function_name
  authorization_type = "NONE"
}

resource "aws_sns_topic" "patch_approval" {
  count = var.approval_process_schedule != "" ? 1 : 0
  name  = "${var.name}-patch-approval-requests"
}


resource "aws_scheduler_schedule" "patch_approval" {
  count                        = var.approval_process_schedule != "" ? 1 : 0
  name                         = "${var.name}-patch-approval-schedule"
  schedule_expression_timezone = var.approval_process_timezone

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.approval_process_schedule

  target {
    arn      = aws_sfn_state_machine.patch_approval[0].arn
    role_arn = aws_iam_role.patch_approval[0].arn
  }
}