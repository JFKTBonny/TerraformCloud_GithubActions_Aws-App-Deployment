# Create an ACM Certificate with the provided domain name
# Validate through DNS only
resource "aws_acm_certificate" "default" {
  domain_name       = var.domain
  validation_method = "DNS" # AWS will give you CNAME records to add to your DNS

  lifecycle {
    create_before_destroy = true # Ensures a new certificate is created before destroying the old one during updates (helps with zero-downtime rotation)
  }

  tags = {
    Environment       = var.environment
    terraform-managed = "true"
    "${format("kubernetes.io/cluster/%s-%s", var.org_name, var.environment)}" = "owned"
  }

}

# Update the Route53 Records with the Certificate details for validation
resource "aws_route53_record" "default" {
  for_each = {
    for dvo in aws_acm_certificate.default.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60  # A short TTL helps propagate changes quickly
  type            = each.value.type
  zone_id         = var.zone_id  # Zone ID: Passed in via var.zone_id, this refers to the Route 53 hosted zone for the domain.

}

# Generate Certificate Validation: Tells AWS to validate the certificate, using the DNS records you just created.
resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.default.arn # Links to the ACM certificate created earlier.
  validation_record_fqdns = [for record in aws_route53_record.default : record.fqdn]

  


  depends_on = [aws_route53_record.default]

}

