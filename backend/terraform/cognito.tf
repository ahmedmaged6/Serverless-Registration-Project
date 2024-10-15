
# Define a Cognito User Pool for managing user authentication
resource "aws_cognito_user_pool" "pool" {
  name = "ServerlessPool"  # The name of the user pool

  # Specify that the username will be the user's email address
  username_attributes = ["email"]

  # Automatically verify email addresses upon user registration
  auto_verified_attributes = ["email"]

  # Custom verification message template for email verification
  verification_message_template {
    email_message = "Your verification code is {####}"  # Message sent to users
    email_subject = "Verify your email"  # Subject line for the verification email
  }
}

# Define a Cognito User Pool Client to allow applications to interact with the user pool
resource "aws_cognito_user_pool_client" "app_client_1" {
  name                = "app-client-1"  # Name of the application client
  user_pool_id       = aws_cognito_user_pool.pool.id  # Link to the user pool

  # Specify the allowed OAuth flows for this client
  allowed_oauth_flows = ["code"]  

  # Define the OAuth scopes that the client can request
  allowed_oauth_scopes = ["email", "openid", "profile"]

  # Specify callback URLs for successful authentication
  callback_urls = [
    "http://localhost:5500/front-end/profile.html"  # Redirect URL after authentication
  ]

  # Enable explicit authentication flows for the client
  explicit_auth_flows = ["USER_PASSWORD_AUTH"]  # Authentication method

  depends_on = [ aws_cognito_user_pool.pool ]
}

