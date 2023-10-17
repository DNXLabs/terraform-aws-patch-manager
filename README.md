# terraform-aws-patch-manager

[![Lint Status](https://github.com/DNXLabs/terraform-aws-patch-manager/workflows/Lint/badge.svg)](https://github.com/DNXLabs/terraform-aws-patch-manager/actions)
[![LICENSE](https://img.shields.io/github/license/DNXLabs/terraform-aws-patch-manager)](https://github.com/DNXLabs/terraform-aws-patch-manager/blob/master/LICENSE)

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