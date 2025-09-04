import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function to execute patch installation after approval
    """
    
    # Initialize clients
    ssm = boto3.client('ssm')
    sns = boto3.client('sns')
    
    try:
        # Extract information from the event
        patch_group = event.get('patch_group', 'Unknown')
        maintenance_window = event.get('maintenance_window', 'Unknown')
        approval_status = event.get('approval_status', 'approved')
        
        if approval_status != 'approved':
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'Patch installation skipped - not approved',
                    'patch_group': patch_group,
                    'status': approval_status
                })
            }
        
        # Execute patch installation
        response = ssm.send_command(
            DocumentName='AWS-RunPatchBaseline',
            Parameters={
                'Operation': ['Install'],
                'RebootOption': ['RebootIfNeeded']
            },
            Targets=[
                {
                    'Key': 'tag:PatchGroup',
                    'Values': [patch_group]
                }
            ],
            MaxConcurrency='10%',
            MaxErrors='10%'
        )
        
        command_id = response['Command']['CommandId']
        
        # Send notification
        message = {
            'patch_group': patch_group,
            'maintenance_window': maintenance_window,
            'command_id': command_id,
            'timestamp': datetime.utcnow().isoformat(),
            'status': 'installation_started'
        }
        
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if topic_arn:
            sns.publish(
                TopicArn=topic_arn,
                Message=json.dumps(message, indent=2),
                Subject=f'Patch Installation Started - {patch_group}'
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Patch installation started successfully',
                'patch_group': patch_group,
                'command_id': command_id
            })
        }
        
    except Exception as e:
        print(f"Error executing patch installation: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to execute patch installation',
                'details': str(e)
            })
        }
