output "cloudfront_distribution_url" {
  description = "The URL for the CloudFront distribution."
  value       = try(aws_route53_record.cdn_subdomain_record[0].fqdn, aws_cloudfront_distribution.cdn.domain_name)
}
