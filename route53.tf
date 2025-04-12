locals {
  subdomain_ttl = 60
  zone_id = try(
    data.aws_route53_zone.existing_zone[0].zone_id,
    try(aws_route53_zone.hosted_zone[0].id, null)
  )
}

data "aws_route53_zone" "existing_zone" {
  count = var.should_create_custom_domain ? 1 : 0
  name  = var.custom_domain_name
}

resource "aws_route53_zone" "hosted_zone" {
  count = var.should_create_custom_domain && length(try(data.aws_route53_zone.existing_zone, [])) == 0 ? 1 : 0

  name = var.custom_domain_name
  tags = var.tags
}

resource "aws_route53_record" "cdn_subdomain_record" {
  count = var.should_create_custom_domain ? 1 : 0

  zone_id         = local.zone_id
  name            = "${var.cdn_subdomain}.${var.custom_domain_name}"
  type            = "CNAME"
  records         = [aws_cloudfront_distribution.cdn.domain_name]
  ttl             = local.subdomain_ttl
  allow_overwrite = true
}

### ACM Certificate

resource "aws_acm_certificate" "cert" {
  count = var.should_create_custom_domain ? 1 : 0

  domain_name               = var.custom_domain_name
  subject_alternative_names = ["*.${var.custom_domain_name}"]
  validation_method         = "DNS"
  tags                      = var.tags
}

resource "aws_acm_certificate_validation" "cert_validation" {
  count = var.should_create_custom_domain ? 1 : 0

  certificate_arn         = try(aws_acm_certificate.cert[0].arn, null)
  validation_record_fqdns = [for record in try(aws_route53_record.cert_validation_records, []) : record.fqdn]
}

resource "aws_route53_record" "cert_validation_records" {
  for_each        = try(aws_acm_certificate.cert[0].domain_validation_options, [])
  zone_id         = local.zone_id
  name            = each.value.resource_record_name
  type            = each.value.resource_record_type
  records         = [each.value.resource_record_value]
  ttl             = local.subdomain_ttl
  allow_overwrite = true
}
