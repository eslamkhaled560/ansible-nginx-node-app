#!/bin/bash

# use nginx public ip in the inventory and default files
ip=$(cat nginx-pub-ip.txt)
sed -i "s/NGINX_PUB_IP/$ip/g" inverntory.txt index.nginx-debian.html

ansible-playbook -i inverntory.txt playbook.yml