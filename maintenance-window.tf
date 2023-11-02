#Maintenance windows
resource "aws_ssm_maintenance_window" "patch_baseline_scan" {
  count             = var.scan_schedule != "" ? 1 : 0
  name              = "${var.name}-maintenance-window-scan"
  schedule          = var.scan_schedule
  schedule_timezone = var.scan_timezone
  duration          = var.scan_duration
  cutoff            = var.scan_cutoff
}

resource "aws_ssm_maintenance_window" "patch_baseline_install" {
  count             = var.install_schedule != "" ? 1 : 0
  name              = "${var.name}-maintenance-window-install"
  schedule          = var.install_schedule
  schedule_timezone = var.install_timezone
  duration          = var.install_duration
  cutoff            = var.install_cutoff
  enabled           = var.approval_process_schedule != "" ? false : true # keep disabled for approval process

  lifecycle {
    ignore_changes = [enabled]
  }
}

#Maintenance window target via tag
resource "aws_ssm_maintenance_window_target" "patch_baseline_scan" {
  count         = var.scan_schedule != "" ? 1 : 0
  window_id     = aws_ssm_maintenance_window.patch_baseline_scan[0].id
  name          = "${var.name}-scan-target"
  description   = "This is a maintenance window scan target for ${var.name}"
  resource_type = "INSTANCE"

  targets {
    key    = var.target
    values = var.target_value
  }
}

resource "aws_ssm_maintenance_window_target" "patch_baseline_install" {
  count         = var.install_schedule != "" ? 1 : 0
  window_id     = aws_ssm_maintenance_window.patch_baseline_install[0].id
  name          = "${var.name}-install-target"
  description   = "This is a maintenance window install target for ${var.name}"
  resource_type = "INSTANCE"

  targets {
    key    = var.target
    values = var.target_value
  }
}

# Command task (AWS-RunPatchBaseline) associated to the maintenance window
resource "aws_ssm_maintenance_window_task" "patch_baseline_scan" {
  count           = var.scan_schedule != "" ? 1 : 0
  name            = "${var.name}-patch-baseline-scan"
  max_concurrency = var.scan_max_concurrency
  max_errors      = var.scan_max_errors
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.patch_baseline_scan[0].id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_baseline_scan[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"
      timeout_seconds  = 600
      service_role_arn = aws_iam_role.maintenance_window_task[0].arn

      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patch_baseline_scan[0].name
      }

      dynamic "notification_config" {
        for_each = length(var.notification_events) > 0 ? [1] : []
        content {
          notification_arn    = var.notification_arn != "" ? var.notification_arn : aws_sns_topic.window_task_notification[0].arn
          notification_events = var.notification_events
          notification_type   = "Command"
        }
      }

      parameter {
        name   = "Operation"
        values = ["Scan"]
      }
    }
  }
}

resource "aws_ssm_maintenance_window_task" "patch_baseline_install" {
  count           = var.install_schedule != "" ? 1 : 0
  name            = "${var.name}-patch-baseline-install"
  max_concurrency = var.install_max_concurrency
  max_errors      = var.install_max_errors
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.patch_baseline_install[0].id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_baseline_install[0].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"
      timeout_seconds  = 600
      service_role_arn = aws_iam_role.maintenance_window_task[0].arn

      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patch_baseline_install[0].name
      }

      dynamic "notification_config" {
        for_each = length(var.notification_events) > 0 ? [1] : []
        content {
          notification_arn    = var.notification_arn != "" ? var.notification_arn : aws_sns_topic.window_task_notification[0].arn
          notification_events = var.notification_events
          notification_type   = "Command"
        }
      }

      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = [var.install_reboot_option]
      }
    }
  }
}