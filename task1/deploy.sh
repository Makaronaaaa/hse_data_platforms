#!/bin/bash

if ! command -v ansible &> /dev/null; then
    sudo apt update
    sudo apt install -y ansible
fi

ansible all -i inventory.ini -m ping

if [ $? -ne 0 ]; then
    exit 1
fi

ansible-playbook -i inventory.ini deploy.yml
