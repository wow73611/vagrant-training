
# Installation

## Requirements

- Linux Ubuntu 14.04, 16.04 or CentOS 7
- virtualenv >= 1.11.0
- ansible >= 2.1.0
- pip == 7.1.2


## Install dependencies

- Ubuntu
```
$ sudo apt-get update
$ sudo apt-get install -y git build-essential libssl-dev libffi-dev sshpass
$ sudo apt-get install -y python-dev python-pip python-virtualenv
```

- CentOS
```
$ yum install -y git gcc gcc-c++ kernel-devel make openssl-devel libffi-devel sshpass
$ yum install -y python-devel python-pip python-virtualenv
```


## Upgrade pip
```
$ sudo pip install --upgrade pip==7.1.2
$ hash -r pip # Ubuntu14.04 only
```


## Get source code
```
$ cd ~
$ git clone https://github.com/wow73611/vagrant-puppet
```


## Install Ansible in virtualenv
```
$ cd ~/vagrant-puppet/
$ virtualenv venv
$ source venv/bin/activate
$ pip install ansible==2.1.0.0
```


## Active virtualenv and use `ansible-galaxy install` before deployment
```
$ cd ~/vagrant-puppet/
$ source venv/bin/activate
$ ansible-galaxy install -r ansible/requirements.yml -p ansible/roles -vvv
```


# Make sure your hosts to deploy

[Ansible’s inventory file](http://docs.ansible.com/ansible/latest/intro_inventory.html) which defaults to being saved in the location /etc/ansible/hosts. 

* You can add your hosts to ```ansible/hosts/inventory``` file

```yaml
# It's a example. Reference http://docs.ansible.com/ansible/latest/intro_inventory.html

default ansible_ssh_host=127.0.0.1 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=password

[puppet_nodes]
default ansible_ssh_host=127.0.0.1 ansible_ssh_port=22 ansible_ssh_user=root ansible_ssh_pass=password
```

* Alternatively you can create a inventory file in ansible/hosts/your_inventory_name.

You can specify a different inventory file using the -i <path> option on the command line.


# Deployment 

## Using ansible-playbook

```
$ ansible-playbook -i ansible/hosts/inventory ansible/vagrant-puppet.yml \
    -e "debug=false"
```


# For developers

## Development with Vagrant

[Vagrant](https://www.vagrantup.com/) is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past.

- [Install Vagrant and VirtualBox](docs/vagrant.md)
- [Using Vagrant + VirtualBox provider](docs/vagrant.md#using-vagrant-virtualbox-provider)
- [Using Vagrant + OpenStack provider](docs/vagrant.md#using-vagrant-openstack-provider)
