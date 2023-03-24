# Terraformで作成する構成
<img width="600" alt="terraform-cicd.drawio.png" src="./terraform-cicd.drawio.png">

TerraformをCICDする構成を作成するTerraformのファイルです。

tfvarsファイルを作成して以下の変数を指定する必要があります。
- aws_region        =  AWSのリージョン
- access_key        =  AWSのアクセスキー
- secret_key        =  AWSのシークレットキー
- github_token      =  GitHubのトークン
- github_owner      =  GitHubのユーザー名
- github_repo =  Terraformのファイルを管理するGitHubのレポジトリ