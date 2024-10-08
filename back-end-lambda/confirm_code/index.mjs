import AWS from 'aws-sdk';
const cognito = new AWS.CognitoIdentityServiceProvider();


export const handler = async (event) => {
  try{
    const requestBody = await JSON.parse(event.body);
    // Destructuring assignment
    const { email, confirmationCode } = requestBody;
    
    
    const params = {
      ClientId:"1f1fkq68uintemgfmmco3lrpii",   //would be identified later using terraform outputs
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
