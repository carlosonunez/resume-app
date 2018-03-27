terraform {
  backend "s3" { }
}

provider "aws" {
  version = "~> 1.9"
}
