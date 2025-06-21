# Create an SSM Parameter with provided path and parameter name
resource "aws_ssm_parameter" "password_parameter" {
  name        = "/${var.parameter_path}/${var.parameter_name}"
  description = var.parameter_description
  type        = var.parameter_type
  value       = var.parameter_value
  overwrite   = true
  tags = {
    Name              = "${var.clustername}-ssm-/${var.parameter_path}/${var.parameter_name}"
    Environment       = var.environment
    terraform-managed = "true"
    "${format("kubernetes.io/cluster/%s-%s", var.org_name, var.environment)}" = "owned"
  }
}

