# Example: Multiple Patching Schedules
# This example demonstrates how to configure multiple patching schedules
# for different maintenance windows (e.g., second and fourth Sundays)

module "patch_manager_multiple_schedules" {
  source = "../../"

  name         = "example-multi-schedule"
  target       = "tag:PatchGroup"
  target_value = ["WebServers", "DatabaseServers"]

  # Multiple scan schedules - runs on different Sundays
  scan_schedules = [
    {
      name            = "second-sunday"
      schedule        = "cron(0 2 ? * SUN#2 *)"  # 2 AM on second Sunday of each month
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    },
    {
      name            = "fourth-sunday"
      schedule        = "cron(0 2 ? * SUN#4 *)"  # 2 AM on fourth Sunday of each month
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    }
  ]

  # Multiple install schedules - runs after scan schedules
  install_schedules = [
    {
      name            = "second-sunday-install"
      schedule        = "cron(0 4 ? * SUN#2 *)"  # 4 AM on second Sunday (2 hours after scan)
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    },
    {
      name            = "fourth-sunday-install"
      schedule        = "cron(0 4 ? * SUN#4 *)"  # 4 AM on fourth Sunday (2 hours after scan)
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    }
  ]

  # Patch configuration
  operating_system = "WINDOWS"
  classification   = ["CriticalUpdates", "SecurityUpdates", "Updates"]
  severity         = ["Critical", "Important", "Moderate"]

  # Notification configuration
  notification_events = ["Success", "Failed", "TimedOut", "Cancelled"]
}

# Output the maintenance window IDs for reference
output "scan_maintenance_windows" {
  description = "Map of scan maintenance window IDs"
  value = {
    for k, v in module.patch_manager_multiple_schedules.scan_maintenance_windows : k => {
      id       = v.id
      name     = v.name
      schedule = v.schedule
    }
  }
}

output "install_maintenance_windows" {
  description = "Map of install maintenance window IDs"
  value = {
    for k, v in module.patch_manager_multiple_schedules.install_maintenance_windows : k => {
      id       = v.id
      name     = v.name
      schedule = v.schedule
    }
  }
}
