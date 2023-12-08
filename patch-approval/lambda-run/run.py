import json
import boto3
import os

sfn_arn = os.environ.get('SFN_ARN')

def check_execution(name):
    client = boto3.client('stepfunctions')
    states = client.list_executions(
      stateMachineArn=sfn_arn,
      statusFilter='RUNNING',
    )
    executionARN = states['executions'][0]['name']

    if executionARN == name:
      return { 'check_execution': 'Execution valid' }
    else:
      raise Exception('Execution invalid')

def resume_state_machine(sfn_arn):
    client = boto3.client('stepfunctions')
    states = client.list_executions(
      stateMachineArn=sfn_arn,
      statusFilter='RUNNING',
    )
    executionARN = states['executions'][0]['executionArn']
    # get token to call success
    info = client.get_execution_history(
      executionArn=executionARN,
      maxResults=10,
    )
            
    payload_json = json.loads(info['events'][7]['taskScheduledEventDetails']['parameters'])
    token = payload_json['Payload']['token']

    # Call step success
    client.send_task_success(
      taskToken=token,
      output=json.dumps(token)
    )
    return { 'state_machine': 'State machine resumed' }

def lambda_handler(event, context):
    key = event.get('queryStringParameters', {}).get('key', '')
    logs = { 'key': key }

    try:
        result_key = check_execution(key)
        result_sfn = resume_state_machine(sfn_arn)
        
        logs |= result_key | result_sfn
        
        logs.update({
            'message': 'Patching request successfully approved!',
            'status': 'Success'
        })
    except Exception as err:
        logs.update({
            'message': str(err),
            'status': 'Error'
        })
    finally:
        print(json.dumps(logs))
        return {
            'statusCode': 200,
            "headers": { "Content-Type": "text/html" },
            'body': open('result.html', 'r').read()
        }