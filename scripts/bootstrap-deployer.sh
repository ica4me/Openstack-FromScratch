#!/usr/bin/env bash
set -euo pipefail

apt update

apt install -y \
  software-properties-common \
  python3-pip \
  python3-venv \
  git \
  sshpass \
  make \
  jq \
  curl \
  vim \
  netcat-openbsd

add-apt-repository --yes --update ppa:ansible/ansible

apt install -y ansible

ansible --version
ansible-playbook --version
ansible-galaxy --version

ansible-galaxy collection install -r requirements.yml
