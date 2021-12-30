provider "aws" {
    region = "ap-northeast-2"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-southouse"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "ap-northeast-2"
        encrypt = true
        dynamodb_table = "terraform-up-and-running-lock"
    }
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"

    cluster_name = "webservers-stage"
    db_remote_state_bucket = "terraform-up-and-running-state-southouse"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

    instance_type = "t2.micro"
    min_size = 1
    max_size = 2
}