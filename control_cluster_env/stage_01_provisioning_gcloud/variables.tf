variable "k8s-control-secondary-ready" {
  type = bool
  description = "K8s setup stage."
  default = false
}

variable "project-id" {
  type = string
  description = "Google cloud project ID."
  default = "tf-k8s-playground"
}

variable "region" {
  type = string
  description = "Google cloud region name."
  default = "europe-west3"
}

variable "zone" {
  type = string
  description = "Google cloud zone name."
  default = "europe-west3-b"
}

variable "internal-dns-name" {
  type = string
  description = "Internal root dns name"
  default = "infra"
}

variable "git-dns-name" {
  type = string
  description = "Internal dns for git"
  default = "git.infra"
}

variable "k8s-dns-name" {
  type = string
  description = "Internal dns for k8s"
  default = "k8s.infra"
}

variable "drone-dns-name" {
  type = string
  description = "Internal dns for drone"
  default = "drone.infra"
}

variable "main-net-range" {
  type = string
  description = "Network for k8s nodes"
  default = "10.2.0.0/16"
}

variable "remote_ssh_user" {
  type = string
  description = "User used to establish SSH connection for remote exec."
  default = "beolnix"
}

variable "remote_ssh_private_key_file" {
  type = string
  description = "Private key used to establish SSH connection for remote exec."
  default = "/root/shadow/id_rsa"
}

variable "ssh_keys" {
  type = map(string)
  description = "Users&rsa pub key file path; to be allowed to access the node."
  default = {
    beolnix = "/root/shadow/id_rsa.pub"
  }
}

variable "gitea-node-type" {
  type = string
  description = "Node type used by gitea node"
  default = "n1-standard-2"
}

variable "drone-node-type" {
  type = string
  description = "Node type used by drone node"
  default = "n1-standard-2"
}

variable "gitea-img" {
  type = string
  description = "Image for gitea node"
  default = "gitea-1595489506"
}

variable "drone-img" {
  type = string
  description = "Image for drone node"
  default = "drone-1593957206"
}

variable "bastion-img" {
  type = string
  description = "Image for k8s bastion node"
  default = "k8s-bastion-1594330326"
}

variable "bastion-wg-port" {
  type = string
  description = "Port used for wireguard to listion on"
  default = "51820"
}

variable "k8s-control-img" {
  type = string
  description = "Image for k8s control node"
  default = "k8s-control-1590611036"
}

variable "k8s-worker-img" {
  type = string
  description = "Image for k8s worker node"
  default = "k8s-control-1590611036"
}

variable "k8s-control-node-type" {
  type = string
  description = "Node type used by k8s control node"
  default = "n1-standard-2"
}

variable "k8s-worker-node-type" {
  type = string
  description = "Node type used by k8s worker node"
  default = "n1-standard-4"
}

variable "k8s-control-pool-size" {
  type = number
  description = "Number of k8s-control nodes in a pool"
  default = 2
}

variable "k8s-worker-pool-size" {
  type = number
  description = "Number of k8s-worker nodes in a pool"
  default = 3
}

variable "k8s-net-range" {
  type = string
  description = "Network for k8s nodes"
  default = "10.2.0.0/16"
}

variable "setup-vpn-client" {
  type = bool
  description = "Configure VPN client"
  default = true
}
