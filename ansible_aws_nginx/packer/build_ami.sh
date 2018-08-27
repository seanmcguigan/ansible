#!/bin/bash

set -e

packer build bastion.json

cd ../tf_instance && terraform apply -auto-approve 