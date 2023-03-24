resource "aws_codebuild_project" "project_terraform" {
  name          = "terraform-project"
  description   = "Analyze the code for vulnerabilities using tfsec."
  service_role  = aws_iam_role.role_terraform.arn
  build_timeout = 60

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
      version: 0.2
      env:
        parameter-store:
          access-key: "access_key"
          secret-key: "secret_key"
          github_token: "github_token"
          github_owner: "github_owner"
      phases:
        install:
          commands:
            - export AWS_ACCESS_KEY_ID="$${access_key}"
            - export AWS_SECRET_ACCESS_KEY="$${secret_key}"
            - export AWS_DEFAULT_REGION="ap-northeast-1"
            - export TF_VAR_github_token="$${github_token}"
            - export TF_VAR_github_owner="$${github_owner}"
        pre_build:
          commands:
            - "cd terraform/"
            - "terraform init -input=false -no-color"
            - "terraform plan -input=false -no-color"
        build:
          commands:
            - "terraform apply -input=false -no-color -auto-approve"
    EOF
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  encryption_key = aws_kms_key.key_s3_artifact.arn

  tags = {
    Name = "tfsec-project"
  }
}