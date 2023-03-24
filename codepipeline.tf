
resource "aws_codepipeline" "tf_pipeline" {
  name     = "tf-pipeline"
  role_arn = aws_iam_role.role_tf_pipeline.arn

  artifact_store {
    location = aws_s3_bucket.bucket_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.aws-terraform-cicd.arn
        BranchName       = "master"
        FullRepositoryId = var.github_repo
      }
      region    = var.aws_region
      namespace = "SourceVariables"
      run_order = 1
    }
  }

  stage {
    name = "Tfsec"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.project_tfsec.name
      }
      region    = var.aws_region
      namespace = "TFSEC"
      run_order = 1
    }
  }

  stage {
    name = "Terraform"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceArtifact"]
      configuration = {
        ProjectName = aws_codebuild_project.project_terraform.name
      }
      region    = var.aws_region
      namespace = "TERRAFORM"
      run_order = 1
    }
  }
}




resource "aws_codestarconnections_connection" "aws-terraform-cicd" {
  name          = "aws-terraform-cicd"
  provider_type = "GitHub"
}