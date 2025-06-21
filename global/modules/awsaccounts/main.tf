# Create an AWS Organisations account with provided name,email and parent ID
# By default create an Administrator Role
resource "aws_organizations_account" "default" {
  name      = var.name                    # The name of the AWS account
  email     = var.email                   # The email for the root user of the account
  parent_id = var.parent_id               # The OU or root under which the account will be created
  role_name = "Administrator"             # IAM Role created in the child account that can be assumed by master account

  lifecycle {
    ignore_changes = [role_name]         # Optional: Prevents Terraform from trying to update this value
  }
}