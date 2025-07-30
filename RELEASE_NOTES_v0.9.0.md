# Release Notes - v0.9.0: Multiple Schedules Support

## 🚀 Major New Feature: Multiple Patching Schedules

This release introduces support for configuring multiple patching schedules per month, enabling more flexible maintenance windows while maintaining full backward compatibility.

## ✨ What's New

### Multiple Schedules Configuration
- **New Variables**: `scan_schedules` and `install_schedules` for defining multiple maintenance windows
- **Flexible Scheduling**: Support for complex patterns like "second and fourth Sundays of each month"
- **Individual Configuration**: Each schedule can have its own timezone, duration, cutoff, concurrency, and error settings

### Enhanced Outputs
- Comprehensive outputs for all maintenance windows, targets, and tasks
- Map-based outputs for better resource management
- Backward-compatible legacy outputs maintained

### Better Resource Management
- Changed from `count` to `for_each` for improved resource handling
- Unique naming for all resources when using multiple schedules
- Dedicated CloudWatch log groups per schedule

## 📋 Usage Examples

### Multiple Schedules (New)
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git?ref=v0.9.0"

  name         = "multi-schedule-patching"
  target_value = ["web-servers", "db-servers"]

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

### Single Schedule (Legacy - Still Supported)
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git?ref=v0.9.0"

  name         = "legacy-patching"
  target_value = ["servers"]

  # Legacy variables still work exactly as before
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

## 🔄 Migration Guide

### No Action Required
Existing configurations will continue to work without any changes. The module maintains full backward compatibility.

### Optional: Migrate to Multiple Schedules
If you want to use the new multiple schedules feature:
1. Replace single schedule variables with `scan_schedules` and `install_schedules` lists
2. Each schedule object can have its own configuration
3. Update outputs to use the new map-based outputs if needed

See `UPGRADE_GUIDE.md` for detailed migration instructions.

## 📁 New Files Added

- `outputs.tf` - Comprehensive outputs for all resources
- `examples/multiple-schedules/main.tf` - Multiple schedules example
- `examples/backward-compatibility/main.tf` - Legacy compatibility example
- `test/main.tf` - Test configuration
- `CHANGELOG.md` - Detailed changelog
- `UPGRADE_GUIDE.md` - Migration guide

## 🔧 Technical Changes

- Resources now use `for_each` instead of `count`
- Added local values for backward compatibility
- Enhanced resource naming with schedule suffixes
- Separate CloudWatch log groups per schedule
- Improved resource organization and management

## 🛡️ Backward Compatibility

- **Zero Breaking Changes**: All existing configurations continue to work
- **Legacy Variables**: All original variables are still supported
- **Legacy Outputs**: Original outputs maintained for compatibility
- **Seamless Upgrade**: No configuration changes required

## 📚 Documentation

- Updated README.md with comprehensive examples
- Added schedule configuration examples with AWS cron expressions
- Detailed upgrade guide with migration strategies
- Complete changelog with technical details

## 🎯 Common Use Cases

- **Second and Fourth Sundays**: `cron(0 2 ? * SUN#2 *)` and `cron(0 2 ? * SUN#4 *)`
- **First and Third Saturdays**: `cron(0 2 ? * SAT#1 *)` and `cron(0 2 ? * SAT#3 *)`
- **Monthly Specific Dates**: `cron(0 2 15 * ? *)` (15th of each month)
- **Quarterly Patching**: `cron(0 2 1 */3 ? *)` (First day of every 3rd month)

## 🔍 Testing

Use the provided test configuration to validate your setup:
```bash
cd test/
terraform init
terraform plan
```

---

**Full Changelog**: [View on GitHub](https://github.com/DNXLabs/terraform-aws-patch-manager/compare/v0.8.0...v0.9.0)
