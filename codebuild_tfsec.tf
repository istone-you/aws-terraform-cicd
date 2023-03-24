resource "aws_codebuild_project" "project_tfsec" {
  name          = "tfsec-project"
  description   = "Analyze the code for vulnerabilities using tfsec."
  service_role  = aws_iam_role.role_tfsec.arn
  build_timeout = 60

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
      version: 0.2
      env:
        exported-variables:
          - BuildID
          - BuildTag
      phases:
        pre_build:
          commands:
            - "echo Executing tfsec"
            - "mkdir -p reports/tfsec/"
        build:
          commands:
            - "tfsec -s . --format junit > reports/tfsec/report.xml"
        post_build:
          commands:
            - "export BuildID=`echo $CODEBUILD_BUILD_ID | cut -d: -f1`"
            - "export BuildTag=`echo $CODEBUILD_BUILD_ID | cut -d: -f2`"
      reports:
        reports:
          files:
            - "reports/tfsec/report.xml"
          file-format: JUNITXML
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
    image                       = "aquasec/tfsec:latest"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false

    environment_variable {
      name  = "access_key"
      type  = "PARAMETER_STORE"
      value = "access_key"
    }

    environment_variable {
      name  = "secret_key"
      type  = "PARAMETER_STORE"
      value = "secret_key"
    }
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