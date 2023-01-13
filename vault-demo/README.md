# Ansible Vault

Goal: Store confidential variables in "ansible-vault", and access these variables from playbooks.

## Create password file

Create a plaintext password file and add it to `.gitignore`:

```sh
echo "mysecretpassword" > mypasswordfile.txt
echo "mypasswordfile.txt" >> .gitignore
```

## Use the password file when calling playbooks

We can pass the location of the password file to ansible playbooks (using `--vault-password-file`). This saves us the hassle of having to interactively enter a password.

```sh
#!/bin/bash

ansible-playbook \
    --vault-password-file=.vault_pass \
    playbook-vault-demo.yml 
```

## Using inline vault variables

This is the simplest way of encrypting sensitive data in playbooks.

```sh
# NOTE: `bla` is the string being encrypted
❯ ansible-vault encrypt_string bla        
Encryption successful
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          34653338636165323833343836376362316630343864326235636539643432373938663330623836
          3763373261386463643831373436373737383866386132350a376365386431323738633935346665
          64356634623738626361326137353634323238323762383435636439663638313264306138343162
          3763343039333030360a333866353739343238613336373938306362653532623334383438613965
          6632
```

This string can then be copied directly into the otherwise unencrypted playbook file:

```yml
---
- name: Vault demo
  hosts: localhost
  gather_facts: false
  vars:
    critical_password: !vault |
        $ANSIBLE_VAULT;1.1;AES256
        37653961356435346266303138366232303630373334346362383066663663613436366638616239
        6234343534623338346562616135386237623763613737660a336664616136656637366364666339
        66613235373662643538383463663863326331663461613862653262323164653466666530656435
        3436646664343765610a646661666264323336343938386165323033383631333632656566323230
        6533

  tasks:

    - name: Using a var from an inline ansible vault variable
      ansible.builtin.debug:
        msg:
          - "Super critical password is: {{ critical_password }}"
```


## Create an ansible vault

```sh
# create an ansible vault file
ansible-vault create vault.yml --vault-password-file=.vault_pass
```

## Edit a vault and create a `vars` file

```sh
ansible-vault edit vault.yml --vault-password-file=.vault_pass
```

The file should have the following content:

```yml
---
vault_db_password: "bar13"
```

Save the file.

The file `vault.yml` is encrypted and can be added to version control.

Since the file is encrypted, we can't even access the variable key without decrypting the file. Ansible has a convention to create a `vars` file next to the `vault` file. The `vars` file contains a mapping between the vault key and a key which is publically visible:

```yml
---
db_password: "{{ vault_db_password }}"
```

The variable key `db_password` can then be used in playbooks.

## Using a vault

Don't forget the add the location of the `vars` and `vault` files to the `vars_files` section, otherwise the files are not found.

```yml
---
- name: Vault demo
  hosts: localhost
  gather_facts: false
  vars:
    db_pw: "{{ db_password }}"
  vars_files:
    - ./vars
    - ./vault
    
  tasks:

    - name: Using a var from ansible vault file
      ansible.builtin.debug:
        msg:
          - "db_pw is: {{ db_pw }}"
```

