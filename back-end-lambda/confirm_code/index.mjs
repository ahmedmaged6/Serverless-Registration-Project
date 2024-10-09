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
  const { email, confirmationCode } = requestBody;
    
    
    const params = {
      ClientId:clientId,   // Use Client ID retrieved from S3
      Username:email,
      ConfirmationCode:confirmationCode
    };
  
    const response = await cognito.confirmSignUp(params).promise();

    return {
      statusCode: 201,
      headers: {
        "Access-Control-Allow-Origin": "*",  
        "Access-Control-Allow-Methods": "OPTIONS, POST",
        "Access-Control-Allow-Headers": "Content-Type"},
      body: JSON.stringify({
          message: 'User Has Been Confirmed',
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
          message: 'Confirmation Failed',
          error: error.message
        })
      };
  }
};
