
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


## Install Vagrant and VirtualBox

- VirutalBox >= 5.0
- Vagrant >= 1.5.0

```
# Install VirtualBox 5.1
$ sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib' > /etc/apt/sources.list.d/virtualbox.list"
$ wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install -y virtualbox-5.1

# Install Vagrant 1.8.7
$ wget https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.deb
$ sudo dpkg -i vagrant_1.8.7_x86_64.deb
```

## Install Ansible in virtualenv
```
$ cd ~/vagrant-puppet/
$ virtualenv venv
$ source venv/bin/activate
$ pip install ansible==2.1
```

## Active virtualenv and use `ansible-galaxy install` before deployment
```
$ cd ~/vagrant-puppet/
$ source venv/bin/activate
$ ansible-galaxy install -r ansible/requirements.yml -p ansible/roles -vvv
```


# Deployment

## Using Vagrant + VirtualBox provider

### Usage

```bash
$ cd ~/vagrant-puppet/

# Ensure vagrant_provider variable is "virtualbox" in config.yml.
$ vagrant up
```


## Using Vagrant + OpenStack provider

### Install vagrant-openstack-provider plugin

This is a [Vagrant](http://www.vagrantup.com) 1.6+ plugin that adds an
[OpenStack Cloud](http://www.openstack.org/software/) provider to Vagrant,
allowing Vagrant to control and provision machines within OpenStack
cloud.

GitHub: [ggiamarchi/vagrant-openstack-provider](https://github.com/ggiamarchi/vagrant-openstack-provider)

```bash
$ vagrant plugin install vagrant-openstack-provider
```

### Usage

```bash
$ cd ~/cascade-engine-ansible/

# Edit config.yml to you need and set vagrant_provider variable to "openstack" in it.
$ vagrant up --no-provision --provider=openstack
$ vagrant provision
```

### Debug message

To easily debug what happened, we recommend to set the environment
variable VAGRANT_OPENSTACK_LOG to debug
```bash
$ export VAGRANT_OPENSTACK_LOG=debug
```


# Common Vagrant Commands

- `vagrant up`          -- starts vagrant environment (also provisions only on the FIRST vagrant up)
- `vagrant status`      -- outputs status of the vagrant machine
- `vagrant halt`        -- stops the vagrant machine
- `vagrant reload`      -- restarts vagrant machine, loads new Vagrantfile configuration
- `vagrant provision`   -- forces reprovisioning of the vagrant machine
- `vagrant ssh`         -- connects to machine via SSH
- `vagrant destroy`     -- stops and deletes all traces of the vagrant machine
