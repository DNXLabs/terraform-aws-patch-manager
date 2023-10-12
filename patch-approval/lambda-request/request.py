import boto3
import logging
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logging.getLogger("boto3").setLevel(logging.WARNING)
logging.getLogger("botocore").setLevel(logging.WARNING)

config = Config(
    region_name='ap-southeast-2',
    retries=dict(
        max_attempts=10
    )
)

def lambda_handler(event, context):
    print(event)
    
    topic_arn = event['topic_arn']
    lambda_url = event['url']
    execution_id = event['execution']
    
    client = boto3.client('sns', config=config,)
    
    try:
        client.publish(
            TopicArn=topic_arn,
            Subject="Patching Manager Approval Request",
            Message=f"""
            In order to authorize the next finPower production servers patching, please click on the link provided below"
            
            {lambda_url}?key={execution_id}
            """
        )
        logger.info('Patching Manager Approval Request sent to SNS topic')
        return { 'statusCode': 200 }
    except Exception as e:
        logger.error('Error sent to SNS topic: %s' % e)
        return { 'statusCode': 500 }
