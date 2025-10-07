#!/usr/bin/env bash

### Requires a fresh, minimal Debian 13 VM 'librechat' with at least:
# - a system user 'USER'
# - working OpenSSH access
#
# How to use:
# 1. Copy this script ('install.sh') to the root of the home directoy of user
#    'USER' on 'librechat'.
# 2. Log in as user 'USER' on 'librechat'
# 3. Run this script as root: su -m root -c 'bash ./install.sh'
# 4. Shutdown the VM and make a snapshot so you can revert to it later using
#    the 'reset.sh' script.

USER="fcoppens"
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEG9oNpv5G/EyLbnkpu7drR2Hzwtz532h8wrsFIEiUPO"

# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl rsync
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable --now docker

mkdir -pv /home/$USER/.ssh
echo "$PUBKEY" > /home/$USER/.ssh/authorized_keys
chown -Rv $USER:users /home/$USER/.ssh
chmod -v 600 /home/$USER/.ssh/authorized_keys

/usr/sbin/usermod -aG docker $USER
