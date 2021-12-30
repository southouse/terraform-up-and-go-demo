resource "aws_launch_configuration" "example" {
    image_id = "ami-0eb14fe5735c13eb5"
    instance_type = "${var.instance_type}"
    security_groups = ["${aws_security_group.instance.id}"]

    user_data = templatefile(
        "${path.module}/user-data.sh",
        {
            vars = {
                server_port = "${var.server_port}"
                db_address = "${data.terraform_remote_state.db.outputs.address}"
                db_port = "${data.terraform_remote_state.db.outputs.port}"
            }
        }
    )
    
    lifecycle {
        create_before_destroy = true # 기존 리소스가 삭제되기 전에 새로운 리소스 생성
    }
}

resource "aws_autoscaling_group" "example" {
    launch_configuration = "${aws_launch_configuration.example.id}"
    availability_zones   = "${data.aws_availability_zones.all.names}"

    load_balancers = ["${aws_elb.example.name}"]
    health_check_type = "ELB"

    min_size = "${var.min_size}"
    max_size = "${var.max_size}"

    tag {
        key = "Name"
        value = "${var.cluster_name}"
        propagate_at_launch = true
    }
}

resource "aws_elb" "example" {
    name = "${var.cluster_name}"
    availability_zones = "${data.aws_availability_zones.all.names}"
    security_groups = ["${aws_security_group.elb.id}"]

    listener {
        lb_port = "${var.http_port}"
        lb_protocol = "http"
        instance_port = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        interval = 30
        target = "HTTP:${var.server_port}/"
    }
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_inbound" {
    type = "ingress"
    security_group_id = "${aws_security_group.instance.id}"

    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.elb.id}"
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "allow_server_ssh_inbound" {
    type = "ingress"
    security_group_id = "${aws_security_group.instance.id}"

    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "allow_server_outbound" {
    type = "egress"
    security_group_id = "${aws_security_group.instance.id}"

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "elb" {
    name = "${var.cluster_name}-elb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = "${aws_security_group.elb.id}"

    from_port = "${var.http_port}"
    to_port = "${var.http_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "allow_http_outbound" { # Health Check를 위한 아웃바운드 포트 허용
    type = "egress"
    security_group_id = "${aws_security_group.elb.id}"

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

    lifecycle {
        create_before_destroy = true
    }
}