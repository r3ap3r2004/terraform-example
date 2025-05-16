#!/bin/bash

if ! dpkg -l | grep -q mysql-server; then
  apt-get update
  apt-get install -y mysql-server
fi
systemctl enable mysql
systemctl start mysql
