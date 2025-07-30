variable "enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the module"
}

variable "name" {
  type        = string
  description = "The name of the patch baseline"
}

variable "target" {
  type        = string
  default     = "tag:PatchGroup"
  description = "The target for the patch baseline"
}

variable "target_value" {
  type        = list(string)
  default     = []
  description = "The target value for the patch baseline"
}

variable "session_encryption" {
  type        = bool
  default     = true
  description = "Enable or disable session encryption"
}

variable "approved_patches" {
  type        = list(string)
  default     = []
  description = "The list of approved patches"
}

variable "rejected_patches" {
  type        = list(string)
  default     = []
  description = "The list of rejected patches"
}

variable "operating_system" {
  type        = string
  default     = "WINDOWS"
  description = "The operating system for the patch baseline"
}

variable "classification" {
  type        = list(string)
  default     = ["CriticalUpdates", "SecurityUpdates"]
  description = "The list of patch classifications"
}

variable "severity" {
  type        = list(string)
  default     = ["Critical", "Important"]
  description = "The list of patch severities"
}

variable "notification_arn" {
  type        = string
  default     = ""
  description = "The SNS topic ARN for notifications"
}

variable "notification_events" {
  type        = list(string)
  default     = []
  description = "The list of notification events"
}

variable "scan_schedule" {
  type        = string
  default     = ""
  description = "DEPRECATED: Use scan_maintenance_windows instead. The schedule for the patch baseline scan"
}

variable "scan_timezone" {
  type        = string
  default     = "Australia/Melbourne"
  description = "DEPRECATED: Use scan_maintenance_windows instead. The schedule timezone for the patch baseline scan"
}

variable "scan_max_concurrency" {
  type        = string
  default     = "20%"
  description = "DEPRECATED: Use scan_maintenance_windows instead. The max concurrency for the patch baseline scan"
}

variable "scan_max_errors" {
  type        = string
  default     = "20%"
  description = "DEPRECATED: Use scan_maintenance_windows instead. The max errors for the patch baseline scan"
}

variable "scan_duration" {
  type        = number
  default     = 5
  description = "DEPRECATED: Use scan_maintenance_windows instead. The duration for the patch baseline scan"
}

variable "scan_cutoff" {
  type        = number
  default     = 1
  description = "DEPRECATED: Use scan_maintenance_windows instead. The cutoff for the patch baseline scan"
}

variable "scan_maintenance_windows" {
  type = list(object({
    name            = string
    schedule        = string
    timezone        = optional(string, "Australia/Melbourne")
    duration        = optional(number, 5)
    cutoff          = optional(number, 1)
    max_concurrency = optional(string, "20%")
    max_errors      = optional(string, "20%")
  }))
  default     = []
  description = "List of maintenance windows for scan operations"
}

variable "install_schedule" {
  type        = string
  default     = ""
  description = "DEPRECATED: Use install_maintenance_windows instead. The schedule for the patch baseline install"
}

variable "install_timezone" {
  type        = string
  default     = "Australia/Melbourne"
  description = "DEPRECATED: Use install_maintenance_windows instead. The schedule timezone for the patch baseline install"
}

variable "install_duration" {
  type        = number
  default     = 5
  description = "DEPRECATED: Use install_maintenance_windows instead. The duration for the patch baseline install"
}

variable "install_cutoff" {
  type        = number
  default     = 1
  description = "DEPRECATED: Use install_maintenance_windows instead. The cutoff for the patch baseline install"
}

variable "install_max_concurrency" {
  type        = string
  default     = "10%"
  description = "DEPRECATED: Use install_maintenance_windows instead. The max concurrency for the patch baseline install"
}

variable "install_max_errors" {
  type        = string
  default     = "10%"
  description = "DEPRECATED: Use install_maintenance_windows instead. The max errors for the patch baseline install"
}

variable "install_reboot_option" {
  type        = string
  default     = "NoReboot"
  description = "DEPRECATED: Use install_maintenance_windows instead. The reboot option for the patch baseline install"
}

variable "install_maintenance_windows" {
  type = list(object({
    name            = string
    schedule        = string
    timezone        = optional(string, "Australia/Melbourne")
    duration        = optional(number, 5)
    cutoff          = optional(number, 1)
    max_concurrency = optional(string, "10%")
    max_errors      = optional(string, "10%")
    reboot_option   = optional(string, "NoReboot")
  }))
  default     = []
  description = "List of maintenance windows for install operations"
}

variable "approval_process_schedule" {
  type        = string
  default     = ""
  description = "The schedule for the approval process"
}

variable "approval_process_timezone" {
  type        = string
  default     = "Australia/Melbourne"
  description = "The schedule timezone for the approval process"
}

variable "approval_process_timeout" {
  type        = number
  default     = 86400
  description = "The timeout in seconds for the approval process"
}
