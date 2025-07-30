# Outputs for scan maintenance windows
output "scan_maintenance_windows" {
  description = "Map of scan maintenance windows with their details"
  value = {
    for k, v in aws_ssm_maintenance_window.patch_baseline_scan : k => {
      id                = v.id
      name              = v.name
      schedule          = v.schedule
      schedule_timezone = v.schedule_timezone
      duration          = v.duration
      cutoff            = v.cutoff
      enabled           = v.enabled
    }
  }
}

# Outputs for install maintenance windows
output "install_maintenance_windows" {
  description = "Map of install maintenance windows with their details"
  value = {
    for k, v in aws_ssm_maintenance_window.patch_baseline_install : k => {
      id                = v.id
      name              = v.name
      schedule          = v.schedule
      schedule_timezone = v.schedule_timezone
      duration          = v.duration
      cutoff            = v.cutoff
      enabled           = v.enabled
    }
  }
}

# Outputs for scan maintenance window targets
output "scan_maintenance_window_targets" {
  description = "Map of scan maintenance window targets"
  value = {
    for k, v in aws_ssm_maintenance_window_target.patch_baseline_scan : k => {
      id          = v.id
      name        = v.name
      description = v.description
      window_id   = v.window_id
    }
  }
}

# Outputs for install maintenance window targets
output "install_maintenance_window_targets" {
  description = "Map of install maintenance window targets"
  value = {
    for k, v in aws_ssm_maintenance_window_target.patch_baseline_install : k => {
      id          = v.id
      name        = v.name
      description = v.description
      window_id   = v.window_id
    }
  }
}

# Outputs for scan maintenance window tasks
output "scan_maintenance_window_tasks" {
  description = "Map of scan maintenance window tasks"
  value = {
    for k, v in aws_ssm_maintenance_window_task.patch_baseline_scan : k => {
      id              = v.id
      name            = v.name
      window_id       = v.window_id
      max_concurrency = v.max_concurrency
      max_errors      = v.max_errors
    }
  }
}

# Outputs for install maintenance window tasks
output "install_maintenance_window_tasks" {
  description = "Map of install maintenance window tasks"
  value = {
    for k, v in aws_ssm_maintenance_window_task.patch_baseline_install : k => {
      id              = v.id
      name            = v.name
      window_id       = v.window_id
      max_concurrency = v.max_concurrency
      max_errors      = v.max_errors
    }
  }
}

# CloudWatch log groups
output "scan_log_groups" {
  description = "Map of scan CloudWatch log groups"
  value = {
    for k, v in aws_cloudwatch_log_group.patch_baseline_scan : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

output "install_log_groups" {
  description = "Map of install CloudWatch log groups"
  value = {
    for k, v in aws_cloudwatch_log_group.patch_baseline_install : k => {
      name = v.name
      arn  = v.arn
    }
  }
}

# Legacy outputs for backward compatibility (when using single schedules)
output "scan_maintenance_window_id" {
  description = "ID of the scan maintenance window (legacy - for backward compatibility)"
  value       = length(local.scan_schedules_combined) > 0 ? values(aws_ssm_maintenance_window.patch_baseline_scan)[0].id : null
}

output "install_maintenance_window_id" {
  description = "ID of the install maintenance window (legacy - for backward compatibility)"
  value       = length(local.install_schedules_combined) > 0 ? values(aws_ssm_maintenance_window.patch_baseline_install)[0].id : null
}
