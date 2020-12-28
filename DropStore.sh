#!/bin/bash
#################################################################################################
# File   : DropStore Installation and Configuration Script
# Author : Reda Maher (eng.redamaher@gmail.com)
# Details: This script installs the DropStore on any Linux based OS (Ubuntu/Raspberry Pi OS)
#          The script does the following tasks:
#             1- Install the system prerequisites
#             2- Configure the Edge devices accounts
#             3- Configure DropStore Cloud parameters/accounts/encryption key
#             4- Restore old backup (if needed)
#             5- Setup the periodic DropStore Cloud Backup job
#################################################################################################

HORIZONTAL_LINE="========================================================================="
DUPLICITY_GIT_REPO="https://github.com/RedaMaher/DropStore_duplicity"
DROPSTORE_DUPLICITY_BRANCH="DropStore_support"
SFTP_GROUP_NAME="dropstore-edge-users"
DROPSTORE_ROOT_DIR="/opt/dropstore"

clear
clear
echo -e "\n${HORIZONTAL_LINE}"
echo -e "\n                   Welcome to DropStore Installation"
echo -e "\n${HORIZONTAL_LINE}"

if [ $(id -u) != 0 ]; then
   echo "This script must be run as root for proper operation" 
   exit 1
fi

echo -e "\n#########################"
echo -e "\n# Install prerequisites"
echo -e "\n#########################"

apt install -y git vim gnupg python3-distutils python3-dev librsync-dev python3-setuptools gettext python3-pip cron
exit_1=$?
python3 -m pip install future fasteners mediafire
exit_2=$?
exit_status=$((${exit_1} + ${exit_2}))

if [ ${exit_status} != 0 ]; then
    echo "ERROR: Colud not install the prerequisites .. Abort!"
    exit 1
fi

echo -e "\n#################################"
echo -e "\n# Configure DropStore location"
echo -e "\n#################################"
# Prompt the user for dropstore location
while true; do
    read -p "Default DropStore Location is ${DROPSTORE_ROOT_DIR}, Do you like to change it [y/n]? " yn
    case $yn in
        [Yy]* )
            read -p "Please Enter the path to the new location: " DROPSTORE_ROOT_DIR; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
rm -rf ${DROPSTORE_ROOT_DIR}
mkdir -p ${DROPSTORE_ROOT_DIR}
EDGE_USERS_BACKUP_DIR="${DROPSTORE_ROOT_DIR}/edge-users"
DROPSTORE_CONFIG_DIR="${DROPSTORE_ROOT_DIR}/config"

echo -e "\n#################################################"
echo -e "\n# Install the DropStore version of Duplicity"
echo -e "\n#################################################"
pushd /tmp > /dev/null
rm -rf /tmp/duplicity-gitlab
git clone ${DUPLICITY_GIT_REPO}
if [ $? != 0 ]; then
    echo "ERROR: Colud not clone the duplicity source code .. Abort!"
    exit 1
fi

cd duplicity-gitlab
python3 setup.py build
if [ $? != 0 ]; then
    echo "ERROR: Failed to build Duplicity .. Abort!"
    exit 1
fi

python3 setup.py install
if [ $? != 0 ]; then
    echo "ERROR: Failed to install Duplicity .. Abort!"
    exit 1
fi

# Check that duplicitiy was installed correctly
duplicity -h > /dev/null
if [ $? != 0 ]; then
    echo "ERROR: Duplicity was not installed correctly .. Abort!"
    exit 1
fi

rm -rf /tmp/duplicity-gitlab

popd > /dev/null

echo -e "\n########################################"
echo -e "\n# Configure the Edge devices accounts"
echo -e "\n########################################"
while true; do
    read -p "Enter the count of the Edge Devices: " EDGE_DEVICES_COUNT
    read -p "The Edge devices count is ${EDGE_DEVICES_COUNT}, please confirm [y/n]? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
done

EDGE_DEVICES_USER_NAMES=()
EDGE_DEVICES_PASSWORD=()

# Read User name and passwords for the edge devices
count=0
while [ ${count} -lt ${EDGE_DEVICES_COUNT} ]
do
    read -p "Enter the user name for Edge Device ${count}: " EDGE_DEVICES_USER_NAMES[${count}]
    read -sp "Enter the password for Edge Device ${count}: " EDGE_DEVICES_PASSWORD[${count}]
    echo ""
    count=`expr $count + 1`
done

# Configure the edge devices account
# Create SFTP group
groupadd ${SFTP_GROUP_NAME} > /dev/null 2>&1

