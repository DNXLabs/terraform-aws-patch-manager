# terraform-aws-patch-manager

[![Lint Status](https://github.com/DNXLabs/terraform-aws-patch-manager/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-patch-manager/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-patch-manager)](https://github.com/DNXLabs/terraform-aws-patch-manager/blob/master/LICENSE)

This terraform module set up Systems Manager Patch Manager in AWS.

The following resources will be created:
- CloudWatch Log Groups
- IAM roles
- Document for Session Manager configuration
- Fleet Manager configuration
- Patch Baseline
- Inventory configuration
- Patch Manager configuration

In addition you have the option to create or not :
 - Patch Manager Install approval
     - Step Function
     - Event Bridge scheduler
     - SNS Topic
     - Lambda function

## Usage

### Single Schedule (Legacy - Still Supported)

```hcl
module "patch_manager" {
  source               = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git?ref=0.8.0"

  enabled            = true
  name               = "windows-patching"
  target_value       = ["windows-server"]
  session_encryption = true
  scan_schedule      = "cron(0 23 ? * SAT *)" # Every Saturday at 11pm
  scan_duration      = 5

  install_schedule = "cron(0 23 ? * SUN *)" # Every Sunday at 11pm
  install_duration = 5

  approval_process_schedule = "cron(0 8 ? * TUE *)" # Every Tuesday at 8am
  approval_process_timeout  = 345600 # 4 days
}
```

### Multiple Schedules (New Feature)

```hcl
module "patch_manager_multiple" {
  source = "git::https://github.com/DNXLabs/terraform-aws-patch-manager.git?ref=0.9.0"

  enabled      = true
  name         = "multi-schedule-patching"
  target_value = ["web-servers", "db-servers"]

  # Multiple scan schedules - second and fourth Sundays
  scan_schedules = [
    {
      name            = "second-sunday"
      schedule        = "cron(0 2 ? * SUN#2 *)"  # 2 AM on second Sunday
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    },
    {
      name            = "fourth-sunday"
      schedule        = "cron(0 2 ? * SUN#4 *)"  # 2 AM on fourth Sunday
      timezone        = "Australia/Melbourne"
      duration        = 4
      cutoff          = 1
      max_concurrency = "25%"
      max_errors      = "15%"
    }
  ]

  # Multiple install schedules
  install_schedules = [
    {
      name            = "second-sunday-install"
      schedule        = "cron(0 4 ? * SUN#2 *)"  # 4 AM on second Sunday
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    },
    {
      name            = "fourth-sunday-install"
      schedule        = "cron(0 4 ? * SUN#4 *)"  # 4 AM on fourth Sunday
      timezone        = "Australia/Melbourne"
      duration        = 6
      cutoff          = 2
      max_concurrency = "15%"
      max_errors      = "10%"
      reboot_option   = "RebootIfNeeded"
    }
  ]

  operating_system = "WINDOWS"
  classification   = ["CriticalUpdates", "SecurityUpdates", "Updates"]
  severity         = ["Critical", "Important", "Moderate"]
}
```

### Schedule Configuration Examples

The module supports AWS cron expressions for flexible scheduling:

- **Second Sunday of each month**: `cron(0 2 ? * SUN#2 *)`
- **Fourth Sunday of each month**: `cron(0 2 ? * SUN#4 *)`
- **First and third Saturdays**: Use two separate schedule objects
- **Monthly on specific date**: `cron(0 2 15 * ? *)` (15th of each month)
- **Quarterly**: `cron(0 2 1 */3 ? *)` (First day of every 3rd month)

### Migration from Single to Multiple Schedules

Existing configurations using single schedule variables (`scan_schedule`, `install_schedule`, etc.) will continue to work without changes. The module maintains full backward compatibility.

To migrate to multiple schedules:
1. Replace single schedule variables with `scan_schedules` and `install_schedules` lists
2. Each schedule object can have its own configuration (timezone, duration, etc.)
3. Update outputs to use the new map-based outputs if needed

<!--- BEGIN_TF_DOCS --->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| archive | >= 2.0.0 |
| aws | >= 4.0.0 |
| template | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| archive | >= 2.0.0 |
| aws | >= 4.0.0 |
| template | >= 2.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| approval\_process\_schedule | The schedule for the approval process | `string` | `""` | no |
| approval\_process\_timeout | The timeout in seconds for the approval process | `number` | `86400` | no |
| approval\_process\_timezone | The schedule timezone for the approval process | `string` | `"Australia/Melbourne"` | no |
| approved\_patches | The list of approved patches | `list(string)` | `[]` | no |
| classification | The list of patch classifications | `list(string)` | <pre>[<br>  "CriticalUpdates",<br>  "SecurityUpdates"<br>]</pre> | no |
| enabled | Enable or disable the module | `bool` | `true` | no |
| install\_cutoff | The cutoff for the patch baseline scan | `number` | `1` | no |
| install\_duration | The duration for the patch baseline scan | `number` | `5` | no |
| install\_max\_concurrency | The max concurrency for the patch baseline scan | `string` | `"10%"` | no |
| install\_max\_errors | The max errors for the patch baseline scan | `string` | `"10%"` | no |
| install\_reboot\_option | The reboot option for the patch baseline scan | `string` | `"NoReboot"` | no |
| install\_schedule | The schedule for the patch baseline scan | `string` | `""` | no |
| install\_timezone | The schedule timezone for the patch baseline scan | `string` | `"Australia/Melbourne"` | no |
| name | The name of the patch baseline | `string` | n/a | yes |
| notification\_arn | The SNS topic ARN for notifications | `string` | `""` | no |
| notification\_events | The list of notification events | `list(string)` | `[]` | no |
| operating\_system | The operating system for the patch baseline | `string` | `"WINDOWS"` | no |
| rejected\_patches | The list of rejected patches | `list(string)` | `[]` | no |
| scan\_cutoff | The cutoff for the patch baseline scan | `number` | `1` | no |
| scan\_duration | The duration for the patch baseline scan | `number` | `5` | no |
| scan\_max\_concurrency | The max concurrency for the patch baseline scan | `string` | `"20%"` | no |
| scan\_max\_errors | The max errors for the patch baseline scan | `string` | `"20%"` | no |
| scan\_schedule | The schedule for the patch baseline scan | `string` | `""` | no |
| scan\_timezone | The schedule timezone for the patch baseline scan | `string` | `"Australia/Melbourne"` | no |
| session\_encryption | Enable or disable session encryption | `bool` | `true` | no |
| severity | The list of patch severities | `list(string)` | <pre>[<br>  "Critical",<br>  "Important"<br>]</pre> | no |
| target | The target for the patch baseline | `string` | `"tag:PatchGroup"` | no |
| target\_value | The target value for the patch baseline | `list(string)` | `[]` | no |

## Outputs

No output.

<!--- END_TF_DOCS --->

## Authors

Module managed by [DNX Solutions](https://github.com/DNXLabs).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/DNXLabs/terraform-aws-template/blob/master/LICENSE) for full details.
