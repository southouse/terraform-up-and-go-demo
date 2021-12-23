provider "aws" {
    region = "ap-northeast-2" 
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-southouse"
        key = "global/s3/terraform.tfstate"
        region = "ap-northeast-2"
        encrypt = true
        dynamodb_table = "terraform-up-and-running-lock"
    }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-up-and-running-state-southouse"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-up-and-running-lock"
    hash_key = "LockID"
    read_capacity = 2
    write_capacity = 2

    attribute {
        name = "LockID"
        type = "S"
    }
}