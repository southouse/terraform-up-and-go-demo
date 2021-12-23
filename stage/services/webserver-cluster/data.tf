data "aws_availability_zones" "all" {
    state = "available"
}

data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = "terraform-up-and-running-state-southouse"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "ap-northeast-2"
    }
}