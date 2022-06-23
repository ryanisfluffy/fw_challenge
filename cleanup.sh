#!/bin/bash -e

terraform destroy -auto-approve
rm -f generated-key-pair.pem

echo "Resources deleted"