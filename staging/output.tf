output "elb_hostname" {
  value = "${module.project.elb.hostname}"
}

output "bastion_host" {
  value = "${module.networking.bastion.hostname}"
}

output "project_ip" {
  value = "${module.project.project.ip}"
}
