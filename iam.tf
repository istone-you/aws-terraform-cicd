

# CodeBuild(tfsec)'s IAM

resource "aws_iam_policy" "policy_tfsec" {
  name = "build-tfsec-project-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "BuildLogs"
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Sid    = "BuildReports"
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:report-group/tfsec-project-reports"
      },
      {
        Sid    = "KmsKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          aws_kms_key.key_s3_artifact.arn
        ]
      },
      {
        Sid    = "S3Artifact"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.bucket_artifacts.arn,
          "${aws_s3_bucket.bucket_artifacts.arn}/*"
        ]
      },
      {
        "Sid" : "SSMParameter",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "role_tfsec" {
  name = "build-tfsec-project-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]

  })

  managed_policy_arns = [aws_iam_policy.policy_tfsec.arn]

  tags = {
    Name = "build-tfsec-project-role"
  }
}

# CodeBuild(terraform)'s IAM

resource "aws_iam_role" "role_terraform" {
  name = "build-terraform-project-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"

        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]

  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  tags = {
    Name = "build-terraform-project-role"
  }
}

#CodePipeline's IAM

resource "aws_iam_policy" "policy_tf_pipeline" {
  name = "tf-pipeline-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Artifact"
        Effect = "Allow"
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:DeleteObject*",
          "s3:PutObject",
          "s3:Abort*"
        ]
        Resource = [
          aws_s3_bucket.bucket_artifacts.arn,
          "${aws_s3_bucket.bucket_artifacts.arn}/*"
        ]
      },
      {
        Sid    = "KmsKey"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ]
        Resource = aws_kms_key.key_s3_artifact.arn
      },
      {
        Sid    = "CodeBuildProjects"
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ]
        Resource = [
          aws_codebuild_project.project_tfsec.arn,
          aws_codebuild_project.project_terraform.arn
        ]
      },
      {
        Sid    = "CodeStar"
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "role_tf_pipeline" {
  name = "tf-pipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.policy_tf_pipeline.arn]

  tags = {
    Name = "tf-pipeline-role"
  }
}