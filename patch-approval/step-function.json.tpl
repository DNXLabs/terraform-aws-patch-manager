{
  "Comment": "AWS Systems Manager Patch Approval Workflow",
  "StartAt": "RequestApproval",
  "States": {
    "RequestApproval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${function_arn}",
        "Payload": {
          "patch_group.$": "$.patch_group",
          "maintenance_window.$": "$.maintenance_window",
          "request_type": "approval_request"
        }
      },
      "ResultPath": "$.approval_request_result",
      "Next": "WaitForApproval"
    },
    "WaitForApproval": {
      "Type": "Wait",
      "Seconds": ${timeout_seconds},
      "Next": "CheckApprovalStatus"
    },
    "CheckApprovalStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.approval_status",
          "StringEquals": "approved",
          "Next": "ExecutePatchInstallation"
        },
        {
          "Variable": "$.approval_status",
          "StringEquals": "rejected",
          "Next": "ApprovalRejected"
        }
      ],
      "Default": "ApprovalTimeout"
    },
    "ExecutePatchInstallation": {
      "Type": "Task",
      "Resource": "arn:aws:states:::http:invoke",
      "Parameters": {
        "ApiEndpoint": "${function_url}",
        "Method": "POST",
        "RequestBody": {
          "patch_group.$": "$.patch_group",
          "maintenance_window.$": "$.maintenance_window",
          "approval_status": "approved"
        }
      },
      "ResultPath": "$.installation_result",
      "Next": "NotifySuccess"
    },
    "NotifySuccess": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${topic_arn}",
        "Subject": "Patch Installation Completed Successfully",
        "Message.$": "$.installation_result"
      },
      "End": true
    },
    "ApprovalRejected": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${topic_arn}",
        "Subject": "Patch Installation Rejected",
        "Message": {
          "status": "rejected",
          "patch_group.$": "$.patch_group",
          "maintenance_window.$": "$.maintenance_window",
          "message": "Patch installation was rejected by the approver"
        }
      },
      "End": true
    },
    "ApprovalTimeout": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${topic_arn}",
        "Subject": "Patch Installation Approval Timeout",
        "Message": {
          "status": "timeout",
          "patch_group.$": "$.patch_group",
          "maintenance_window.$": "$.maintenance_window",
          "message": "Patch installation approval timed out after ${timeout_seconds} seconds"
        }
      },
      "End": true
    }
  }
}
