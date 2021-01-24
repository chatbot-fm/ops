#!/usr/bin/env bash

terraform destroy \
    -var-file=/root/shadow/deploy.json \
    -auto-approve
