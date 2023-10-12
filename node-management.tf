#SSMAgentUpdate
resource "aws_ssm_association" "ssm_agent" {
  count               = var.enabled ? 1 : 0
  name                = "AWS-UpdateSSMAgent"
  association_name    = "SystemAssociationForSsmAgentUpdate"
  max_concurrency     = 50
  max_errors          = "10%"
  compliance_severity = "UNSPECIFIED"

  schedule_expression = "rate(14 days)"
  parameters = {
    allowDowngrade = "false"
  }

  targets {
    key    = var.target
    values = var.target_value
  }
}

#Inventory
resource "aws_ssm_association" "inventory" {
  count               = var.enabled ? 1 : 0
  name                = "AWS-GatherSoftwareInventory"
  association_name    = "Inventory-Association"
  schedule_expression = "rate(1 day)"

  parameters = {
    applications                = "Enabled"
    awsComponents               = "Enabled"
    billingInfo                 = "Enabled"
    customInventory             = "Enabled"
    files                       = ""
    instanceDetailedInformation = "Enabled"
    networkConfig               = "Enabled"
    services                    = "Disabled"
    windowsRegistry             = ""
    windowsRoles                = "Disabled"
    windowsUpdates              = "Disabled"
  }

  targets {
    key    = var.target
    values = var.target_value
  }
}

#Session Manager
resource "aws_kms_key" "ssm_session_manager" {
  count               = var.session_encryption ? 1 : 0
  description         = "KMS key for SSM Session Manager"
  enable_key_rotation = true
}

resource "aws_kms_alias" "ssm_session_manager" {
  count         = var.session_encryption ? 1 : 0
  name          = "alias/kms/ssm-sm"
  target_key_id = aws_kms_key.ssm_session_manager[0].key_id
}

resource "aws_ssm_document" "session_manager_prefs" {
  count           = var.session_encryption ? 1 : 0
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      kmsKeyId                    = aws_kms_key.ssm_session_manager[0].key_id
      s3BucketName                = ""
      s3KeyPrefix                 = ""
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = ""
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
      idleSessionTimeout          = "20"
      maxSessionDuration          = ""
      runAsEnabled                = false
      shellProfile = {
        linux   = ""
        windows = ""
      }
    }
  })
}

#Custom PatchBaseline
resource "aws_ssm_patch_baseline" "default" {
  count            = var.enabled ? 1 : 0
  name             = "${var.name}-DefaultPatchBaseline"
  description      = "Custom Patch Baseline ${var.operating_system} for ${var.name}"
  operating_system = var.operating_system
  approved_patches = var.approved_patches
  rejected_patches = var.rejected_patches

  approval_rule {
    approve_after_days = 7

    patch_filter {
      key    = "CLASSIFICATION"
      values = var.classification
    }

    patch_filter {
      key    = "MSRC_SEVERITY"
      values = var.severity
    }
  }
}

resource "aws_ssm_patch_group" "patchgroup" {
  for_each    = { for value in var.target_value : value => value if var.enabled }
  baseline_id = aws_ssm_patch_baseline.default[0].id
  patch_group = each.value
}

resource "aws_ssm_default_patch_baseline" "default" {
  count            = var.enabled ? 1 : 0
  baseline_id      = aws_ssm_patch_baseline.default[0].id
  operating_system = aws_ssm_patch_baseline.default[0].operating_system
}

