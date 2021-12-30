output "elb_dns_name" {
    value = "${module.webserver_cluster.elb_dns_name}"
}

output "asg_name" {
    value = "${module.webserver_cluster.asg_name}"
}