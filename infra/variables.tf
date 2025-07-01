// Add only Variables that'll be used Globally across all modules
// Adding default values to environment and region to assist developers will testing in development environment

variable "environment" {
  description = "The Deployment environment"
  type        = string
  default     = "dev"
}

variable "domain" {
  description = "The FQDN domain"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "org_name" {
  description = "Name of Organisation"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL Database"
  type        = string
}

variable "db_user_name" {
  description = "Name of User for Accessing PGQSL Database"
  type        = string
}

variable "clustername" {
  description = "Cluster Name"
  type        = string
  default = "jfktbonny-us-east-1-dev"
}

variable "zone_id" {
  default = "Z086982133XZDQQ52UFW5"
}