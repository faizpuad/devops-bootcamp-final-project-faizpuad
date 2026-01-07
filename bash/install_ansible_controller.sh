#!/usr/bin/env bash
set -e

if command -v ansible >/dev/null 2>&1; then
  echo "Ansible already installed"
  exit 0
fi

sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

ansible --version
