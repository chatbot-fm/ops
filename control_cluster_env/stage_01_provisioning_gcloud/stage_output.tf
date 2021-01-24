data  "template_file" "inventory" {
  template = "${file("./templates/inventory.tmpl")}"
  vars = {
    remote_ssh_private_key_file = var.remote_ssh_private_key_file
    remote_ssh_public_key_file = var.ssh_keys[var.remote_ssh_user]
    remote_ssh_user = var.remote_ssh_user
    bastion_ip = google_compute_instance.bastion-node.network_interface.0.access_config.0.nat_ip
    k8s_control_master_ip = google_compute_instance.k8s-control-master-node.network_interface.0.network_ip
    k8s_control_slave_ips = join("\n", google_compute_instance.k8s-control-slave-node.*.network_interface.0.network_ip)
    k8s_control_lb_ip = google_compute_forwarding_rule.k8s-control-lb.ip_address
    k8s_worker_ips = join("\n", google_compute_instance.k8s-worker-node.*.network_interface.0.network_ip)
    gitea_ip = google_compute_instance.gitea-node.network_interface.0.network_ip
    drone_ip = google_compute_instance.drone-node.network_interface.0.network_ip
  }

  depends_on = [
    google_compute_instance.gitea-node,
    google_compute_instance.drone-node,
    google_compute_instance.k8s-control-master-node,
    google_compute_forwarding_rule.k8s-control-lb,
  ]
}

resource "local_file" "inventory_file" {
  content  = data.template_file.inventory.rendered
  filename = "./stage_output/hosts.ini"
}

data "template_file" "run_ansible" {
  template = file("./templates/run_ansible.tmpl")
  depends_on = [
    local_file.inventory_file
  ]
}

resource "local_file" "run_ansible_file" {
  content  = data.template_file.run_ansible.rendered
  filename = "./stage_output/run_ansible.sh"
}

data "template_file" "ansible_vars" {
  template = file("./templates/ansible_vars.tmpl")
  vars = {
    gitea_ip = google_compute_instance.gitea-node.network_interface.0.network_ip
    bastion_ip = google_compute_instance.bastion-node.network_interface.0.access_config.0.nat_ip
    k8s_control_lb_ip = google_compute_forwarding_rule.k8s-control-lb.ip_address
    k8s_net_range = var.k8s-net-range
    apiserver_advertise_address = google_compute_instance.k8s-control-master-node.network_interface.0.network_ip
    drone_ip = google_compute_instance.drone-node.network_interface.0.network_ip
    git_dns = var.git-dns-name
    k8s_dns = var.k8s-dns-name
    drone_dns = var.drone-dns-name
    setup_vpn_client = var.setup-vpn-client
  }

  depends_on = [
    google_compute_instance.gitea-node,
    google_compute_instance.bastion-node
  ]
}

resource "local_file" "ansible_vars_file" {
  content  = data.template_file.ansible_vars.rendered
  filename = "./stage_output/ansible_vars.yml"
}
