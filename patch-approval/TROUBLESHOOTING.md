# Troubleshooting Guide

## Current Issues and Solutions

Based on the error logs, here are the issues and how to fix them:

### Issue 1: Missing Maintenance Window IDs

**Error**: `Monitoring maintenance windows: ['']`

**Problem**: The `MAINTENANCE_WINDOW_IDS` environment variable is not set or is empty.

**Solution**:
1. Go to AWS Lambda Console
2. Find your function: `Patch-Manager-Notification`
3. Go to **Configuration** → **Environment variables**
4. Add or update the environment variable:
   - **Key**: `MAINTENANCE_WINDOW_IDS`
   - **Value**: Your maintenance window IDs separated by commas (e.g., `mw-1234567890abcdef0,mw-0987654321fedcba0`)

**To find your maintenance window IDs**:
```bash
aws ssm describe-maintenance-windows --region ap-southeast-2
```

### Issue 2: SNS Permission Error

**Error**: `User: arn:aws:sts::533267147001:assumed-role/Patch-Manager-Notification-role-n7pojq51/Patch-Manager-Notification is not authorized to perform: SNS:Publish`

**Problem**: The Lambda execution role doesn't have permission to publish to the SNS topic.

**Solution**:

#### Option A: Using AWS Console
1. Go to **IAM Console** → **Roles**
2. Find the role: `Patch-Manager-Notification-role-n7pojq51`
3. Click **Add permissions** → **Attach policies**
4. Create a new policy with the JSON from `iam-policy-example.json`
5. Attach the policy to the role

#### Option B: Using AWS CLI
```bash
# Create the policy
aws iam create-policy \
    --policy-name PatchManagerNotificationPolicy \
    --policy-document file://iam-policy-example.json \
    --region ap-southeast-2

# Attach the policy to the role
aws iam attach-role-policy \
    --role-name Patch-Manager-Notification-role-n7pojq51 \
    --policy-arn arn:aws:iam::533267147001:policy/PatchManagerNotificationPolicy
```

#### Option C: Update Existing Policy
If you have an existing policy attached to the role, add these permissions:

```json
{
    "Effect": "Allow",
    "Action": [
        "sns:Publish"
    ],
    "Resource": "arn:aws:sns:ap-southeast-2:533267147001:patch-test"
}
```

## Environment Variables Checklist

Make sure these environment variables are set in your Lambda function:

- ✅ **SNS_TOPIC_ARN**: `arn:aws:sns:ap-southeast-2:533267147001:patch-test`
- ❌ **MAINTENANCE_WINDOW_IDS**: Currently empty - needs to be set
- ✅ **AWS_REGION**: `ap-southeast-2` (optional, will use Lambda's region by default)

## Testing After Fixes

1. **Test the Lambda function**:
   ```bash
   aws lambda invoke \
       --function-name Patch-Manager-Notification \
       --payload '{}' \
       --region ap-southeast-2 \
       response.json
   ```

2. **Check the response**:
   ```bash
   cat response.json
   ```

3. **Expected successful response**:
   ```json
   {
       "statusCode": 200,
       "body": "{\"message\": \"Patch notification sent successfully\", \"executions_found\": 1, \"instances_processed\": 3, \"send_result\": {\"status\": \"sent\", \"messageId\": \"12345678-1234-1234-1234-123456789012\"}}"
   }
   ```

## Common Issues and Solutions

### No Recent Executions Found
If you see `Found 0 recent executions`:
- Check that your maintenance windows have run recently
- Verify the maintenance window IDs are correct
- The function looks for the most recent execution from each window

### SNS Topic Not Found
If you get SNS topic errors:
- Verify the SNS topic exists: `aws sns list-topics --region ap-southeast-2`
- Check the topic ARN is correct in the environment variable
- Ensure the topic has email subscriptions configured

### Permission Denied Errors
- Verify all IAM permissions are correctly attached
- Check the Lambda execution role has the required policies
- Ensure resource ARNs match your actual AWS account and region

## Verification Steps

After making the fixes:

1. **Check Environment Variables**:
   ```bash
   aws lambda get-function-configuration \
       --function-name Patch-Manager-Notification \
       --region ap-southeast-2 \
       --query 'Environment.Variables'
   ```

2. **Check IAM Role Policies**:
   ```bash
   aws iam list-attached-role-policies \
       --role-name Patch-Manager-Notification-role-n7pojq51
   ```

3. **Test SNS Publishing**:
   ```bash
   aws sns publish \
       --topic-arn arn:aws:sns:ap-southeast-2:533267147001:patch-test \
       --message "Test message" \
       --region ap-southeast-2
   ```

## Next Steps

Once you've fixed both issues:
1. The function should successfully retrieve maintenance window executions
2. It will format the patch information into an email
3. Send the notification via SNS to your configured email addresses

If you continue to have issues, check the CloudWatch Logs for more detailed error information.
