import json
import boto3
import os
import logging
from datetime import datetime, timedelta
from botocore.config import Config
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logging.getLogger("boto3").setLevel(logging.WARNING)
logging.getLogger("botocore").setLevel(logging.WARNING)

# AWS client configuration with retry logic
config = Config(
    region_name=os.environ.get('AWS_REGION', 'us-east-1'),
    retries=dict(
        max_attempts=3,
        mode='adaptive'
    )
)

# Environment variables
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')
MAINTENANCE_WINDOW_IDS = os.environ.get('MAINTENANCE_WINDOW_IDS', '').split(',')

def get_latest_patch_executions():
    """
    Get the most recent patch executions from maintenance windows
    
    Returns:
        list: List of the latest execution details
    """
    try:
        ssm_client = boto3.client('ssm', config=config)
        
        latest_executions = []
        
        # Get the latest execution for each maintenance window
        for window_id in MAINTENANCE_WINDOW_IDS:
            if not window_id.strip():
                continue
                
            try:
                response = ssm_client.describe_maintenance_window_executions(
                    WindowId=window_id.strip(),
                    MaxResults=1  # Get only the most recent execution
                )
                
                executions = response.get('WindowExecutions', [])
                if executions:
                    execution = executions[0]
                    execution['MaintenanceWindowId'] = window_id.strip()
                    latest_executions.append(execution)
                    
            except ClientError as e:
                logger.warning(f"Could not get executions for window {window_id}: {e}")
                continue
        
        return latest_executions
        
    except Exception as e:
        logger.error(f"Error getting latest patch executions: {e}")
        return []

def get_execution_results(window_id, execution_id):
    """
    Get detailed results for a specific execution
    
    Args:
        window_id (str): Maintenance window ID
        execution_id (str): Execution ID
        
    Returns:
        dict: Execution results with instance details
    """
    try:
        ssm_client = boto3.client('ssm', config=config)
        
        # Get basic execution info
        execution_info = {
            'window_id': window_id,
            'execution_id': execution_id,
            'instances': []
        }
        
        # Get task executions
        task_response = ssm_client.describe_maintenance_window_execution_tasks(
            WindowExecutionId=execution_id
        )
        
        # Process each task to get instance results
        for task in task_response.get('WindowExecutionTaskIdentities', []):
            task_id = task['TaskExecutionId']
            
            try:
                # Get task invocations (instance-level results)
                invocation_response = ssm_client.describe_maintenance_window_execution_task_invocations(
                    WindowExecutionId=execution_id,
                    TaskId=task_id
                )
                
                for invocation in invocation_response.get('WindowExecutionTaskInvocationIdentities', []):
                    instance_id = invocation.get('Parameters', {}).get('InstanceId', 'Unknown')
                    
                    if instance_id != 'Unknown':
                        instance_result = {
                            'instance_id': instance_id,
                            'status': invocation.get('Status', 'Unknown'),
                            'start_time': invocation.get('StartTime'),
                            'end_time': invocation.get('EndTime'),
                            'status_details': invocation.get('StatusDetails', '')
                        }
                        
                        execution_info['instances'].append(instance_result)
                        
            except ClientError as e:
                logger.warning(f"Could not get task invocations for task {task_id}: {e}")
        
        return execution_info
        
    except Exception as e:
        logger.error(f"Error getting execution results for {execution_id}: {e}")
        return None

def get_instance_patch_details(instance_id):
    """
    Get current patch state for an instance
    
    Args:
        instance_id (str): EC2 instance ID
        
    Returns:
        dict: Patch state information
    """
    try:
        ssm_client = boto3.client('ssm', config=config)
        
        response = ssm_client.describe_instance_patch_states(
            InstanceIds=[instance_id]
        )
        
        if response.get('InstancePatchStates'):
            patch_state = response['InstancePatchStates'][0]
            return {
                'installed_count': patch_state.get('InstalledCount', 0),
                'installed_pending_reboot_count': patch_state.get('InstalledPendingRebootCount', 0),
                'missing_count': patch_state.get('MissingCount', 0),
                'failed_count': patch_state.get('FailedCount', 0),
                'operation': patch_state.get('Operation', 'Unknown'),
                'operation_start_time': patch_state.get('OperationStartTime'),
                'operation_end_time': patch_state.get('OperationEndTime')
            }
        
        return None
        
    except Exception as e:
        logger.error(f"Error getting patch details for instance {instance_id}: {e}")
        return None

