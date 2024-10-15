import json
import boto3

# Initialize AWS Cognito client
cognito = boto3.client('cognito-idp')

def lambda_handler(event, context):
    # Get the Authorization header
    auth_header = event['headers'].get('Authorization')
    print(auth_header)
    
    if not auth_header:
        return {
            'statusCode': 401,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': 'Authorization header missing'
        }

    # Extract the Access Token from the header
    access_token = auth_header.split(" ")[1]
    print(access_token)

    try:
        # Get user details from Cognito using the access token
        response = cognito.get_user(AccessToken=access_token)
        
        # Reduce UserAttributes into a dictionary
        user_attributes = {attr['Name']: attr['Value'] for attr in response['UserAttributes']}

        # Set default values for missing attributes
        first_name = user_attributes.get('given_name', 'FirstName')
        second_name = user_attributes.get('family_name', 'SecondName')
        email = user_attributes.get('email', 'Email')

        # Return the user information
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'firstName': first_name,
                'secondName': second_name,
                'email': email
            })
        }

    except Exception as error:
        # Handle any errors during the getUser call
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'message': 'Profile failed',
                'error': str(error)
            })
        }
