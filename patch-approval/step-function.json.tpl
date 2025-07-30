{
  "Comment": "Patch Manager Approval Workflow - Multiple Maintenance Windows",
  "StartAt": "Disable All Install Windows",
  "States": {
    "Disable All Install Windows": {
      "Type": "Map",
      "ItemsPath": "$.maintenance_windows",
      "MaxConcurrency": 10,
      "Iterator": {
        "StartAt": "Disable Window",
        "States": {
          "Disable Window": {
            "Type": "Task",
            "Parameters": {
              "WindowId.$": "$",
              "Enabled": false
            },
            "Resource": "arn:aws:states:::aws-sdk:ssm:updateMaintenanceWindow",
            "End": true,
            "ResultSelector": {
              "window_id.$": "$.WindowId"
            }
          }
        }
      },
      "Next": "Request Approval",
      "InputTransformer": {
        "PathsMap": {},
        "InputTemplate": {
          "maintenance_windows": ${jsonencode(maintenance_windows)}
        }
      }
    },
    "Request Approval": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Parameters": {
        "FunctionName": "${function_arn}",
        "Payload": {
          "topic_arn": "${topic_arn}",
          "url": "${function_url}",
          "execution.$": "$$.Execution.Name",
          "maintenance_windows": ${jsonencode(maintenance_windows)},
          "token.$": "$$.Task.Token"
        }
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 60,
          "MaxAttempts": 2,
          "BackoffRate": 2
        }
      ],
      "Catch": [
        {
          "ErrorEquals": [
            "States.Timeout"
          ],
          "Next": "Approval Timeout",
          "Comment": "Timeout",
          "ResultPath": "$.error"
        }
      ],
      "TimeoutSeconds": ${timeout_seconds},
      "ResultPath": null,
      "Next": "Enable All Install Windows"
    },
    "Enable All Install Windows": {
      "Type": "Map",
      "ItemsPath": "$.maintenance_windows",
      "MaxConcurrency": 10,
      "Iterator": {
        "StartAt": "Enable Window",
        "States": {
          "Enable Window": {
            "Type": "Task",
            "Parameters": {
              "WindowId.$": "$",
              "Enabled": true
            },
            "Resource": "arn:aws:states:::aws-sdk:ssm:updateMaintenanceWindow",
            "End": true,
            "ResultSelector": {
              "window_id.$": "$.WindowId"
            }
          }
        }
      },
      "InputTransformer": {
        "PathsMap": {},
        "InputTemplate": {
          "maintenance_windows": ${jsonencode(maintenance_windows)}
        }
      },
      "Next": "Approval Success"
    },
    "Approval Success": {
      "Type": "Pass",
      "Next": "SNS Publish Result",
      "Result": {
        "message": "Approval process success - All maintenance windows enabled"
      }
    },
    "Approval Timeout": {
      "Type": "Pass",
      "Result": {
        "message": "Approval process timeout - Maintenance windows remain disabled"
      },
      "End": true
    },
    "SNS Publish Result": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${topic_arn}",
        "Message.$": "States.JsonToString($.message)"
      },
      "End": true
    }
  }
}
