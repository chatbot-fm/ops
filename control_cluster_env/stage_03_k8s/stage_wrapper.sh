#!/usr/bin/env bash
rm $HOME/.ssh/known_hosts
set -e

sh ../stage_01_provisioning_gcloud/stage_output/run_ansible.sh k8s-install.yml
