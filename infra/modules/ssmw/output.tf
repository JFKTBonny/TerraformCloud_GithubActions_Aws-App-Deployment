output "ssm-arn" {
  value = aws_ssm_parameter.password_parameter.arn
}