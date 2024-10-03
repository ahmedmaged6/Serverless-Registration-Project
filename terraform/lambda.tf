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

data "aws_iam_policy_document" "lambda_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/*:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = "lambda_logging_policy"
  policy = data.aws_iam_policy_document.lambda_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}


/*
variable "api_paths" {
  type    = list(string)
  default = ["signup", "login", "profile", "confirm_code"]
}

  for_each    = toset(var.api_paths)

  each.value
*/
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
