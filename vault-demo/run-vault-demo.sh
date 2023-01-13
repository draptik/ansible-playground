#!/bin/bash

ansible-playbook \
    --vault-password-file=.vault_pass \
    playbook-vault-demo.yml 
