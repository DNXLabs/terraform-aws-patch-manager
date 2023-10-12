{
  "Comment": "Patch Manager Approval Workflow",
  "StartAt": "Disable Patch Install",
  "States": {
    "Disable Patch Install": {
      "Type": "Task",
      "Parameters": {
        "WindowId": "${maintenance_window}",
        "Enabled": false
      },
      "Resource": "arn:aws:states:::aws-sdk:ssm:updateMaintenanceWindow",
      "Next": "Request Approval",
      "ResultSelector": {
        "window_id.$": "$.WindowId"
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
          "window_id.$": "$.window_id",
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
      "Next": "Enable Patch Install"
    },
    "Enable Patch Install": {
      "Type": "Task",
      "Parameters": {
        "WindowId.$": "$.window_id",
        "Enabled": true
      },
      "Resource": "arn:aws:states:::aws-sdk:ssm:updateMaintenanceWindow",
      "Next": "Approval Success"
    },
    "Approval Success": {
      "Type": "Pass",
      "Next": "SNS Publish Result",
      "Result": {
        "message": "Approval process success"
      }
    },
    "Approval Timeout": {
      "Type": "Pass",
      "Result": {
        "message": "Approval process timeout"
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