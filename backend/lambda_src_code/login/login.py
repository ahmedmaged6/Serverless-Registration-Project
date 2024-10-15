import json
import boto3
import os

# Initialize AWS Cognito and S3 clients
cognito = boto3.client('cognito-idp')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # Retrieve bucket name from the environment variable
    bucket_name = os.environ['BUCKET_NAME']
    object_key = 'client_id.txt'

    try:
        # Fetch the client ID from S3
        s3_response = s3.get_object(Bucket=bucket_name, Key=object_key)
        client_id = s3_response['Body'].read().decode('utf-8')

        # Parse the request body
        request_body = json.loads(event['body'])

        # Destructure the request body to get email and password
        email = request_body['email']
        password = request_body['password']

        # Set parameters for Cognito authentication
        params = {
            'AuthFlow': "USER_PASSWORD_AUTH",
            'ClientId': client_id,  # Use Client ID retrieved from S3
            'AuthParameters': {
                'USERNAME': email,
                'PASSWORD': password
            }
        }

        # Initiate authentication in Cognito
        response = cognito.initiate_auth(**params)

        return {
            'statusCode': 201,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, POST',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'message': 'User logged in successfully',
                'data': response['AuthenticationResult']
            })
        }

    except Exception as error:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, POST',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'message': 'Login failed',
                'error': str(error)
            })
        }
