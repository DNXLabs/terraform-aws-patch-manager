#Maintenance windows
resource "aws_ssm_maintenance_window" "patch_baseline_scan" {
  for_each          = { for idx, schedule in local.scan_schedules_combined : idx => schedule }
  name              = "${var.name}-maintenance-window-scan-${each.value.name}"
  schedule          = each.value.schedule
  schedule_timezone = each.value.timezone
  duration          = each.value.duration
  cutoff            = each.value.cutoff
}

resource "aws_ssm_maintenance_window" "patch_baseline_install" {
  for_each          = { for idx, schedule in local.install_schedules_combined : idx => schedule }
  name              = "${var.name}-maintenance-window-install-${each.value.name}"
  schedule          = each.value.schedule
  schedule_timezone = each.value.timezone
  duration          = each.value.duration
  cutoff            = each.value.cutoff
  enabled           = var.approval_process_schedule != "" ? false : true # keep disabled for approval process

  lifecycle {
    ignore_changes = [enabled]
  }
}

#Maintenance window target via tag
resource "aws_ssm_maintenance_window_target" "patch_baseline_scan" {
  for_each      = { for idx, schedule in local.scan_schedules_combined : idx => schedule }
  window_id     = aws_ssm_maintenance_window.patch_baseline_scan[each.key].id
  name          = "${var.name}-scan-target-${each.value.name}"
  description   = "This is a maintenance window scan target for ${var.name} - ${each.value.name}"
  resource_type = "INSTANCE"

  targets {
    key    = var.target
    values = var.target_value
  }
}

resource "aws_ssm_maintenance_window_target" "patch_baseline_install" {
  for_each      = { for idx, schedule in local.install_schedules_combined : idx => schedule }
  window_id     = aws_ssm_maintenance_window.patch_baseline_install[each.key].id
  name          = "${var.name}-install-target-${each.value.name}"
  description   = "This is a maintenance window install target for ${var.name} - ${each.value.name}"
  resource_type = "INSTANCE"

  targets {
    key    = var.target
    values = var.target_value
  }
}

# Command task (AWS-RunPatchBaseline) associated to the maintenance window
resource "aws_ssm_maintenance_window_task" "patch_baseline_scan" {
  for_each        = { for idx, schedule in local.scan_schedules_combined : idx => schedule }
  name            = "${var.name}-patch-baseline-scan-${each.value.name}"
  max_concurrency = each.value.max_concurrency
  max_errors      = each.value.max_errors
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.patch_baseline_scan[each.key].id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_baseline_scan[each.key].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"
      timeout_seconds  = 600
      service_role_arn = aws_iam_role.maintenance_window_task[0].arn

      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patch_baseline_scan[each.key].name
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
  for_each        = { for idx, schedule in local.install_schedules_combined : idx => schedule }
  name            = "${var.name}-patch-baseline-install-${each.value.name}"
  max_concurrency = each.value.max_concurrency
  max_errors      = each.value.max_errors
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline"
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.patch_baseline_install[each.key].id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_baseline_install[each.key].id]
  }

  task_invocation_parameters {
    run_command_parameters {
      document_version = "$LATEST"
      timeout_seconds  = 600
      service_role_arn = aws_iam_role.maintenance_window_task[0].arn

      cloudwatch_config {
        cloudwatch_output_enabled = true
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patch_baseline_install[each.key].name
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
        values = [each.value.reboot_option]
      }
    }
  }
}
