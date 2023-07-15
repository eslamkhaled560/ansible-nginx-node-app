#!/bin/bash

# run node app on nginx port 8081
echo 'server {
    listen 80;
    location / {
        proxy_pass http://0.0.0.0:8080;
    }
}' | sudo tee -a /etc/nginx/sites-enabled/default

systemctl restart nginx

node /app/server.js