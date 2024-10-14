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
  name               = "iam_for_lambdaa"
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
  name   = "lambda_log_policyyy"
  policy = data.aws_iam_policy_document.lambda_logging_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}


data "aws_iam_policy_document" "lambda_access_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
                "s3:GetObject",
                "s3:ListBucket"
    ]
    resources = [
                "arn:aws:s3:::lambda-zipped-for-serverless-web",
                "arn:aws:s3:::lambda-zipped-for-serverless-web/*"    ]
  }
}

resource "aws_iam_policy" "lambda_access_s3_policy" {
  name   = "lambda_access_s3_policyyy"
  policy = data.aws_iam_policy_document.lambda_access_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_access_s3_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_access_s3_policy.arn
}


# SignUp Lambda
resource "aws_lambda_function" "lambda" {
  for_each         = toset(var.lambda_names)
  s3_bucket = aws_s3_bucket.lambda_zipped.id
  s3_key = aws_s3_object.object[each.value].key
  function_name    = "${each.value}_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  depends_on       = [aws_iam_role.iam_for_lambda]
}



resource "aws_lambda_permission" "apigw_invoke" {
  for_each      = toset(var.lambda_names)
  statement_id  = "${each.value}_AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.value].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyServerlessAPI.execution_arn}/*"
}

