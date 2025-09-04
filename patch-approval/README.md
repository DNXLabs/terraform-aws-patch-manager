# AWS Patch Manager Notification Lambda Function

This directory contains a Lambda function that sends detailed email notifications about AWS Patch Manager execution results. The function provides comprehensive reporting on patch installations, failures, and reboot requirements.

## Overview

The notification function is designed to run after patch operations complete and send summary emails of what happened during the patching process. It retrieves detailed information about the latest patch executions and formats it into user-friendly email reports.

## Lambda Function

### Notification Function (`lambda-notification/lambda_function.py`)

**Purpose**: Sends detailed email notifications about the latest patch execution results.

**Trigger**: Manual invocation, scheduled events, or post-execution triggers.

**Key Features**:
- Retrieves the most recent patch execution from each maintenance window
- Provides detailed instance-level patch status
- Shows specific patches that were installed and failed
- Includes instance information (name, type, platform)
- Calculates execution duration and success rates
- Sends formatted email reports via SNS

**Environment Variables**:
- `SNS_TOPIC_ARN` (required): SNS topic for sending notifications
- `MAINTENANCE_WINDOW_IDS` (required): Comma-separated list of maintenance window IDs to monitor
- `AWS_REGION` (optional): AWS region for client configuration

**Report Contents**:
- Overall execution summary with success/failure counts
- Instance-level details including:
  - Patch installation status and execution duration
  - Number of patches installed, failed, missing
  - Pending reboot requirements
  - Specific patch details (title, KB ID, severity)
  - Error details if applicable
- Platform and instance type information
- Maintenance window execution details

## Deployment

### Prerequisites

- Python 3.11 runtime
- Required IAM permissions for SNS, SSM, and EC2
- SNS topic configured for email notifications

### Dependencies

The function uses the following dependencies (see `requirements.txt`):
- `boto3>=1.34.0`
- `botocore>=1.34.0`

### IAM Permissions

The Lambda function requires the following permissions:

- `ssm:DescribeMaintenanceWindowExecutions` on maintenance windows
- `ssm:DescribeMaintenanceWindowExecutionTasks` on maintenance windows
- `ssm:DescribeMaintenanceWindowExecutionTaskInvocations` on maintenance windows
- `ssm:DescribeInstancePatchStates` on EC2 instances
- `ssm:DescribeInstancePatches` on EC2 instances
- `ec2:DescribeInstances` on EC2 instances
- `sns:Publish` on the notification topic

## Usage Examples

### Manual Invocation

```python
import boto3

lambda_client = boto3.client('lambda')

# Basic invocation - uses environment variables
response = lambda_client.invoke(
    FunctionName='patch-notification-function',
    Payload=json.dumps({})
)

# Custom maintenance windows
response = lambda_client.invoke(
    FunctionName='patch-notification-function',
    Payload=json.dumps({
        "maintenance_window_ids": ["mw-12345", "mw-67890"]
    })
)
```

### Scheduled Execution

You can schedule the function to run automatically after maintenance windows complete using EventBridge:

```json
{
  "Rules": [
    {
      "Name": "patch-notification-schedule",
      "ScheduleExpression": "cron(0 2 ? * SUN *)",
      "State": "ENABLED",
      "Targets": [
        {
          "Id": "1",
          "Arn": "arn:aws:lambda:region:account:function:patch-notification-function"
        }
      ]
    }
  ]
}
```

## Sample Notification Output

The function generates detailed email reports like this:

