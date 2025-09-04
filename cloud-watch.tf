#Cloudwatch log group for scan operations
resource "aws_cloudwatch_log_group" "patch_baseline_scan" {
  for_each          = { for idx, window in local.scan_windows : idx => window }
  name              = "/aws/ssm/${var.name}-patch-baseline-scan-${each.value.name}"
  retention_in_days = var.log_retention_in_days
}

#Cloudwatch log group for install operations
resource "aws_cloudwatch_log_group" "patch_baseline_install" {
  for_each          = { for idx, window in local.install_windows : idx => window }
  name              = "/aws/ssm/${var.name}-patch-baseline-install-${each.value.name}"
  retention_in_days = var.log_retention_in_days
}

#Cloudwatch log group for patch approval
resource "aws_cloudwatch_log_group" "patch_approval" {
  count             = var.approval_process_schedule != "" ? 1 : 0
  name              = "/aws/sfn/${var.name}-patch-approval-logs"
  retention_in_days = var.log_retention_in_days
}
