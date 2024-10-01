import json
import boto3

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    if 'body' in event and event['body']:
        body = json.loads(event['body'])
    else:
        body = event
    
    email = body.get('email')
    password = body.get('password')
    
    if not email or not password:
        return {
            'statusCode': 400,
            'headers': {
                "Access-Control-Allow-Origin": "*",  
                "Access-Control-Allow-Methods": "OPTIONS, POST",  
                "Access-Control-Allow-Headers": "Content-Type"  
            },
            'body': json.dumps({'error': 'Missing email or password'})
        }
    
    try:
        response = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            ClientId='1f1fkq68uintemgfmmco3lrpii', #would be identified later using outputs
            AuthParameters={
                'USERNAME': email,
                'PASSWORD': password
            }
        )
        
        return {
            'statusCode': 200,
            'headers': {
                "Access-Control-Allow-Origin": "*",  
                "Access-Control-Allow-Methods": "OPTIONS, POST",  
                "Access-Control-Allow-Headers": "Content-Type"  
            },
            'body': json.dumps({
                'message': 'Login successful',
                'data': response['AuthenticationResult']  
            })
        }
    
    except client.exceptions.NotAuthorizedException:
        return {
            'statusCode': 401,
            'headers': {
                "Access-Control-Allow-Origin": "*",  
                "Access-Control-Allow-Methods": "OPTIONS, POST",  
                "Access-Control-Allow-Headers": "Content-Type"  
            },
            'body': json.dumps({
                'message': 'Invalid username or password'
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
                'message': 'Error logging in',
                'error': str(e)
            })
        }