def get_installed_patches(instance_id, operation_start_time=None):
    """
    Get list of patches installed during the last patch operation
    
    Args:
        instance_id (str): EC2 instance ID
        operation_start_time (datetime): Start time of the patch operation
        
    Returns:
        list: List of installed patches with details
    """
    try:
        ssm_client = boto3.client('ssm', config=config)
        
        # Set up filters for the patch query
        filters = [
            {
                'Key': 'State',
                'Values': ['Installed']
            }
        ]
        
        # If we have operation start time, filter patches installed after that time
        if operation_start_time:
            # Convert to string format if it's a datetime object
            if hasattr(operation_start_time, 'strftime'):
                start_time_str = operation_start_time.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
            else:
                start_time_str = str(operation_start_time)
            
            filters.append({
                'Key': 'InstalledTime',
                'Values': [start_time_str]
            })
        
        # Get patches for the instance
        response = ssm_client.describe_instance_patches(
            InstanceId=instance_id,
            Filters=filters,
            MaxResults=50  # Limit to avoid too much data
        )
        
        patches = []
        for patch in response.get('Patches', []):
            patch_info = {
                'title': patch.get('Title', 'Unknown'),
                'kb_id': patch.get('KBId', ''),
                'classification': patch.get('Classification', 'Unknown'),
                'severity': patch.get('Severity', 'Unknown'),
                'installed_time': patch.get('InstalledTime'),
                'state': patch.get('State', 'Unknown')
            }
            patches.append(patch_info)
        
        # Sort patches by installed time (most recent first)
        patches.sort(key=lambda x: x.get('installed_time') or datetime.min, reverse=True)
        
        return patches
        
    except Exception as e:
        logger.error(f"Error getting installed patches for instance {instance_id}: {e}")
        return []

def get_failed_patches(instance_id):
    """
    Get list of patches that failed to install
    
    Args:
        instance_id (str): EC2 instance ID
        
    Returns:
        list: List of failed patches with details
    """
    try:
        ssm_client = boto3.client('ssm', config=config)
        
        # Get failed patches
        response = ssm_client.describe_instance_patches(
            InstanceId=instance_id,
            Filters=[
                {
                    'Key': 'State',
                    'Values': ['Failed']
                }
            ],
            MaxResults=20  # Limit failed patches to avoid too much data
        )
        
        failed_patches = []
        for patch in response.get('Patches', []):
            patch_info = {
                'title': patch.get('Title', 'Unknown'),
                'kb_id': patch.get('KBId', ''),
                'classification': patch.get('Classification', 'Unknown'),
                'severity': patch.get('Severity', 'Unknown'),
                'state': patch.get('State', 'Unknown')
            }
            failed_patches.append(patch_info)
        
        return failed_patches
        
    except Exception as e:
        logger.error(f"Error getting failed patches for instance {instance_id}: {e}")
        return []

def get_instance_names(instance_ids):
    """
    Get instance names from EC2 tags
    
    Args:
        instance_ids (list): List of instance IDs
        
    Returns:
        dict: Instance names keyed by instance ID
    """
    try:
        ec2_client = boto3.client('ec2', config=config)
        
        if not instance_ids:
            return {}
        
        response = ec2_client.describe_instances(InstanceIds=instance_ids)
        
        instance_names = {}
        for reservation in response.get('Reservations', []):
            for instance in reservation.get('Instances', []):
                instance_id = instance['InstanceId']
                
                # Get instance name from tags
                name = instance_id  # Default to instance ID if no name tag
                for tag in instance.get('Tags', []):
                    if tag['Key'] == 'Name':
                        name = tag['Value']
                        break
                
                instance_names[instance_id] = {
                    'name': name,
                    'instance_type': instance.get('InstanceType', 'Unknown'),
                    'platform': instance.get('Platform', 'Linux')
                }
        
        return instance_names
        
    except Exception as e:
        logger.error(f"Error getting instance names: {e}")
        return {}

