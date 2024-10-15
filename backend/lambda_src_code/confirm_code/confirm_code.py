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

        # Destructuring assignment
        email = request_body['email']
        confirmation_code = request_body['confirmationCode']

        # Prepare parameters for Cognito confirmation
        params = {
            'ClientId': client_id,   # Use Client ID retrieved from S3
            'Username': email,
            'ConfirmationCode': confirmation_code
        }

        # Confirm sign-up with Cognito
        cognito.confirm_sign_up(**params)

        return {
            'statusCode': 201,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS, POST',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({'message': 'User Has Been Confirmed'})
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
                'message': 'Confirmation Failed',
                'error': str(error)
            })
        }
