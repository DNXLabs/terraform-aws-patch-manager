# Test configuration to validate the multiple schedules functionality
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

# Test multiple schedules configuration
module "test_multiple_schedules" {
  source = "../"

  name         = "test-multi-schedule"
  target_value = ["test-servers"]

  # Test multiple scan schedules
  scan_schedules = [
    {
      name            = "second-sunday"
      schedule        = "cron(0 2 ? * SUN#2 *)"
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    },
    {
      name            = "fourth-sunday"
      schedule        = "cron(0 2 ? * SUN#4 *)"
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    }
  ]

  # Test multiple install schedules
  install_schedules = [
    {
      name            = "second-sunday-install"
      schedule        = "cron(0 4 ? * SUN#2 *)"
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    },
    {
      name            = "fourth-sunday-install"
      schedule        = "cron(0 4 ? * SUN#4 *)"
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    }
  ]

  operating_system = "WINDOWS"
  classification   = ["CriticalUpdates", "SecurityUpdates"]
  severity         = ["Critical", "Important"]
}

# Test backward compatibility
module "test_legacy" {
  source = "../"

  name         = "test-legacy"
  target_value = ["legacy-servers"]

  # Legacy single schedule configuration
  scan_schedule        = "cron(0 2 ? * SUN#2 *)"
  scan_timezone        = "Australia/Melbourne"
  scan_duration        = 4
  scan_cutoff          = 1
  scan_max_concurrency = "25%"
  scan_max_errors      = "15%"

  install_schedule        = "cron(0 4 ? * SUN#2 *)"
  install_timezone        = "Australia/Melbourne"
  install_duration        = 6
  install_cutoff          = 2
  install_max_concurrency = "15%"
  install_max_errors      = "10%"
  install_reboot_option   = "RebootIfNeeded"

  operating_system = "WINDOWS"
  classification   = ["CriticalUpdates", "SecurityUpdates"]
  severity         = ["Critical", "Important"]
}

# Outputs to verify functionality
output "multiple_schedules_scan_windows" {
  description = "Multiple schedules scan maintenance windows"
  value       = module.test_multiple_schedules.scan_maintenance_windows
}

output "multiple_schedules_install_windows" {
  description = "Multiple schedules install maintenance windows"
  value       = module.test_multiple_schedules.install_maintenance_windows
}

output "legacy_scan_window_id" {
  description = "Legacy scan maintenance window ID"
  value       = module.test_legacy.scan_maintenance_window_id
}

output "legacy_install_window_id" {
  description = "Legacy install maintenance window ID"
  value       = module.test_legacy.install_maintenance_window_id
}
