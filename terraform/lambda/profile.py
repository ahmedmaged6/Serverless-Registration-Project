import json
import boto3

def lambda_handler(event, context):
    auth_header = event['headers'].get('Authorization')
    print(auth_header)
    if not auth_header:
        return {
            'statusCode': 401,
            'body': 'Authorization header missing'
        }

    access_token = auth_header.split(" ")[1]
    
    print(access_token)

    client = boto3.client('cognito-idp')

    try:
        response = client.get_user(
            AccessToken=access_token
        )
        user_attributes = {attr['Name']: attr['Value'] for attr in response['UserAttributes']}
        first_name = user_attributes.get('given_name', 'FirstName')
        second_name = user_attributes.get('family_name', 'SecondName')
        email = user_attributes.get('email', 'Email')

        return {
            'statusCode': 200,
             'headers': {
                    "Access-Control-Allow-Origin": "*",  
                    "Access-Control-Allow-Methods": "OPTIONS, POST",
                    "Access-Control-Allow-Headers": "Content-Type"  
                },
            'body': json.dumps({
                'firstName': first_name,
                'secondName': second_name,
                'email': email
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
                'message': 'Error fetching user details',
                'error': str(e)
            })
        }
