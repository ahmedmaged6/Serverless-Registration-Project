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
                aws_s3_bucket.lambda_zipped.arn,
                "${aws_s3_bucket.lambda_zipped.arn}/*"    ]
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


data "archive_file" "lambda_zip_file" {
  for_each    = toset(var.lambda_names)
  type        = "zip"
  source_dir   = "${path.module}/../lambda_src_code/${each.value}"
  output_path = "../temp/lambda_src_zipped/${each.value}_payload.zip"
}


resource "aws_s3_bucket" "lambda_zipped" {
    bucket = var.lambda_zipped_bucket
    depends_on = [ aws_cognito_user_pool_client.app_client_1 ]
}


resource "aws_s3_object" "object" {
  for_each = toset(var.lambda_names)
  bucket = aws_s3_bucket.lambda_zipped.id
  key    = "${each.value}.zip"
  source = "${path.module}/../temp/lambda_src_zipped/${each.value}_payload.zip"
  
  depends_on = [aws_s3_bucket.lambda_zipped]
  

}


resource "aws_s3_object" "client_id_file" {
  bucket = aws_s3_bucket.lambda_zipped.id
  key    = "client_id.txt"
  content = aws_cognito_user_pool_client.app_client_1.id

  depends_on = [aws_s3_bucket.lambda_zipped,aws_s3_object.object]
}


# SignUp Lambda
resource "aws_lambda_function" "lambda" {
  for_each         = toset(var.lambda_names)
  s3_bucket = aws_s3_bucket.lambda_zipped.id
  s3_key = aws_s3_object.object[each.value].key
  function_name    = "${each.value}_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "${each.value}.lambda_handler"
  runtime          = "python3.9"
  depends_on       = [aws_iam_role.iam_for_lambda]
    environment {
    variables = {
      BUCKET_NAME = var.lambda_zipped_bucket
    }
  }
}


resource "aws_lambda_permission" "apigw_invoke" {
  for_each      = toset(var.lambda_names)
  statement_id  = "${each.value}_AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda[each.value].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyServerlessAPI.execution_arn}/*"
}

