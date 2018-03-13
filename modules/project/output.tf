output "elb.hostname" {
  value = "${aws_elb.project.dns_name}"
}

output "project.ip" {
  value = "${aws_instance.project.*.private_ip}"
}
