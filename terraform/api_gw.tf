# Terraform and CORS-Enabled AWS API Gateway:-
    # Step 1: Creation of Rest API
    # Step 2: Creation of Resources in API
    # Step 3: Creation of Methods in Resources
    # Step 4: Creation of Deployment



# Step 1: Creation of Rest API
resource "aws_api_gateway_rest_api" "MyServerlessAPI" {
  name        = "ServerlessRegistrationAPI"
  description = "This is API for Serverless Registration"
    endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Step 2: Creation of Resources in API

# Note: we need to create 4 resources (/singup /login  /profile /confirm_code)

# Create the resources dynamically using for_each
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = toset(var.api_paths)
  rest_api_id = aws_api_gateway_rest_api.MyServerlessAPI.id
  parent_id   = aws_api_gateway_rest_api.MyServerlessAPI.root_resource_id
  path_part   = each.value
  depends_on = [aws_lambda_function.signup_lambda]
}


# Step 3: Creation of Methods in Resources

# 1-Creation of OPTIONS Method
resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}

# 2-Creation of OPTIONS Method Response
resource "aws_api_gateway_method_response" "options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.options_method]
}

# 3-Creation of OPTIONS Integration Request
resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    type          = "MOCK"
    depends_on = [aws_api_gateway_method.options_method]
    request_templates={
        "application/json" = <<EOF
{"statusCode" : 200}
EOF
    }
}
# 4-Creation of OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [aws_api_gateway_method_response.options_200]
}



# 1-Creation of POST Method
resource "aws_api_gateway_method" "post_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "POST"
    authorization = "NONE"
}

# 2-Creation of POST Method Response
resource "aws_api_gateway_method_response" "post_method_response_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "${aws_api_gateway_method.post_method.http_method}"
    status_code   = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    response_models = {
        "application/json" = "Empty"
    }
    depends_on = [aws_api_gateway_method.post_method]
}



# 3-Creation of POST Integration Request 
resource "aws_api_gateway_integration" "post_integration_request" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
    http_method   = "${aws_api_gateway_method.post_method.http_method}"
    integration_http_method = "POST"
    type          = "AWS"
    uri           =  "${aws_lambda_function.signup_lambda.invoke_arn}"
    depends_on    = [aws_api_gateway_method.post_method,aws_lambda_function.signup_lambda]
}

# 4-Creation of POST Integration Response 
resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.MyServerlessAPI.id
  resource_id   = "${aws_api_gateway_resource.api_resources["signup"].id}"
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [aws_api_gateway_integration.post_integration_request]
}

# Step 4: Creation of Deployment
resource "aws_api_gateway_deployment" "deployment" {
    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    stage_name    = "Prod"
  depends_on = [
    aws_api_gateway_integration.post_integration_request,
    aws_lambda_function.signup_lambda,
    aws_api_gateway_method.post_method,
    aws_api_gateway_method.options_method,
  ]
}
output "signup_post_url" {
  value = "https://${aws_api_gateway_rest_api.MyServerlessAPI.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_deployment.deployment.stage_name}/signup"
  description = "The URL for the POST method of the /signup resource."
}
