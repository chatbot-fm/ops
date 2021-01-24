variable "account_file" {
  type = string
  default = "/root/shadow/packer-credentials.json"
}

variable "zone" {
  type = string
  default = "europe-west6-a"
}

variable "project_id" {
  type = string
  default = "tf-k8s-playground"
}

variable "source_image" {
  type = string
  default = "debian-10-buster-v20200413"
}

variable "image_name" {
  type = string
  default = "default-image-name"
}

variable "playbook_path" {
  type = string
  default = "ansible/drone.yml"
}

source "googlecompute" "gcp_source" {
  account_file = var.account_file
  project_id = var.project_id
  source_image = var.source_image
  ssh_username = "packer"
  zone = var.zone

  image_name = var.image_name
}

build {
  sources = ["sources.googlecompute.gcp_source"]
  
  provisioner "ansible" {
    user = "packer"
    playbook_file = var.playbook_path
  }
}
