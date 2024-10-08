import AWS from 'aws-sdk';
const cognito = new AWS.CognitoIdentityServiceProvider();


export const handler = async (event) => {

    const authHeader = event.headers.Authorization;
    console.log(authHeader);
    
    if (!authHeader) {
        return {
            statusCode: 401,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS, GET",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            body: 'Authorization header missing'
        };
    }

    const accessToken = authHeader.split(" ")[1];
    console.log(accessToken);
    
    try{
        const response = await cognito.getUser({ AccessToken: accessToken }).promise();
        const userAttributes = response.UserAttributes.reduce((acc, attr) => {
            acc[attr.Name] = attr.Value;
            return acc;
        }, {});

        const firstName = userAttributes.given_name || 'FirstName';
        const secondName = userAttributes.family_name || 'SecondName';
        const email = userAttributes.email || 'Email';
      
      return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS, GET",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            body: JSON.stringify({
                firstName: firstName,
                secondName: secondName,
                email: email
            })
        };
    } catch(error){
    return {
      statusCode: 500,
      headers: {
       "Access-Control-Allow-Origin": "*",  
       "Access-Control-Allow-Methods": "OPTIONS, GET",
       "Access-Control-Allow-Headers": "Content-Type"},
      body: JSON.stringify({
          message: 'Profile failed',
          error: error.message
        })
      };
  }
};