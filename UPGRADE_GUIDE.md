# Terraform AWS Patch Manager - Multiple Maintenance Windows Upgrade Guide

## Overview

This upgrade enhances the terraform-aws-patch-manager module to support multiple maintenance windows for both scan and install operations, while maintaining backward compatibility with existing configurations.

## Key Changes

### 1. New Variables

#### Scan Maintenance Windows
- **`scan_maintenance_windows`** - List of scan maintenance window configurations
  ```hcl
  scan_maintenance_windows = [
    {
      name            = "weekend-scan-1"
      schedule        = "cron(0 23 ? * SAT *)"
      timezone        = "Australia/Melbourne"  # optional
      duration        = 5                      # optional
      cutoff          = 1                      # optional
      max_concurrency = "20%"                  # optional
      max_errors      = "20%"                  # optional
    }
  ]
  ```

#### Install Maintenance Windows
- **`install_maintenance_windows`** - List of install maintenance window configurations
  ```hcl
  install_maintenance_windows = [
    {
      name            = "weekend-install-1"
      schedule        = "cron(0 23 ? * SUN *)"
      timezone        = "Australia/Melbourne"  # optional
      duration        = 5                      # optional
      cutoff          = 1                      # optional
      max_concurrency = "10%"                  # optional
      max_errors      = "10%"                  # optional
      reboot_option   = "NoReboot"             # optional
    }
  ]
  ```

### 2. Deprecated Variables (Still Supported)

The following variables are deprecated but still supported for backward compatibility:

**Scan Variables:**
- `scan_schedule`
- `scan_timezone`
- `scan_duration`
- `scan_cutoff`
- `scan_max_concurrency`
- `scan_max_errors`

**Install Variables:**
- `install_schedule`
- `install_timezone`
- `install_duration`
- `install_cutoff`
- `install_max_concurrency`
- `install_max_errors`
- `install_reboot_option`

### 3. Infrastructure Changes

#### Resource Naming
- Maintenance windows now include the window name in their resource names
- Format: `${var.name}-maintenance-window-{scan|install}-${window.name}`
- CloudWatch log groups follow the same pattern

#### Multiple Resources
- Each maintenance window configuration creates separate AWS resources:
  - SSM Maintenance Window
  - SSM Maintenance Window Target
  - SSM Maintenance Window Task
  - CloudWatch Log Group

#### Approval Process Enhancement
- Step Function now handles multiple install maintenance windows
- All install windows are disabled/enabled together during approval process
- Updated to use modern `templatefile` function instead of deprecated `template` provider

### 4. Backward Compatibility

The module maintains full backward compatibility:
- Existing configurations using legacy variables will continue to work
- Legacy variables are automatically merged with new list variables
- No breaking changes to existing deployments

## Migration Examples

### Example 1: Basic Migration

**Before (Legacy):**
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git"
  
  name               = "windows-patching"
  target_value       = ["windows-server"]
  scan_schedule      = "cron(0 23 ? * SAT *)"
  scan_duration      = 5
  install_schedule   = "cron(0 23 ? * SUN *)"
  install_duration   = 5
}
```

**After (Multiple Windows):**
```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git"
  
  name         = "windows-patching"
  target_value = ["windows-server"]
  
  scan_maintenance_windows = [
    {
      name     = "weekend-scan"
      schedule = "cron(0 23 ? * SAT *)"
      duration = 5
    }
  ]
  
  install_maintenance_windows = [
    {
      name     = "weekend-install"
      schedule = "cron(0 23 ? * SUN *)"
      duration = 5
    }
  ]
}
```

### Example 2: Multiple Windows for Different Server Groups

```hcl
module "patch_manager" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git"
  
  name         = "multi-environment-patching"
  target_value = ["production-servers", "staging-servers"]
  
  scan_maintenance_windows = [
    {
      name            = "production-scan"
      schedule        = "cron(0 22 ? * SAT *)"
      duration        = 4
      max_concurrency = "15%"
      max_errors      = "10%"
    },
    {
      name            = "staging-scan"
      schedule        = "cron(0 20 ? * SAT *)"
      duration        = 3
      max_concurrency = "25%"
      max_errors      = "20%"
    }
  ]
  
  install_maintenance_windows = [
    {
      name          = "production-install"
      schedule      = "cron(0 23 ? * SUN *)"
      duration      = 6
      reboot_option = "NoReboot"
    },
    {
      name          = "staging-install"
      schedule      = "cron(0 21 ? * SUN *)"
      duration      = 4
      reboot_option = "RebootIfNeeded"
    }
  ]
}
```

## Technical Implementation Details

### Local Values
- `local.scan_windows` - Merges legacy and new scan window configurations
- `local.install_windows` - Merges legacy and new install window configurations
- `local.install_window_ids` - Collects all install window IDs for approval process

### Resource Iteration
- Uses `for_each` with indexed maps to create multiple resources
- Each maintenance window gets a unique index and configuration

### Step Function Updates
- Updated to handle arrays of maintenance window IDs
- Uses Map state to process multiple windows in parallel
- Enhanced error handling and messaging

## Validation

The module has been validated with:
- Terraform >= 1.5
- AWS Provider >= 4.0.0
- Archive Provider >= 2.0.0

## Breaking Changes

**None** - This is a backward-compatible enhancement.

## Recommendations

1. **New Deployments**: Use the new `scan_maintenance_windows` and `install_maintenance_windows` variables
2. **Existing Deployments**: Can continue using legacy variables or migrate at your convenience
3. **Mixed Usage**: You can use legacy variables for some windows and new variables for others
4. **Naming**: Use descriptive names for maintenance windows to easily identify them in AWS console

## Support

For issues or questions regarding this upgrade, please refer to the module documentation or create an issue in the repository.
