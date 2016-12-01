#!/bin/sh

echo "Rising the maximum memory that virtual machines are allowed to map"
sudo sysctl -w vm.max_map_count=262144

echo "Starting cim ..."
docker-compose up
