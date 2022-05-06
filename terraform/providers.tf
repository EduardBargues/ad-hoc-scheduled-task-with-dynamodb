provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      RepositoryUrl = "https://github.com/EduardBargues/ad-hoc-scheduled-task-with-dynamodb"
    }
  }
}
