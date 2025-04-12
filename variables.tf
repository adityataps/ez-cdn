variable "region" {
  type        = string
  description = "AWS Region for deployment."
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name."
  default     = ""
}

variable "should_create_custom_domain" {
  type        = bool
  description = "Whether to create a custom domain using Route 53."
  default     = false
}

variable "custom_domain_name" {
  type        = string
  description = "Name of the custom domain name to create, if configured."
  default     = ""
}

variable "cdn_subdomain" {
  type        = string
  description = "Subdomain for the CDN domain name, if configured (e.g. 'cdn.{domain}')."
  default     = "cdn"
}

variable "cloudfront_origin_path" {
  type        = string
  description = "Path to the origin directory on the S3 bucket to distribute with CloudFront."
  default     = ""
}

variable "cloudfront_origin_name" {
  type        = string
  description = "Name of the CloudFront origin."
  default     = ""
}

variable "whitelisted_locations" {
  type        = list(string)
  description = "List of geolocations that are allowed to access the CDN."
  default     = ["US", "CA", "GB", "DE"]
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}
