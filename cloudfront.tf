locals {
  cloudfront_origin_name = (var.cloudfront_origin_name != "" ? var.cloudfront_origin_name : aws_s3_bucket.s3_bucket.bucket_regional_domain_name)
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id                = local.cloudfront_origin_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn_oac.id
    origin_path              = var.cloudfront_origin_path
  }

  enabled         = true
  is_ipv6_enabled = true
  aliases         = var.custom_domain_name != "" ? [var.custom_domain_name] : []

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.cloudfront_origin_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.whitelisted_locations
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = var.should_create_custom_domain ? false : true
    acm_certificate_arn            = try(aws_acm_certificate.cert[0].arn, null)
    ssl_support_method             = var.should_create_custom_domain ? "sni-only" : null
  }

  tags = var.tags
}

resource "aws_cloudfront_origin_access_control" "cdn_oac" {
  name                              = local.cloudfront_origin_name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
