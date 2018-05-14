#!/usr/bin/env bash

echo "Starting Adalab Provisioner..."

set -e

echo "--> Installing prerequisites..."
apt-get update -qq
apt-get install -y -q ansible python-apt apt-transport-https

echo "--> Running Adalab Provision Playbook..."
ansible-playbook ./adalab-provision.yml

echo "Finished Adalab Provisioner!"

echo "Powering off computer..."
sleep 15s; shutdown -P now
