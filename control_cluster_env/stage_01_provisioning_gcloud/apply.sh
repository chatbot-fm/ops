#!/usr/bin/env bash

terraform apply \
    -var-file=/root/shadow/deploy.json \
    -auto-approve
