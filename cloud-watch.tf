#Cloudwatch log group
resource "aws_cloudwatch_log_group" "patch_baseline_scan" {
  for_each          = { for idx, schedule in local.scan_schedules_combined : idx => schedule }
  name              = "/aws/ssm/${var.name}-patch-baseline-scan-${each.value.name}"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "patch_baseline_install" {
  for_each          = { for idx, schedule in local.install_schedules_combined : idx => schedule }
  name              = "/aws/ssm/${var.name}-patch-baseline-install-${each.value.name}"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_group" "patch_approval" {
  count             = var.approval_process_schedule != "" ? 1 : 0
  name              = "/aws/sfn/${var.name}-patch-approval-logs"
  retention_in_days = 365
}