def format_notification_message(executions_data):
    """
    Format execution data into a notification message
    
    Args:
        executions_data (list): List of execution data
        
    Returns:
        tuple: (subject, message) for notification
    """
    if not executions_data:
        return (
            "🔧 AWS Patch Manager - No Recent Executions",
            "No patch executions found in the monitored maintenance windows."
        )
    
    # Collect all instance IDs for batch lookup
    all_instance_ids = set()
    for execution_data in executions_data:
        for instance in execution_data.get('instances', []):
            all_instance_ids.add(instance['instance_id'])
    
    # Get instance information
    instance_info = get_instance_names(list(all_instance_ids))
    
    # Build notification message
    total_instances = len(all_instance_ids)
    successful_instances = 0
    failed_instances = 0
    pending_reboot_instances = 0
    
    message_lines = [
        "🔧 AWS Patch Manager - Latest Execution Report",
        "=" * 50,
        f"Report Generated: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}",
        f"Maintenance Windows Checked: {len(executions_data)}",
        f"Total Instances: {total_instances}",
        ""
    ]
    
    # Process each execution
    for execution_data in executions_data:
        window_id = execution_data.get('window_id', 'Unknown')
        execution_id = execution_data.get('execution_id', 'Unknown')
        instances = execution_data.get('instances', [])
        
        message_lines.extend([
            f"Maintenance Window: {window_id}",
            f"Execution ID: {execution_id}",
            f"Instances in this execution: {len(instances)}",
            ""
        ])
        
        # Process each instance
        for instance in instances:
            instance_id = instance['instance_id']
            status = instance['status']
            
            # Get instance details
            info = instance_info.get(instance_id, {})
            instance_name = info.get('name', instance_id)
            instance_type = info.get('instance_type', 'Unknown')
            platform = info.get('platform', 'Unknown')
            
            # Get patch details
            patch_details = get_instance_patch_details(instance_id)
            
            # Determine status emoji and count
            if status == 'Success':
                successful_instances += 1
                status_emoji = "✅"
            elif status in ['Failed', 'TimedOut', 'Cancelled']:
                failed_instances += 1
                status_emoji = "❌"
            else:
                status_emoji = "⚠️"
            
            # Calculate duration
            duration = "Unknown"
            if instance.get('start_time') and instance.get('end_time'):
                try:
                    start = instance['start_time']
                    end = instance['end_time']
                    if isinstance(start, str):
                        start = datetime.fromisoformat(start.replace('Z', '+00:00'))
                    if isinstance(end, str):
                        end = datetime.fromisoformat(end.replace('Z', '+00:00'))
                    duration = str(end - start)
                except:
                    pass
            
            message_lines.extend([
                f"{status_emoji} {instance_name} ({instance_id})",
                f"   Platform: {platform} | Type: {instance_type}",
                f"   Status: {status} | Duration: {duration}"
            ])
            
            # Add status details if available
            if instance.get('status_details'):
                message_lines.append(f"   Details: {instance['status_details']}")
            
            # Add patch information if available
            if patch_details:
                installed = patch_details['installed_count']
                pending_reboot = patch_details['installed_pending_reboot_count']
                failed = patch_details['failed_count']
                missing = patch_details['missing_count']
                operation_start_time = patch_details.get('operation_start_time')
                
                message_lines.extend([
                    f"   Patches Installed: {installed}",
                    f"   Failed: {failed}",
                    f"   Missing: {missing}",
                    f"   Pending Reboot: {pending_reboot}"
                ])
                
                if pending_reboot > 0:
                    pending_reboot_instances += 1
                    message_lines.append(f"   🔄 REBOOT REQUIRED")
                
                # Get and display installed patches
                if installed > 0:
                    installed_patches = get_installed_patches(instance_id, operation_start_time)
                    if installed_patches:
                        message_lines.append(f"   📦 INSTALLED PATCHES:")
                        for patch in installed_patches[:10]:  # Limit to first 10 patches
                            kb_info = f" ({patch['kb_id']})" if patch['kb_id'] else ""
                            severity_info = f" [{patch['severity']}]" if patch['severity'] != 'Unknown' else ""
                            message_lines.append(f"      • {patch['title']}{kb_info}{severity_info}")
                        
                        if len(installed_patches) > 10:
                            message_lines.append(f"      ... and {len(installed_patches) - 10} more patches")
                
                # Get and display failed patches
                if failed > 0:
                    failed_patches = get_failed_patches(instance_id)
                    if failed_patches:
                        message_lines.append(f"   ❌ FAILED PATCHES:")
                        for patch in failed_patches[:5]:  # Limit to first 5 failed patches
                            kb_info = f" ({patch['kb_id']})" if patch['kb_id'] else ""
                            severity_info = f" [{patch['severity']}]" if patch['severity'] != 'Unknown' else ""
                            message_lines.append(f"      • {patch['title']}{kb_info}{severity_info}")
                        
                        if len(failed_patches) > 5:
                            message_lines.append(f"      ... and {len(failed_patches) - 5} more failed patches")
            
            message_lines.append("")  # Empty line between instances
    
    # Add summary
    message_lines.extend([
        "SUMMARY",
        "-" * 10,
        f"✅ Successful: {successful_instances}",
        f"❌ Failed: {failed_instances}",
        f"🔄 Pending Reboot: {pending_reboot_instances}",
        "",
        "=" * 50,
        "This is an automated notification from AWS Patch Manager."
    ])
    
    # Create subject line
    if failed_instances > 0:
        subject = f"🔧 Patch Manager Update - {failed_instances} Failed, {successful_instances} Successful"
    elif pending_reboot_instances > 0:
        subject = f"🔧 Patch Manager Update - {pending_reboot_instances} Require Reboot, {successful_instances} Successful"
    else:
        subject = f"🔧 Patch Manager Update - All {successful_instances} Instances Successful"
    
    return subject, "\n".join(message_lines)

