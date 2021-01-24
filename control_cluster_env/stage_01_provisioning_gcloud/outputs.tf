output "bastion-node-external-ip" {
  value = google_compute_instance.bastion-node.network_interface.0.access_config.0.nat_ip
}

output "gitea-node-ip" {
  value = google_compute_instance.gitea-node.network_interface.0.network_ip
}

output "drone-node-ip" {
  value = google_compute_instance.drone-node.network_interface.0.network_ip
}

output "k8s-control-master-node-ip" {
  value = google_compute_instance.k8s-control-master-node.network_interface.0.network_ip
}

output "k8s-control-slave-node-ip" {
  value = google_compute_instance.k8s-control-slave-node.*.network_interface.0.network_ip
}

output "k8s-control-lb-ip" {
  value = google_compute_forwarding_rule.k8s-control-lb.ip_address
}
