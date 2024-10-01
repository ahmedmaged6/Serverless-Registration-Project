import json
import boto3 

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    if 'body' not in event:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'message': 'Missing request body'
            })
        }
    
    body = json.loads(event['body'])
    
    email = body.get('email')
    confirmation_code = body.get('confirmationCode')

    if not (email and confirmation_code):
        return {
            'statusCode': 400,
            'headers': {
                    "Access-Control-Allow-Origin": "*",  
                    "Access-Control-Allow-Methods": "OPTIONS, POST",  
                    "Access-Control-Allow-Headers": "Content-Type"  
                },
            'body': json.dumps({
                'message': 'Missing required fields'
            })
        }

    try:
        response = client.confirm_sign_up(
            ClientId='1f1fkq68uintemgfmmco3lrpii', #would be identified later using outputs
            Username=email,
            ConfirmationCode=confirmation_code
        )
        
        return {
            'statusCode': 200,
             'headers': {
                    "Access-Control-Allow-Origin": "*",  
                    "Access-Control-Allow-Methods": "OPTIONS, POST",  
                    "Access-Control-Allow-Headers": "Content-Type"  
                },
            'body': json.dumps({
                'message': 'User confirmed successfully',
                'response': response
            })
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'headers': {
                    "Access-Control-Allow-Origin": "*",  
                    "Access-Control-Allow-Methods": "OPTIONS, POST",  
                    "Access-Control-Allow-Headers": "Content-Type"  
                },
            'body': json.dumps({
                'message': 'Error confirming user sign-up',
                'error': str(e)
            })
        }
