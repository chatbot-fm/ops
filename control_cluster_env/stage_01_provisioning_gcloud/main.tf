#########################################################
######################################################### Network
#########################################################

resource "google_compute_network" "main-net" {
  name = "main-net"
  project = var.project-id
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main-a-subnet" {
  name = "main-a-subnet"
  project = var.project-id
  region = var.region
  ip_cidr_range = var.main-net-range
  network = google_compute_network.main-net.self_link
}

###
### Allow all traffic between members of internal network.
###

resource "google_compute_firewall" "internal-traffic-rule" {
  name    = "internal-traffic-rule"
  project = var.project-id
  network = google_compute_network.main-net.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
  source_ranges = [var.main-net-range]
}

###
### Let memebers of internal network see the internet.
###

resource "google_compute_router" "main-net-router" {
  name    = "main-net-router"
  region  = var.region
  network = google_compute_network.main-net.name
  project = var.project-id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "main-net-nat" {
  name                               = "main-net-nat"
  router                             = google_compute_router.main-net-router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project = var.project-id
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

###
### Setup internal DNS zone for the members of internal network.
###

resource "google_dns_managed_zone" "main-zone" {
  name        = "main-zone"
  dns_name    = "${var.internal-dns-name}."
  description = "Example private DNS zone"
  project = var.project-id

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.main-net.self_link
    }
  }
}

#########################################################
######################################################### Bastion node
#########################################################

resource "google_compute_instance" "bastion-node" {
  project = var.project-id
  
  name         = "bastion-node"
  machine_type = "n1-standard-1"
  zone         = var.zone
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = var.bastion-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["bastion", "bastion-ssh", "main-a-subnet"]
}

###
### Allow connections to SSH port of bastion from everywhere.
###

resource "google_compute_firewall" "bastion-ssh-rule" {
  name    = "bastion-ssh-rule"
  project = var.project-id
  network = google_compute_network.main-net.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion-ssh"]
}

###
### Allow traffic from vpn network to internal network.
###

resource "google_compute_firewall" "vpn-traffic-rule" {
  name    = "vpn-traffic-rule"
  project = var.project-id
  network = google_compute_network.main-net.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
  source_ranges = ["10.10.0.0/24"]
}

###
### Allow  connections from the outside to wireguard's port of bastion.
###

resource "google_compute_firewall" "wireguard-rule" {
  name    = "wireguard-rule"
  project = var.project-id
  network = google_compute_network.main-net.self_link

  allow {
    protocol = "udp"
    ports    = [var.bastion-wg-port]
  }

  target_tags = ["bastion"]
}

#########################################################
######################################################### Gitea node
#########################################################

resource "google_compute_instance" "gitea-node" {
  project = var.project-id
  
  name         = "gitea-node"
  machine_type = var.gitea-node-type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.gitea-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["gitea", "main-a-subnet"]
}

resource "google_dns_record_set" "git" {
  name = "${var.git-dns-name}."
  type = "A"
  ttl  = 300
  project = var.project-id

  managed_zone = google_dns_managed_zone.main-zone.name

  rrdatas = [google_compute_instance.gitea-node.network_interface.0.network_ip]
}

#########################################################
######################################################### Drone node
#########################################################

resource "google_compute_instance" "drone-node" {
  project = var.project-id
  
  name         = "drone-node"
  machine_type = var.drone-node-type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.drone-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["drone", "main-a-subnet"]
}

resource "google_dns_record_set" "drone" {
  name = "${var.drone-dns-name}."
  type = "A"
  ttl  = 300
  project = var.project-id

  managed_zone = google_dns_managed_zone.main-zone.name

  rrdatas = [google_compute_instance.drone-node.network_interface.0.network_ip]
}

#########################################################
######################################################### K8s nodes
#########################################################

resource "google_compute_instance" "k8s-control-master-node" {
  project = var.project-id
  
  name         = "k8s-control-master-node"
  machine_type = var.k8s-control-node-type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.k8s-control-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["k8s-control", "main-a-subnet"]
}

resource "google_compute_instance" "k8s-control-slave-node" {
  project = var.project-id
  
  name         = "k8s-control-slave-node-${count.index}"
  machine_type = var.k8s-control-node-type
  zone         = var.zone

  count = var.k8s-control-pool-size

  boot_disk {
    initialize_params {
      image = var.k8s-control-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["k8s-control", "main-a-subnet"]
}

resource "google_compute_instance" "k8s-worker-node" {
  project = var.project-id
  
  name         = "k8s-worker-node-${count.index}"
  machine_type = var.k8s-worker-node-type
  zone         = var.zone

  count = var.k8s-worker-pool-size

  boot_disk {
    initialize_params {
      image = var.k8s-worker-img
    }
  }

  network_interface {
    network = google_compute_network.main-net.self_link
    subnetwork = google_compute_subnetwork.main-a-subnet.self_link
  }

  metadata = {
    ssh-keys = join("\n", [for user, key in var.ssh_keys : "${user}:${file(key)}"])
  }

  tags = ["k8s-worker", "main-a-subnet"]
}

###
### Allow health checks of internal hosts by Google's TCP health probe servers.
###

resource "google_compute_firewall" "k8s-control-hc-traffic-rule" {
  name    = "k8s-control-hc-traffic-rule"
  project = var.project-id
  network = google_compute_network.main-net.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
  direction = "INGRESS"
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

###
### Setup load balancer for k8s control nodes.
###

resource "google_compute_health_check" "k8s-control-hc" {
  name               = "k8s-control-hc"
  project = var.project-id
  check_interval_sec = 1
  timeout_sec        = 1
  
  tcp_health_check {
    port = 6443
  }
}

resource "google_compute_region_backend_service" "k8s-control-svc" {
  name          = "k8s-control-svc"
  project = var.project-id
  region = var.region
  health_checks = [google_compute_health_check.k8s-control-hc.id]
  protocol = "TCP"
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_instance_group.k8s-control-primary-ig.self_link
  }

}

resource "google_compute_instance_group" "k8s-control-primary-ig" {
  name = "k8s-control-primary-ig"
  zone = var.zone
  project = var.project-id
  network = google_compute_network.main-net.self_link
  instances = var.k8s-control-secondary-ready ? concat(
    flatten(google_compute_instance.k8s-control-slave-node.*.self_link),
    [google_compute_instance.k8s-control-master-node.self_link]) : [google_compute_instance.k8s-control-master-node.self_link]
  
  named_port {
    name = "k8s-api"
    port = "6443"
  }
}

resource "google_compute_forwarding_rule" "k8s-control-lb" {
  name   = "k8s-control-lb"
  region = var.region
  project = var.project-id

  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.k8s-control-svc.id
  network               = google_compute_network.main-net.name
  subnetwork            = google_compute_subnetwork.main-a-subnet.name

  ports = [6443]
}

resource "google_dns_record_set" "k8s" {
  name = "${var.k8s-dns-name}."
  type = "A"
  ttl  = 300
  project = var.project-id

  managed_zone = google_dns_managed_zone.main-zone.name

  rrdatas = [google_compute_forwarding_rule.k8s-control-lb.ip_address]
}

