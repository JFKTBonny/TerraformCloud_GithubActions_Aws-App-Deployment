variable "domain" {
  description = "Domain Name for generating the SSL Cert"
  type        = string
}

variable "zone_id" {
  description = "Hosted Zone ID of AWS"
  type        = string
}

variable "environment" {
  description = "Environment to deploy"
  type        = string
}

variable "org_name" {
  description = "Name of Organisation"
  type        = string
}

