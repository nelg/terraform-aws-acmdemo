variable "demo_dns_zone" {
  description = "Specific to your setup, pick a domain you have in route53"
}


variable "demo_dns_name" {
  description = "Just a demo domain name"
  default     = "ssldemo"
}
