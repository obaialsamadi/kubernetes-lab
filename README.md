# kubernetes-lab

Ansible playbooks to setup kubernetes cluster the hardway.

## lxd

By default, the repo targets `LXC` containers as host to install and setup kubernetes.
Make sure you are using the vagrant box as backend as your workenvironment. It needs `virtualbox` to be installed
on you host.

- `make init` : creates and installs some base packages on containers.
- `make clean` : removes lxc containers

## ansible

- deploy

```bash
ansible-playbook -i staging --limit staging site.yml
```