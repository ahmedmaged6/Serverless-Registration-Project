import AWS from 'aws-sdk';
const cognito = new AWS.CognitoIdentityServiceProvider();
const s3 = new AWS.S3();

export const handler = async (event) => {
  const bucketName = 'lambda-zipped-for-serverless-web'; 
  const objectKey = 'client_id.txt'; 

  try {
    // Fetch the client ID from S3
    const paramsS3 = {
      Bucket: bucketName,
      Key: objectKey
    };
    const s3Response = await s3.getObject(paramsS3).promise();
    const clientId = s3Response.Body.toString('utf-8');
    
    // Parse the request body
    const requestBody = await JSON.parse(event.body);
    
  // Destructuring assignment
    const { firstName, secondName, email, password } = requestBody;
    
    // Set Cognito signup parameters
    const paramsCognito = {
      ClientId: clientId,  // Use Client ID retrieved from S3
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: "email", Value: email },
        { Name: "given_name", Value: firstName },
        { Name: "family_name", Value: secondName }
      ]
    };

    // Sign up the user in Cognito
    const response = await cognito.signUp(paramsCognito).promise();
    
    return {
      statusCode: 201,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS, POST",
        "Access-Control-Allow-Headers": "Content-Type"
      },
      body: JSON.stringify({
        message: 'User signed up successfully',
        data: response
      })
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS, POST",
        "Access-Control-Allow-Headers": "Content-Type"
      },
      body: JSON.stringify({
        message: 'Signup failed',
        error: error.message
      })
    };
  }
};
