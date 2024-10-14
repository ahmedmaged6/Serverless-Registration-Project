output "cognito_clientID" {
  value = aws_cognito_user_pool_client.app_client_1.id
  description = "cognito client id"
}

output "api_id" {
  value = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
}



