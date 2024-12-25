#!/bin/bash
echo "Provisioning EC2 instance with ansible"
cd /tmp
git clone https://github.com/PramodCodes/roboshop-ansible-roles.git
cd rpoboshop-ansible-roles
# Array of components
components=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

# Loop through each component and run the playbook
for component in "${components[@]}"
do
    ansible-playbook -e component=$component main.yaml
done
