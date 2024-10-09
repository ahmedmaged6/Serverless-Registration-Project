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
  const {email,password} = requestBody;
  
  const params = {
    AuthFlow: "USER_PASSWORD_AUTH", 
    ClientId:clientId,   // Use Client ID retrieved from S3
    AuthParameters:{
      "USERNAME":email,
      "PASSWORD":password
    }
  };

    const response = await cognito.initiateAuth(params).promise();
    
    return {
      statusCode: 201,
      headers: {
        "Access-Control-Allow-Origin": "*",  
        "Access-Control-Allow-Methods": "OPTIONS, POST",
        "Access-Control-Allow-Headers": "Content-Type"},
      body: JSON.stringify({
          message: 'User logged in successfully',
          data: response['AuthenticationResult']
      })
    };
  }
  catch(error){
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",  
        "Access-Control-Allow-Methods": "OPTIONS, POST",
        "Access-Control-Allow-Headers": "Content-Type"},
      body: JSON.stringify({
          message: 'Login failed',
          error: error.message
        })
      };
  }
};