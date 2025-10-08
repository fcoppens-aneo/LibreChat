#!/usr/bin/env bash

# Local host info
KEY="~/.ssh/arch.key"
TARGET="LibreChat"
ROOT="/work/home/fcoppens/LCB/$TARGET"

# VM info
VM="lc-hr-only"
SNAPSHOT="02"
TIMEOUT="10"
HOST="10.0.0.208"
USER="fcoppens"

# Shutdown VM and wait for it to finish
sudo virsh shutdown $VM
while [[ $(sudo virsh domstate $VM) != "shut off" ]]; do
    echo "Waiting for VM to shut down..."
    sleep 1
done

# Revert to snapshot 'SNAPSHOT'
sudo virsh snapshot-revert $VM $SNAPSHOT

# Start the VM and wait for the boot sequence to complete
sudo virsh start $VM
echo "Waiting $TIMEOUT seconds for VM to complete booting..."
sleep $TIMEOUT

# Copy the Chatbot files to the VM
rsync -av \
    --exclude='.devcontainer' \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='.gitignore' \
    --exclude='.husky' \
    --exclude='.prettierrc' \
    --exclude='.vscode' \
    -e "ssh -i $KEY" \
    $ROOT $USER@$HOST:~

# Login to the VM and initialize the Chatbot
CMD="export TERM=xterm-256color; \
    bash ./$TARGET/setup/init.sh || true; \
    cd /home/$USER/$TARGET; \
    exec bash -l"
ssh -t -i $KEY $USER@$HOST $CMD
