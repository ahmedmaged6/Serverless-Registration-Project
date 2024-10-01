import json
import boto3

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    first_name = body['firstName']
    second_name = body['secondName']
    email = body['email']
    password = body['password']

    try:
        response = client.sign_up(
            ClientId='1f1fkq68uintemgfmmco3lrpii', #would be identified later using outputs
            Username=email,
            Password=password,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                },
                {
                    'Name': 'given_name',
                    'Value': first_name
                },
                {
                    'Name': 'family_name',
                    'Value': second_name
                }
            ]
        )
        
        return {
            'statusCode': 200,
            'headers': {
                    "Access-Control-Allow-Origin": "*", 
                    "Access-Control-Allow-Methods": "OPTIONS, POST",
                    "Access-Control-Allow-Headers": "Content-Type"  
                },
            'body': json.dumps({
                'message': 'User signed up successfully',
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
                'message': 'Error signing up user',
                'error': str(e)
            })
        }
