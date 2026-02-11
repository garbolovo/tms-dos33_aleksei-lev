# Create default user (auto UID/GID, with sudo)
./50-users.sh devops

# Create user with fixed UID/GID (recommended for multi-VM / Docker / K8s)
./50-users.sh devops -u 2000 -g 2000

# Create user with custom primary group
./50-users.sh devops developers

# Create service user (no sudo)
./50-users.sh devops --no-sudo

### Есть ли пользователь и группа с нужными UID/GID
getent group devops
id devops

### HOW TO RUN SCRIPTS
cd ~
# example git clone твоего репо hw4
chmod +x bootstrap/*.sh

./bootstrap/00-common.sh
./bootstrap/10-net.sh <role>
./bootstrap/30-ntp.sh <role>
./bootstrap/40-users.sh
./bootstrap/20-ssh.sh <role>

###  <role> this is: jumphost | vm1 | vm2 | vm3.