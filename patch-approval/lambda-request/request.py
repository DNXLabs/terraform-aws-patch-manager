import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function to handle patch approval requests
    """
    
    # Initialize clients
    sns = boto3.client('sns')
    
    try:
        # Extract information from the event
        patch_group = event.get('patch_group', 'Unknown')
        maintenance_window = event.get('maintenance_window', 'Unknown')
        
        # Create approval request message
        message = {
            'patch_group': patch_group,
            'maintenance_window': maintenance_window,
            'timestamp': datetime.utcnow().isoformat(),
            'status': 'pending_approval'
        }
        
        # Send notification if SNS topic is configured
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if topic_arn:
            sns.publish(
                TopicArn=topic_arn,
                Message=json.dumps(message, indent=2),
                Subject=f'Patch Approval Request - {patch_group}'
            )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Patch approval request processed successfully',
                'patch_group': patch_group,
                'maintenance_window': maintenance_window
            })
        }
        
    except Exception as e:
        print(f"Error processing patch approval request: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to process patch approval request',
                'details': str(e)
            })
        }
