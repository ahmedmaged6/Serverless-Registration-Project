
data "archive_file" "lambda_zip_file" {
  for_each    = toset(var.lambda_names)
  type        = "zip"
  source_dir   = "${path.module}/../back-end-lambda/${each.value}"
  output_path = "lambda_zipped/${each.value}_payload.zip"
}


resource "aws_s3_bucket" "lambda_zipped" {
    bucket = "lambda-zipped-for-serverless-web"
    depends_on = [ aws_cognito_user_pool_client.app_client_1 ]
}


resource "aws_s3_object" "object" {
  for_each = toset(var.lambda_names)
  bucket = aws_s3_bucket.lambda_zipped.id
  key    = "${each.value}.zip"
  source = "${path.module}/lambda_zipped/${each.value}_payload.zip"
  depends_on = [aws_s3_bucket.lambda_zipped]

}


resource "aws_s3_object" "client_id_file" {
  bucket = aws_s3_bucket.lambda_zipped.id
  key    = "client_id.txt"
  content = aws_cognito_user_pool_client.app_client_1.id
  depends_on = [aws_s3_bucket.lambda_zipped]
}