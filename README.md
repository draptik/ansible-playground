# Ansible playground

Just some [ansible](https://www.ansible.com/) experiments...

## RPi setup

I started using 2 RPis version 1 (!).

Both RPis are clean installs of `bullseye`.

The first RPi will be my "server". The second RPi will be the "client".

Both RPis are configured with enabled SSH, and the "server" is setup with `ssh-cpy-id` so it can
access the "client".

In addition both RPis have a unique name configured.

## Installing ansible on RPi "server"

The ansible version provided by Debian is outdated.

[Official Installation Instructions for Debian](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-debian)

Add to `/etc/apt/sources.list`:

```txt
deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main
```

```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt update
sudo apt install ansible
```

## Ansible: Setup inventory

The default location of the `inventory` is: `/etc/ansible/hosts`.

Ansible's `inventory` is a list of machines which ansible `playbooks` are applied to.

The simplest form of an `inventory` is a list of IPs and/or hostnames:

```txt
192.168.172.123
rpi1
```

These entries can be grouped:

```txt
[rpis]
rpi1
rpi2
```

The `inventory` can also include `localhost`, but we have to tell ansible to use a different network
connection type:

```txt
localhost ansible_connection=local

[rpis]
rpi1
```

## Ansible playbooks

### Apt packages

```yml
---
- name: My first playbook
  hosts: all
  become: yes
  become_user: root
  vars:
    ansible_python_interpreter: /usr/bin/python3
 
  tasks:
    - name: apt update...
      apt:
        update_cache: yes
        cache_valid_time: 3600
    - name: apt upgrade...
      apt:
        upgrade: dist
    - name: install vim...
      apt:
        name: vim
        state: present
```

...same, but shorter:

```yml
---
- name: My second playbook
  hosts: all
  become: yes
  become_user: root
  vars:
    ansible_python_interpreter: /usr/bin/python3
 
  tasks:
    - name: apt update...
      apt:
        update_cache: yes
        cache_valid_time: 3600
    - name: apt upgrade...
      apt:
        upgrade: dist
    - name: install vim, git, and tmux...
      apt:
        pkg:
          - vim
          - git
          - tmux
```

### Clone a git repo

Note: no user/sudo changes.

```yml
---
- name: get dotfile playbook
  hosts: all
  vars:
    ansible_python_interpreter: /usr/bin/python3
 
  tasks:
    - name: get dotfiles from github...
      ansible.builtin.git:
        repo: 'https://github.com/draptik/dotfiles.git'
        dest: ~/.dotfiles
```

