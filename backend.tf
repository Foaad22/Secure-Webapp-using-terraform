terraform {
  backend "s3" {
    bucket = "backend-st"
    key    = "backend-stfile"
    region = "us-east-1"
    dynamodb_table = "statelock"
  }
}