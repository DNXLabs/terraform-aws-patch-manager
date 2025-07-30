# Example: Multiple Maintenance Windows Configuration
# This example shows how to configure multiple maintenance windows for both scan and install operations

module "patch_manager_multiple_windows" {
  source = "../"

  enabled            = true
  name               = "multi-window-patching"
  target_value       = ["production-servers", "staging-servers"]
  session_encryption = true

  # Configure multiple scan maintenance windows
  scan_maintenance_windows = [
    {
      name            = "production-scan"
      schedule        = "cron(0 22 ? * SAT *)" # Every Saturday at 10pm
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "15%"
      max_errors      = "15%"
    },
    {
      name            = "staging-scan"
      schedule        = "cron(0 20 ? * SAT *)" # Every Saturday at 8pm
      timezone        = "Australia/Melbourne"
      duration        = 3
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "25%"
    }
  ]

  # Configure multiple install maintenance windows
  install_maintenance_windows = [
    {
      name            = "production-install"
      schedule        = "cron(0 23 ? * SUN *)" # Every Sunday at 11pm
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "10%"
      max_errors      = "5%"
      reboot_option   = "NoReboot"
    },
    {
      name            = "staging-install"
      schedule        = "cron(0 21 ? * SUN *)" # Every Sunday at 9pm
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "20%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    }
  ]

  # Optional: Configure approval process
  approval_process_schedule = "cron(0 9 ? * TUE *)" # Every Tuesday at 9am
  approval_process_timeout  = 259200 # 3 days

  # Optional: Configure notifications
  notification_events = ["Success", "Failed", "TimedOut", "Cancelled", "InProgress"]
}

# Example: Mixed configuration (using both new and legacy variables)
# This demonstrates backward compatibility
module "patch_manager_mixed" {
  source = "../"

  enabled            = true
  name               = "mixed-patching"
  target_value       = ["legacy-servers"]
  session_encryption = true

  # Legacy single scan window (will be merged with new windows)
  scan_schedule      = "cron(0 23 ? * SAT *)" # Every Saturday at 11pm
  scan_duration      = 5
  scan_max_concurrency = "20%"
  scan_max_errors    = "20%"

  # New multiple install windows
  install_maintenance_windows = [
    {
      name            = "critical-install"
      schedule        = "cron(0 1 ? * SUN *)" # Every Sunday at 1am
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "5%"
      max_errors      = "5%"
      reboot_option   = "NoReboot"
    },
    {
      name            = "standard-install"
      schedule        = "cron(0 3 ? * SUN *)" # Every Sunday at 3am
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    }
  ]
}
