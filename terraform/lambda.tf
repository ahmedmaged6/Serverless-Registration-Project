                            #Lambda Implementation

#IAM Execution Role for all lambda functions
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# SignUp Lambda
data "archive_file" "signup_lambda_zip_file" {
  type        = "zip"
  source_file = "lambda/signup.py"
  output_path = "lambda_zipped/signup_payload.zip"
}

resource "aws_lambda_function" "signup_lambda" {
  filename      = "${path.module}/lambda_zipped/signup_payload.zip"
  function_name = "signup_lambda"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "signup.lambda_handler"
  source_code_hash = data.archive_file.signup_lambda_zip_file.output_base64sha256
  runtime = "python3.12"
  depends_on = [ aws_iam_role.iam_for_lambda ]
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.signup_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyServerlessAPI.execution_arn}/*/*"
}


/*

# ConfirmationCode Lambda
data "archive_file" "confirmation_code_zip_file" {
  type        = "zip"
  source_file = "lambda/confirmation_code.py"
  output_path = "lambda_zipped/confirmation_code_payload.zip"
}

resource "aws_lambda_function" "confirm_lambda" {
  filename      = "${path.module}/lambda_zipped/confirmation_code_payload.zip"
  function_name = "confirmation_code_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "confirmation_code.lambda_handler"
  source_code_hash = data.archive_file.confirmation_code_zip_file.output_base64sha256
  runtime = "python3.12"
}


# Login Lambda
data "archive_file" "login_lambda_zip_file" {
  type        = "zip"
  source_file = "lambda/login.py"
  output_path = "lambda_zipped/login_payload.zip"
}

resource "aws_lambda_function" "login_lambda" {
  filename      = "${path.module}/lambda_zipped/login_payload.zip"
  function_name = "login_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "login.lambda_handler"
  source_code_hash = data.archive_file.login_lambda_zip_file.output_base64sha256
  runtime = "python3.12"
}

# Profile Lambda
data "archive_file" "profile_lambda_zip_file" {
  type        = "zip"
  source_file = "lambda/profile.py"
  output_path = "lambda_zipped/profile_payload.zip"
}

resource "aws_lambda_function" "profile_lambda" {
  filename      = "${path.module}/lambda_zipped/profile_payload.zip"
  function_name = "profile_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "profile.lambda_handler"
  source_code_hash = data.archive_file.profile_lambda_zip_file.output_base64sha256
  runtime = "python3.12"
}

*/