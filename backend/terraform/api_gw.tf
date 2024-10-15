
# Terraform and CORS-Enabled AWS API Gateway:-
    # Step 1: Creation of Rest API
    # Step 2: Creation of Resources in API
    # Step 3: Creation of Methods in Resources
    # Step 4: Creation of Deployment


# Step 1: Creation of Rest API
resource "aws_api_gateway_rest_api" "MyServerlessAPI" {
  name        = "ServerlessRegistrationAPI"
  description = "This is API is kolo kher"
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
  depends_on = [aws_lambda_function.lambda["signup"]]
}


# Step 3: Creation of Methods in Resources

# 1-Creation of OPTIONS Method Request
resource "aws_api_gateway_method" "options_method_request" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
    depends_on = [aws_api_gateway_resource.api_resources]
}

# 2-Creation of OPTIONS Integration Request
resource "aws_api_gateway_integration" "options_integration_request" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method = "OPTIONS"
    type          = "MOCK"
    depends_on = [aws_api_gateway_method.options_method_request]
    request_templates={
        "application/json" = <<EOF
{"statusCode" : 200}
EOF
    }
}

# 3-Creation of OPTIONS Method Response
resource "aws_api_gateway_method_response" "options_method_response" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method   = "OPTIONS"
    status_code   = "200"
    response_models = {
        "application/json" = "Empty"
    }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_integration.options_integration_request]
}

# 4-Creation of OPTIONS Integration Response
resource "aws_api_gateway_integration_response" "options_integration_response" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method   = "OPTIONS"
    status_code   = "200"
response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
}

    depends_on = [aws_api_gateway_method_response.options_method_response]
}


# 1-Creation of POST Method Request
resource "aws_api_gateway_method" "post_method_request" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method   = each.value=="profile"?"GET":"POST"
    authorization = "NONE"
}


# 2-Creation of POST Method Response
resource "aws_api_gateway_method_response" "post_method_response" {
    for_each    = toset(var.api_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method   = "${aws_api_gateway_method.post_method_request[each.value].http_method}"
    status_code   = "200"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Origin" = true,
        "method.response.header.Content-Type" = true,
        "method.response.header.Access-Control-Allow-Methods" = true
        "method.response.header.Content-Type" = true

    }
    response_models = {
        "application/json" = "Empty"
    }
    depends_on = [aws_api_gateway_integration.post_integration_request]
}



# 3-Creation of POST Integration Request 
resource "aws_api_gateway_integration" "post_integration_request" {
    for_each    = toset(var.post_paths)

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources[each.value].id}"
    http_method="POST"  
    integration_http_method ="POST"
    type          = "AWS_PROXY"
    uri           =  "${aws_lambda_function.lambda[each.value].invoke_arn}"
    depends_on    = [aws_lambda_function.lambda]
}

# 4-Creation of GET Integration Request 
resource "aws_api_gateway_integration" "get_integration_request" {

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    resource_id   = "${aws_api_gateway_resource.api_resources["profile"].id}"
    http_method   = "GET"
    integration_http_method ="POST"   #very important step
    type          = "AWS_PROXY"
    uri           =  "${aws_lambda_function.lambda["profile"].invoke_arn}"
    depends_on    = [aws_lambda_function.lambda]
}


# Step 4: Creation of Deployment
resource "aws_api_gateway_deployment" "deployment" {

    rest_api_id   = "${aws_api_gateway_rest_api.MyServerlessAPI.id}"
    stage_name    = "Production"
    depends_on = [
    aws_api_gateway_integration.post_integration_request,
    aws_api_gateway_method_response.post_method_response,
    aws_api_gateway_integration_response.options_integration_response,
    aws_api_gateway_method_response.options_method_response ,
    aws_lambda_permission.apigw_invoke
]

}
