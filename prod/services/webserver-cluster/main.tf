provider "aws" {
    region = "ap-northeast-2"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state-southouse"
        key = "prod/services/webserver-cluster/terraform.tfstate"
        region = "ap-northeast-2"
        encrypt = true
        dynamodb_table = "terraform-up-and-running-lock"
    }
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"

    cluster_name = "webservers-prod"
    db_remote_state_bucket = "terraform-up-and-running-state-southouse"
    db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

    instance_type = "t2.small"
    min_size = 2
    max_size = 2
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name = "scale-out-during-business-hours"
    min_size = 2
    max_size = 3
    desired_capacity = 3
    recurrence = "0 9 * * *"

    autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
    scheduled_action_name = "scale-in-at-night"
    min_size = 2
    max_size = 2
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = "${module.webserver_cluster.asg_name}"
}