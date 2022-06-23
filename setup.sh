#!/bin/bash -e

access_key=$(echo $AWS_ACCESS_KEY_ID)
sec_key=$(echo $AWS_SECRET_KEY)

terraform init
terraform apply -auto-approve
PUBLIC_DNS=$(terraform state show aws_instance.app | grep public_dns | awk -F ' = ' '{gsub(/"/, "")}{print $2}')
chmod 400 ./generated-key-pair.pem


# timeout 30 bash -c 'while [[ "$(curl -s -o /dev/null -w "%{http_code}" http://${PUBLIC_DNS}:3030)" != "200" ]]; do echo "waiting for RustPad to become available..."; sleep 5; done' || false

until curl -s -f -o /dev/null "http://${PUBLIC_DNS}:3030"
do
  echo "Waiting for the RustPad Service to come online..."
  sleep 5
done

echo "Resources successfully provisioned. You can connect to the RustPad service by visiting"
echo "http://${PUBLIC_DNS}:3030 in your browser"
echo "You can also connect to your instance via ssh by running: ssh -i "generated-key-pair.pem" ec2-user@${PUBLIC_DNS}"