# Upgrade Guide: Multiple Schedules Support

This guide explains the changes made to support multiple patching schedules and how to upgrade your existing configurations.

## What's New

### Multiple Schedules Support
The module now supports configuring multiple patching schedules per month, allowing for more flexible maintenance windows such as:
- Second and fourth Sundays of each month
- Different schedules for different server groups
- Varying configurations per schedule (timezone, duration, concurrency, etc.)

### New Variables

#### `scan_schedules` (list of objects)
Replaces the single `scan_schedule` with support for multiple schedules:

```hcl
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
```

#### `install_schedules` (list of objects)
Replaces the single `install_schedule` with support for multiple schedules:

```hcl
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
  }
]
```

### New Outputs

The module now provides comprehensive outputs for all maintenance windows:

- `scan_maintenance_windows` - Map of all scan maintenance windows
- `install_maintenance_windows` - Map of all install maintenance windows
- `scan_maintenance_window_targets` - Map of all scan targets
- `install_maintenance_window_targets` - Map of all install targets
- `scan_maintenance_window_tasks` - Map of all scan tasks
- `install_maintenance_window_tasks` - Map of all install tasks
- `scan_log_groups` - Map of scan CloudWatch log groups
- `install_log_groups` - Map of install CloudWatch log groups

## Backward Compatibility

### No Breaking Changes
All existing configurations will continue to work without any modifications. The legacy variables are still supported:

- `scan_schedule`
- `scan_timezone`
- `scan_duration`
- `scan_cutoff`
- `scan_max_concurrency`
- `scan_max_errors`
- `install_schedule`
- `install_timezone`
- `install_duration`
- `install_cutoff`
- `install_max_concurrency`
- `install_max_errors`
- `install_reboot_option`

### Legacy Outputs Maintained
The following outputs are still available for backward compatibility:
- `scan_maintenance_window_id`
- `install_maintenance_window_id`

## Migration Strategies

### Option 1: Keep Existing Configuration (Recommended for Stability)
No changes required. Your existing configuration will continue to work exactly as before.

### Option 2: Migrate to Multiple Schedules

#### Before (Single Schedule):
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git"

  name         = "windows-patching"
  target_value = ["windows-server"]

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
}
```

#### After (Multiple Schedules):
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git"

  name         = "windows-patching"
  target_value = ["windows-server"]

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
}
```

## Common Use Cases

### 1. Second and Fourth Sundays
```hcl
scan_schedules = [
  {
    name     = "second-sunday"
    schedule = "cron(0 2 ? * SUN#2 *)"
  },
  {
    name     = "fourth-sunday"
    schedule = "cron(0 2 ? * SUN#4 *)"
  }
]
```

### 2. First and Third Saturdays
```hcl
scan_schedules = [
  {
    name     = "first-saturday"
    schedule = "cron(0 2 ? * SAT#1 *)"
  },
  {
    name     = "third-saturday"
    schedule = "cron(0 2 ? * SAT#3 *)"
  }
]
```

### 3. Monthly on Specific Dates
```hcl
scan_schedules = [
  {
    name     = "mid-month"
    schedule = "cron(0 2 15 * ? *)"  # 15th of each month
  },
  {
    name     = "end-month"
    schedule = "cron(0 2 L * ? *)"   # Last day of each month
  }
]
```

### 4. Quarterly Patching
```hcl
scan_schedules = [
  {
    name     = "quarterly"
    schedule = "cron(0 2 1 */3 ? *)"  # First day of every 3rd month
  }
]
```

## Testing Your Configuration

Use the provided test configuration in `test/main.tf` to validate your setup:

```bash
cd test/
terraform init
terraform plan
```

## Troubleshooting

### Resource Naming
With multiple schedules, resources are now named with the schedule name suffix:
- `${var.name}-maintenance-window-scan-${schedule.name}`
- `${var.name}-maintenance-window-install-${schedule.name}`

### CloudWatch Log Groups
Each schedule gets its own log group:
- `/aws/ssm/${var.name}-patch-baseline-scan-${schedule.name}`
- `/aws/ssm/${var.name}-patch-baseline-install-${schedule.name}`

### State Migration
When migrating from single to multiple schedules, Terraform will detect the resource changes. Plan the migration carefully and consider using `terraform state mv` if needed to avoid resource recreation.

## Support

For questions or issues related to this upgrade:
1. Check the examples in `examples/` directory
2. Review the test configuration in `test/main.tf`
3. Refer to the updated README.md for comprehensive documentation
