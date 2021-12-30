data "aws_availability_zones" "all" {
    state = "available"
}

data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = "${var.db_remote_state_bucket}"
        key = "${var.db_remote_state_key}"
        region = "ap-northeast-2"
    }
}