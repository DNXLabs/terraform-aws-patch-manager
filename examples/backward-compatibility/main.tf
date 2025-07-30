# Example: Backward Compatibility
# This example demonstrates that existing single schedule configurations
# continue to work without any changes

module "patch_manager_legacy" {
  source = "../../"

  name         = "example-legacy"
  target       = "tag:PatchGroup"
  target_value = ["LegacyServers"]

  # Legacy single schedule variables (still supported)
  scan_schedule        = "cron(0 2 ? * SUN#2 *)"  # 2 AM on second Sunday
  scan_timezone        = "Australia/Melbourne"
  scan_duration        = 4
  scan_cutoff          = 1
  scan_max_concurrency = "25%"
  scan_max_errors      = "15%"

  install_schedule        = "cron(0 4 ? * SUN#2 *)"  # 4 AM on second Sunday
  install_timezone        = "Australia/Melbourne"
  install_duration        = 6
  install_cutoff          = 2
  install_max_concurrency = "15%"
  install_max_errors      = "10%"
  install_reboot_option   = "RebootIfNeeded"

  # Patch configuration
  operating_system = "WINDOWS"
  classification   = ["CriticalUpdates", "SecurityUpdates"]
  severity         = ["Critical", "Important"]

  # Notification configuration
  notification_events = ["Success", "Failed"]
}

# These outputs will work exactly as before
output "legacy_scan_window_id" {
  description = "Legacy scan maintenance window ID"
  value       = module.patch_manager_legacy.scan_maintenance_window_id
}

output "legacy_install_window_id" {
  description = "Legacy install maintenance window ID"
  value       = module.patch_manager_legacy.install_maintenance_window_id
}
