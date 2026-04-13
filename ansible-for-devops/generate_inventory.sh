#!/bin/bash

cd ..

echo "[servers]" > ansible-for-devops/inventory.ini  #  Creates Ansible group section in inventory file

terraform output -json ec2_public_ips | jq -r '.[]' | while read ip; do  # Gets EC2 IPs from Terraform
  echo "$ip" >> ansible-for-devops/inventory.ini      # Appends each IP to Ansible inventory file & dds each EC2 IP  
done

echo "" >> ansible-for-devops/inventory.ini
echo "[servers:vars]" >> ansible-for-devops/inventory.ini  # Adds group variables section
echo "ansible_user=ubuntu" >> ansible-for-devops/inventory.ini
echo "ansible_ssh_private_key_file=../terra-automate-key" >> ansible-for-devops/inventory.ini # Specifies the path to the SSH private key for Ansible to use when connecting to the EC2 instances



