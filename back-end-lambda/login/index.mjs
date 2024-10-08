import AWS from 'aws-sdk';
const cognito = new AWS.CognitoIdentityServiceProvider();


export const handler = async (event) => {

  const requestBody = await JSON.parse(event.body);
  
  // Destructuring assignment
  const {email,password} = requestBody;
  
  const params = {
    AuthFlow: "USER_PASSWORD_AUTH", // Specify the AuthFlow
    ClientId:"1f1fkq68uintemgfmmco3lrpii",   //This Would be passed in the future after Cognito Resource Imnmplementation
    AuthParameters:{
      "USERNAME":email,
      "PASSWORD":password
    }
  };

  try{
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