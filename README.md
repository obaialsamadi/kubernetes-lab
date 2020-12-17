# kubernetes-lab

Ansible playbooks to setup kubernetes cluster the hardway.

## lxd

By default, the repo targets `LXC` containers as host to install and setup kubernetes.

- `make init` : creates and installs some base packages on containers.
- `make clean` : removes lxc containers