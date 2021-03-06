variable "account_file" {
  type = string
  default = "/home/admin/shadow/key.json"
}

variable "zone" {
  type = string
  default = "europe-west6-a"
}

variable "project_id" {
  type = string
  default = ""
}

source "googlecompute" "gcp-source" {
  account_file = var.account_file
  project_id = var.project_id
  source_image = "debian-10-buster-v20200413"
  ssh_username = "admin"
  zone = var.zone

  image_name = "docker-registry-v3"
}

build {
  sources = ["sources.googlecompute.gcp-source"]
  
  provisioner "ansible" {
    user = "packer"
    playbook_file = "ansible/docker-registry.yml"
  }
}
