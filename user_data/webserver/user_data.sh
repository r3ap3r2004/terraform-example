#!/bin/bash

if ! dpkg -l | grep -q nginx; then
  apt-get update
  apt-get install -y nginx
fi
systemctl enable nginx
systemctl start nginx
