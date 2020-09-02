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
# This works, but requires a targeted apply :(  not really good enough.
#
# This is also pretty odd.  What it's doing, is foreach is creating an a set of objects {} and assinging these
# to each.value.  The inner for loop is looping over each domain_validation_options and for each one, creating a
# map of name, record and type..
#
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.myapp.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id  = data.aws_route53_zone.public.id
  ttl      = 60
  provider = aws.account_route53
}

# This tells terraform to cause the route53 validation to happen
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.myapp.arn
  validation_record_fqdns = [ for record in aws_route53_record.cert_validation : record.fqdn ]
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
