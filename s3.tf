resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = jsonencode({
    "Version" : "2008-10-17",
    "Id" : "PolicyForCloudFrontPrivateContent",
    "Statement" : [
      {
        "Sid" : "AllowCloudFrontServicePrincipal",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudfront.amazonaws.com"
        },
        "Action" : "s3:GetObject",
        "Resource" : "${aws_s3_bucket.s3_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "AWS:SourceArn" : aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "s3_objects" {
  bucket = aws_s3_bucket.s3_bucket.id

  for_each = fileset("${path.module}/objects", "**")
  key      = each.value
  source   = "${path.module}/objects/${each.value}"
  etag     = filemd5("${path.module}/objects/${each.value}")

  tags = var.tags
}
