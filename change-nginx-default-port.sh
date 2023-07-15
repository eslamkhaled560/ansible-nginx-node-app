#!/bin/bash

default_port=$(grep -oP 'listen\s+\K\d+' /etc/nginx/sites-enabled/default | head -n 1)

# if default port is not 8090, change it
if [ "$default_port" -ne "8090" ]; then
  sed -i 's/80/8090/g' /etc/nginx/sites-enabled/default
fi