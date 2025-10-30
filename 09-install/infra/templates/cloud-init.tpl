#cloud-config

users:
  - name: ${user}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
packages:
  - python3
  - python3-pip

runcmd:
  - apt-get -y install python3-apt
  - pip3 install --upgrade pip setuptools