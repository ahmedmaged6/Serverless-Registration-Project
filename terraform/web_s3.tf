/*
resource "aws_s3_bucket" "web_bucket" {
  bucket = var.s3_website_bucket
}


resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.web_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "allow_public_access_policy" {
  bucket = aws_s3_bucket.web_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_internet.json
  depends_on = [ aws_s3_bucket_public_access_block.access_block]
}

data "aws_iam_policy_document" "allow_access_from_internet" {
    statement {

    principals {
        type        = "*"
        identifiers = ["*"]
    }

    actions = [
        "s3:GetObject",
    ]

    resources = [
        "${aws_s3_bucket.web_bucket.arn}/*",
    ]
}
}


resource "aws_s3_object" "file" {
  for_each = toset(var.frontend_paths)
  bucket = aws_s3_bucket.web_bucket.id
  key    = "${each.value}"
  source = "${path.module}/../front-end/${each.value}"
  etag = filemd5("${path.module}/../front-end/${each.value}")
  content_type = each.value=="styles.css"?"text/css":"text/html"
}


resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.web_bucket.id

  index_document {
    suffix = "index.html"
  }

}

output "s3_website_url" {
  value ="${aws_s3_bucket_website_configuration.example.website_endpoint}"  
}
*/