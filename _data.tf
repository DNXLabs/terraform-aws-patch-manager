data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  # Merge legacy single maintenance window variables with new list variables for backward compatibility
  scan_windows = concat(
    var.scan_maintenance_windows,
    var.scan_schedule != "" ? [{
      name            = "legacy-scan"
      schedule        = var.scan_schedule
      timezone        = var.scan_timezone
      duration        = var.scan_duration
      cutoff          = var.scan_cutoff
      max_concurrency = var.scan_max_concurrency
      max_errors      = var.scan_max_errors
    }] : []
  )

  install_windows = concat(
    var.install_maintenance_windows,
    var.install_schedule != "" ? [{
      name            = "legacy-install"
      schedule        = var.install_schedule
      timezone        = var.install_timezone
      duration        = var.install_duration
      cutoff          = var.install_cutoff
      max_concurrency = var.install_max_concurrency
      max_errors      = var.install_max_errors
      reboot_option   = var.install_reboot_option
    }] : []
  )
}