def send_notification(subject, message):
    """
    Send notification via SNS
    
    Args:
        subject (str): Email subject
        message (str): Email message
        
    Returns:
        dict: Send result
    """
    if not SNS_TOPIC_ARN:
        raise ValueError("SNS_TOPIC_ARN environment variable not configured")
    
    try:
        sns_client = boto3.client('sns', config=config)
        
        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=subject,
            Message=message
        )
        
        logger.info(f"Successfully sent patch notification. MessageId: {response.get('MessageId')}")
        return {
            'status': 'sent',
            'messageId': response.get('MessageId')
        }
        
    except ClientError as e:
        logger.error(f"AWS error sending notification: {e}")
        raise ValueError(f"Failed to send notification: {e.response['Error']['Message']}")

def lambda_handler(event, context):
    """
    Lambda function to send patch execution notifications
    
    This function gets the latest patch execution results and sends
    a notification email with the status of all instances.
    """
    
    try:
        logger.info("Starting patch notification generation")
        logger.info(f"Monitoring maintenance windows: {MAINTENANCE_WINDOW_IDS}")
        
        # Get latest patch executions
        executions = get_latest_patch_executions()
        logger.info(f"Found {len(executions)} recent executions")
        
        # Get detailed execution results
        executions_data = []
        for execution in executions:
            window_id = execution['MaintenanceWindowId']
            execution_id = execution['WindowExecutionId']
            
            results = get_execution_results(window_id, execution_id)
            if results:
                executions_data.append(results)
        
        # Format and send notification
        subject, message = format_notification_message(executions_data)
        send_result = send_notification(subject, message)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Patch notification sent successfully',
                'executions_found': len(executions),
                'instances_processed': len(set(
                    instance['instance_id'] 
                    for execution_data in executions_data 
                    for instance in execution_data.get('instances', [])
                )),
                'send_result': send_result
            })
        }
        
    except ValueError as e:
        logger.error(f"Configuration error: {str(e)}")
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'Configuration Error',
                'message': str(e)
            })
        }
        
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal Server Error',
                'message': 'An unexpected error occurred while generating the patch notification'
            })
        }
