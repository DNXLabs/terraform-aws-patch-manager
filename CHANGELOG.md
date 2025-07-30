# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.0] - 2025-01-30

### Added
- **Multiple Schedules Support**: Added support for configuring multiple patching schedules per month
  - New `scan_schedules` variable to define multiple scan maintenance windows
  - New `install_schedules` variable to define multiple install maintenance windows
  - Each schedule can have its own configuration (timezone, duration, cutoff, concurrency, etc.)
  - Support for complex scheduling patterns (e.g., second and fourth Sundays of each month)

### Enhanced
- **Outputs**: Added comprehensive outputs for all maintenance windows, targets, and tasks
  - `scan_maintenance_windows` - Map of all scan maintenance windows
  - `install_maintenance_windows` - Map of all install maintenance windows
  - `scan_maintenance_window_targets` - Map of all scan targets
  - `install_maintenance_window_targets` - Map of all install targets
  - `scan_maintenance_window_tasks` - Map of all scan tasks
  - `install_maintenance_window_tasks` - Map of all install tasks
  - `scan_log_groups` - Map of scan CloudWatch log groups
  - `install_log_groups` - Map of install CloudWatch log groups

### Backward Compatibility
- **Full Backward Compatibility**: All existing single schedule configurations continue to work
  - Legacy variables (`scan_schedule`, `install_schedule`, etc.) are still supported
  - Legacy outputs (`scan_maintenance_window_id`, `install_maintenance_window_id`) maintained
  - Existing Terraform configurations require no changes

### Examples
- Added `examples/multiple-schedules/` - Demonstrates new multiple schedules feature
- Added `examples/backward-compatibility/` - Shows legacy configuration still works

### Documentation
- Updated README.md with comprehensive usage examples
- Added migration guide from single to multiple schedules
- Added schedule configuration examples with AWS cron expressions

### Technical Details
- Resources now use `for_each` instead of `count` for better resource management
- Added local values for backward compatibility merging
- Unique naming for all resources when using multiple schedules
- CloudWatch log groups created per schedule for better log organization

## [0.8.0] - Previous Release
- Previous functionality (single schedule support)
