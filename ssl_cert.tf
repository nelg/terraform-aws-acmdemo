# This data source looks up the public DNS zone
data "aws_route53_zone" "public" {
  name         = var.demo_dns_zone
  private_zone = false
  provider     = aws.account_route53
}

# This creates an SSL certificate
resource "aws_acm_certificate" "myapp" {
  domain_name       = aws_route53_record.myapp.fqdn
  validation_method = "DNS"
}

# This is a DNS record for the ACM certificate validation to prove we own the domain
resource "aws_route53_record" "cert_validation" {
  name     = aws_acm_certificate.myapp.domain_validation_options.0.resource_record_name
  type     = aws_acm_certificate.myapp.domain_validation_options.0.resource_record_type
  zone_id  = data.aws_route53_zone.public.id
  records  = [aws_acm_certificate.myapp.domain_validation_options.0.resource_record_value]
  ttl      = 60
  provider = aws.account_route53
}

# This tells terraform to cause the route53 validation to happen
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.myapp.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

# Standard route53 DNS record for "myapp" pointing to an ALB
resource "aws_route53_record" "myapp" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.demo_dns_name}.${data.aws_route53_zone.public.name}"
  type    = "A"
  alias {
    name                   = aws_alb.mylb.dns_name
    zone_id                = aws_alb.mylb.zone_id
    evaluate_target_health = false
  }
  provider = aws.account_route53
}

output "testing" {
  value = "Test this demo code by going to https://${aws_route53_record.myapp.fqdn} and checking your have a valid SSL cert"
}
