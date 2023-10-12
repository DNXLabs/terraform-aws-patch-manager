#Cloudwatch log group
resource "aws_cloudwatch_log_group" "patch_baseline_scan" {
  count             = var.scan_schedule != "" ? 1 : 0
  name              = "/aws/ssm/${var.name}-patch-baseline-scan"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "patch_baseline_install" {
  count             = var.install_schedule != "" ? 1 : 0
  name              = "/aws/ssm/${var.name}-patch-baseline-install"
  retention_in_days = 30
}