# Create edge users accounts
count=0
for edgeuser in "${EDGE_DEVICES_USER_NAMES[@]}"
do
    userdel ${edgeuser} > /dev/null 2>&1
    useradd -g ${SFTP_GROUP_NAME} -d /backup -s /sbin/nologin ${edgeuser}
    echo ${edgeuser}:${EDGE_DEVICES_PASSWORD[${count}]} | chpasswd
    mkdir -p ${EDGE_USERS_BACKUP_DIR}/${edgeuser}/backup
    chown ${edgeuser}:${SFTP_GROUP_NAME} ${EDGE_USERS_BACKUP_DIR}/${edgeuser}/backup
    count=`expr $count + 1`
done

# Configure the SFTP Jail
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Remove old configs
sed -ri "s/^Subsystem(.*?)sftp(.*)/\#Subsystem\1sftp\2/" /etc/ssh/sshd_config
sed -ri "s/^Match Group(.*?)/\#Match Group\1/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)ChrootDirectory(.*?)/\#\1ChrootDirectory\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)X11Forwarding(.*?)/\#\X11Forwarding\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)AllowTcpForwarding(.*?)/\#\AllowTcpForwarding\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)PermitTunnel(.*?)/\#\PermitTunnel\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)AllowAgentForwarding(.*?)/\#\AllowAgentForwarding\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)ForceCommand(.*?)/\#\ForceCommand\2/" /etc/ssh/sshd_config
sed -ri "s/^(\s*)PasswordAuthentication(.*?)/\#\PasswordAuthentication\2/" /etc/ssh/sshd_config

# Add the new configs
echo "Subsystem       sftp    internal-sftp" >> /etc/ssh/sshd_config
echo "Match Group ${SFTP_GROUP_NAME}
        ChrootDirectory ${EDGE_USERS_BACKUP_DIR}/%u
        X11Forwarding no
        AllowTcpForwarding no
        PermitTunnel no
        AllowAgentForwarding no
        ForceCommand internal-sftp
        PasswordAuthentication yes" >> /etc/ssh/sshd_config
service sshd restart > /dev/null
if [ $? != 0 ]; then
    echo "ERROR: Failed to configure SFTP .. Abort!"
    exit 1
fi

echo -e "\n########################################"
echo -e "\n# Configure DropStore Cloud Parameters"
echo -e "\n########################################"
while true; do
    read -p "Enter the count of Cloud Servers: " CLOUD_SERVERS_COUNT
    read -p "Enter the Replica Count         : " DATA_REPLICA_COUNT
    read -p "Enter the data Chunk Size       : " DATA_CHUNCK_SIZE
    
    echo "DropStore Cloud Configurations:"
    echo "    Number of Cloud Servers: ${CLOUD_SERVERS_COUNT}"
    echo "    Replica Count          : ${DATA_REPLICA_COUNT}"
    echo "    Data Chunk Size        : ${DATA_CHUNCK_SIZE}"
    
    read -p "Please confirm [y/n]? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) ;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "\n#########################################"
echo -e "\n# Configure the Cloud Servers accounts"
echo -e "\n#########################################"

echo -e "\nPlease enter the cloud server URL in the following format:"
echo -e "\n   scheme://[user[:password]@]host[:port]/[/]path"
echo -e "\n   for more information, please refer to Duplicity manual page\n"

CLOUD_SERVERS_URLS=()
count=0
while [ ${count} -lt ${CLOUD_SERVERS_COUNT} ]
do
    read -p "Cloud Server ${count}: " CLOUD_SERVERS_URLS[${count}]
    count=`expr $count + 1`
done

# Create the Multi-Cloud configuration file
mkdir -p ${DROPSTORE_CONFIG_DIR}
touch ${DROPSTORE_CONFIG_DIR}/config.json
echo "[" > ${DROPSTORE_CONFIG_DIR}/config.json

count=0
for csp_url in "${CLOUD_SERVERS_URLS[@]}"
do
    count=`expr $count + 1`
    if [ ${count} -lt ${CLOUD_SERVERS_COUNT} ]; then
        echo "  {
    \"url\":\"${csp_url}\"
  }," >> ${DROPSTORE_CONFIG_DIR}/config.json
    else
        echo "  {
    \"url\":\"${csp_url}\"
  }" >> ${DROPSTORE_CONFIG_DIR}/config.json
    fi
done

echo "]" >> ${DROPSTORE_CONFIG_DIR}/config.json

echo -e "\n###########################################"
echo -e "\n# Configure the DropStore Encryption Key"
echo -e "\n###########################################"

