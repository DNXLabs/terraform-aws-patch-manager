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
  description = "The schedule for the patch baseline scan"
}

variable "scan_timezone" {
  type        = string
  default     = "Australia/Melbourne"
  description = "The schedule timezone for the patch baseline scan"
}

variable "scan_max_concurrency" {
  type        = string
  default     = "20%"
  description = "The max concurrency for the patch baseline scan"
}

variable "scan_max_errors" {
  type        = string
  default     = "20%"
  description = "The max errors for the patch baseline scan"
}

variable "scan_duration" {
  type        = number
  default     = 5
  description = "The duration for the patch baseline scan"
}

variable "scan_cutoff" {
  type        = number
  default     = 1
  description = "The cutoff for the patch baseline scan"
}

variable "install_schedule" {
  type        = string
  default     = ""
  description = "The schedule for the patch baseline scan"
}

variable "install_timezone" {
  type        = string
  default     = "Australia/Melbourne"
  description = "The schedule timezone for the patch baseline scan"
}

variable "install_duration" {
  type        = number
  default     = 5
  description = "The duration for the patch baseline scan"
}

variable "install_cutoff" {
  type        = number
  default     = 1
  description = "The cutoff for the patch baseline scan"
}

variable "install_max_concurrency" {
  type        = string
  default     = "10%"
  description = "The max concurrency for the patch baseline scan"
}

variable "install_max_errors" {
  type        = string
  default     = "10%"
  description = "The max errors for the patch baseline scan"
}

variable "install_reboot_option" {
  type        = string
  default     = "NoReboot"
  description = "The reboot option for the patch baseline scan"
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
