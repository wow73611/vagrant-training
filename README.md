# vagrant-training


## Install Vagrant and VirtualBox

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](https://www.vagrantup.com/)

### Requirements
- VirutalBox >= 5.0
- Vagrant >= 1.5.0

### For Debian-based Linux distributions

Install VirtualBox 5.1
```bash
$ sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib' > /etc/apt/sources.list.d/virtualbox.list"
$ wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install -y virtualbox-5.1
```

Install Vagrant 1.8.7

[Getting Started - Install](https://www.vagrantup.com/intro/getting-started/install.html)
[Docs - Install](https://www.vagrantup.com/docs/installation/)

```bash
$ wget https://releases.hashicorp.com/vagrant/1.8.7/vagrant_1.8.7_x86_64.deb
$ sudo dpkg -i vagrant_1.8.7_x86_64.deb
```