while true; do
    echo "1) Generate a New Key."
    echo "2) Import an existing Key."
    echo "3) List the available Public Keys."
    echo "4) List the available Private Keys"
    echo "5) Configure DropStore Key ID and Continue."
    read -p "Type your selected option number: " choice
    if [ "${choice}" -eq "${choice}" 2> /dev/null ]; then
        if [ ${choice} -lt 1 -o ${choice} -gt 5 ]; then
            echo -e "\n\n==> Enter number between 1 and 5 <==\n\n"
        elif [ ${choice} -eq 1 ]; then
            echo "Generating a New Key .."
            gpg --gen-key
        elif [ ${choice} -eq 2 ]; then
            read -p "Enter the path to the Key: " KEY_PATH
            gpg --import ${KEY_PATH}/DropStore.key && gpg --import-ownertrust ${KEY_PATH}/DropStore.trust
            if [ $? != 0 ]; then
                echo -e "\n\nERROR: Failed to import the Key .. Make sure the path is correct!\n\n"
            fi
        elif [ ${choice} -eq 3 ]; then
            echo "List Public Keys .."
            gpg --list-public-keys
        elif [ ${choice} -eq 4 ]; then
            echo "List Private Keys .."
            gpg --list-secret-keys
        elif [ ${choice} -eq 5 ]; then
            read -p "Enter the DropStore Key ID: " DROPSTORE_ENC_KEY_ID
            break;
        fi
    else
        echo -e "\n\n==> This is not a number <==\n\n"
    fi
done

# Export the key to the configuration folder
gpg --export-secret-keys ${DROPSTORE_ENC_KEY_ID} > /tmp/key
gpg --export-ownertrust > /tmp/trust
mv /tmp/key ${DROPSTORE_CONFIG_DIR}/DropStore.key
mv /tmp/trust ${DROPSTORE_CONFIG_DIR}/DropStore.trust

# Configure Periodic DropStore Cloud backup task
crontab -r > /dev/null 2>&1
echo "0 1 * * * duplicity --progress --allow-source-mismatch --volsize ${DATA_CHUNCK_SIZE} --encrypt-key ${DROPSTORE_ENC_KEY_ID} ${EDGE_USERS_BACKUP_DIR} \"multi://${DROPSTORE_CONFIG_DIR}/config.json?mode=redundent&onfail=abort&count=${DATA_REPLICA_COUNT}\"" > /tmp/dropstore_cron
crontab /tmp/dropstore_cron
rm -f /tmp/dropstore_cron

# Write the configuration of the DropStore to the configuration folder
echo "====================================================
        DropStore Retrieval Information
====================================================
CLOUD_SERVERS_COUNT  : ${CLOUD_SERVERS_COUNT}
DATA_REPLICA_COUNT   : ${DATA_REPLICA_COUNT}
DATA_CHUNCK_SIZE     : ${DATA_CHUNCK_SIZE}
DROPSTORE_ENC_KEY_ID : ${DROPSTORE_ENC_KEY_ID}
====================================================
DropStore Edge Users
---------------------" > ${DROPSTORE_CONFIG_DIR}/DropStore_Retrieval.info
count=0
for edgeuser in "${EDGE_DEVICES_USER_NAMES[@]}"
do
    echo "USER ${count}: ${edgeuser}, ${EDGE_DEVICES_PASSWORD[${count}]}" >> ${DROPSTORE_CONFIG_DIR}/DropStore_Retrieval.info
    count=`expr $count + 1`
done

echo "====================================================
DropStore Cloud Accounts
------------------------" >> ${DROPSTORE_CONFIG_DIR}/DropStore_Retrieval.info

count=0
for csp_url in "${CLOUD_SERVERS_URLS[@]}"
do
    echo "ACCOUNT ${count}: ${csp_url}" >> ${DROPSTORE_CONFIG_DIR}/DropStore_Retrieval.info
    count=`expr $count + 1`
done

# Retore Old backup (if any)
while true; do
    read -p "Do you like to restore an old backup from the cloud [y/n]? " yn
    case $yn in
        [Yy]* )
            echo "Restoring the old backup .."
            rm -rf ${EDGE_USERS_BACKUP_DIR} # To restore it from the cloud
            duplicity --progress --volsize ${DATA_CHUNCK_SIZE} --encrypt-key ${DROPSTORE_ENC_KEY_ID} "multi://${DROPSTORE_CONFIG_DIR}/config.json?mode=redundent&onfail=abort&count=${DATA_REPLICA_COUNT}" ${EDGE_USERS_BACKUP_DIR}
            break;;
        [Nn]* )
            break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Finalize
echo -e "\n######################################################################################################################"
echo -e "\n# DropStore Setup was Successfully Done !\n"
echo -e "# CAUTION: DropStore Retrieval Information was saved in:"
echo -e "#    ${DROPSTORE_CONFIG_DIR}"
echo -e "# Please save it in a secure external storage for disaster recovery."
echo -e "\n#######################################################################################################################"