```
🔧 AWS Patch Manager - Latest Execution Report
==================================================
Report Generated: 2024-01-15 10:30:00 UTC
Maintenance Windows Checked: 2
Total Instances: 3

Maintenance Window: mw-12345
Execution ID: exec-67890
Instances in this execution: 3

✅ WebServer-01 (i-1234567890abcdef0)
   Platform: Linux | Type: t3.medium
   Status: Success | Duration: 0:15:30
   Patches Installed: 12
   Failed: 0
   Missing: 0
   Pending Reboot: 3
   🔄 REBOOT REQUIRED
   📦 INSTALLED PATCHES:
      • Security update for kernel (KB123456) [Critical]
      • Update for systemd [Important]
      • Security update for openssl [Critical]
      • Update for curl [Moderate]
      • Security update for nginx [Important]
      ... and 7 more patches

❌ DatabaseServer-02 (i-0987654321fedcba0)
   Platform: Windows | Type: m5.large
   Status: Failed | Duration: 0:08:45
   Details: Patch installation failed due to insufficient disk space
   Patches Installed: 5
   Failed: 3
   Missing: 15
   Pending Reboot: 0
   📦 INSTALLED PATCHES:
      • 2024-01 Cumulative Update for Windows Server (KB5034441) [Critical]
      • Security Update for Microsoft Edge (KB5034442) [Important]
      • Update for Windows Defender (KB5034443) [Important]
      • .NET Framework Security Update (KB5034444) [Critical]
      • Windows Update for Office 365 (KB5034445) [Moderate]
   ❌ FAILED PATCHES:
      • 2024-01 Security Update for SQL Server (KB5034446) [Critical]
      • Update for Visual C++ Redistributable (KB5034447) [Important]
      • Windows Feature Update (KB5034448) [Important]

SUMMARY
----------
✅ Successful: 2
❌ Failed: 1
🔄 Pending Reboot: 1

==================================================
This is an automated notification from AWS Patch Manager.
```

## Configuration

### Environment Variables Setup

```bash
# Required
export SNS_TOPIC_ARN="arn:aws:sns:us-east-1:123456789012:patch-notifications"
export MAINTENANCE_WINDOW_IDS="mw-12345,mw-67890,mw-abcdef"

# Optional
export AWS_REGION="us-east-1"
```

### SNS Topic Configuration

Ensure your SNS topic is configured with appropriate email subscriptions:

```json
{
  "TopicArn": "arn:aws:sns:us-east-1:123456789012:patch-notifications",
  "Subscriptions": [
    {
      "Protocol": "email",
      "Endpoint": "admin@company.com"
    },
    {
      "Protocol": "email",
      "Endpoint": "ops-team@company.com"
    }
  ]
}
```

## Monitoring and Logging

The function includes comprehensive logging:

- Execution start and completion details
- Number of maintenance windows and instances processed
- AWS API call results and any errors
- Performance metrics and timing information

Logs are available in CloudWatch Logs under the function's log group.

## Error Handling

The function implements robust error handling:

- **Configuration Errors**: Returns 400 status for missing required environment variables
- **AWS Service Errors**: Returns 500 status with service-specific error details
- **Unexpected Errors**: Returns 500 status with generic error messages
- **Partial Failures**: Continues processing other instances/windows if some fail

## Troubleshooting

### Common Issues

1. **Missing Environment Variables**: Ensure `SNS_TOPIC_ARN` and `MAINTENANCE_WINDOW_IDS` are configured
2. **Permission Errors**: Verify IAM role has all required permissions
3. **No Executions Found**: Check that maintenance window IDs are correct and have recent executions
4. **Email Not Received**: Verify SNS topic configuration and email subscriptions

### Debug Steps

1. Check CloudWatch Logs for detailed error messages
2. Verify environment variable configuration
3. Test IAM permissions using AWS CLI
4. Validate maintenance window IDs exist and have executions
5. Test SNS topic by publishing a test message

## Customization

You can customize the notification format by modifying the `format_notification_message` function:

- Adjust the number of patches shown per instance
- Change the email formatting and styling
- Add additional instance or patch information
- Modify the summary statistics

## Version History

- **v1.0**: Initial notification function with basic patch reporting
- **v2.0**: Added detailed patch information including specific patches installed and failed
- **v2.1**: Enhanced error handling and improved email formatting
