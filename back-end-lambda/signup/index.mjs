import AWS from 'aws-sdk';
const cognito = new AWS.CognitoIdentityServiceProvider();


export const handler = async (event) => {

  const requestBody = await JSON.parse(event.body);
  
  // Destructuring assignment
  const { firstName, secondName, email, password } = requestBody;
  
  const params = {
    ClientId:"1f1fkq68uintemgfmmco3lrpii",   //This Would be passed in the future after Cognito Resource Imnmplementation
    Username:email,
    Password:password,
    UserAttributes:[
      {Name:"email",Value:email},
      {Name:"given_name",Value:firstName},
      {Name:"family_name",Value:secondName}
    ]
  };

  try{
    const response = await cognito.signUp(params).promise();
    
    return {
      statusCode: 201,
      headers: {
       "Access-Control-Allow-Origin": "*",  
       "Access-Control-Allow-Methods": "OPTIONS, POST",
       "Access-Control-Allow-Headers": "Content-Type"},
      body: JSON.stringify({
          message: 'User signed up successfully',
          data: response
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
          message: 'Signup failed',
          error: error.message
        })
      };
  }
};