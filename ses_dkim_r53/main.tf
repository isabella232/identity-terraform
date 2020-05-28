# -- Variables --

variable "domain" {
  description = "Name of the owned/managed domain."
  type        = string
  default     = "example.com"
}

variable "zone_id" {
  description = "ID for the Route53 zone where the domain exists."
  type        = string
  default     = "ABCDEFGHIJ123"
}

variable "ttl_verification_record" {
  description = "TTL value for the SES verification TXT record."
  type        = string
  default     = "1800"
}

variable "ttl_dkim_records" {
  description = "TTL value for the SES DKIM records."
  type        = string
  default     = "1800"
}

variable "create_token" {
  description = <<EOM
Whether or not to create a primary_verification_record in Route53.
Set to FALSE if this TXT record has been created with multiple entries.
EOM
  type        = bool
  default     = true
}

# -- Resources --

resource "aws_ses_domain_identity" "primary" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "primary" {
  domain = aws_ses_domain_identity.primary.domain
}

resource "aws_route53_record" "primary_verification_record" {
  count   = var.create_token ? 1 : 0
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = var.ttl_verification_record
  records = ["${aws_ses_domain_identity.primary.verification_token}"]
}

resource "aws_route53_record" "primary_ses_dkim" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.primary.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = var.ttl_dkim_records
  records = ["${element(aws_ses_domain_dkim.primary.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
