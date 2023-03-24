resource "aws_ssm_parameter" "github_token" {
  name  = "github_token"
  type  = "SecureString"
  value = var.github_token
}

resource "aws_ssm_parameter" "github_owner" {
  name  = "github_owner"
  type  = "SecureString"
  value = var.github_owner
}

resource "aws_ssm_parameter" "access_key" {
  name  = "access_key"
  type  = "SecureString"
  value = var.access_key
}

resource "aws_ssm_parameter" "secret_key" {
  name  = "secret_key"
  type  = "SecureString"
  value = var.secret_key
}