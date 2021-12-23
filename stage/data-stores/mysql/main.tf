provider "aws" {
    region = "ap-northeast-2"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-southouse"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "ap-northeast-2"
        encrypt = true
        dynamodb_table = "terraform-up-and-running-lock"
    }
}

resource "aws_db_instance" "example" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "example_database"
    port = 9999
    username = "admin"
    password = "${var.db_password}"
}