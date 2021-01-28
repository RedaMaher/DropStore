# DropStore

DropStore is a backup system architecture utilizes state-of-the-art Multi-Cloud backup techniques and provides an easy-to-use and fast interface using Fog Computing.

## DropStore Installation

To install and configure DropStore:
```
$ sudo apt install -y git
$ git clone https://github.com/RedaMaher/DropStore.git
$ cd DropStore
$ sudo ./DropStore.sh
```

The script will go with you step by step to install and configure the DropStore on any Linux based OS (Ubuntu/Raspberry Pi OS)

The following tasks are performed:
1. Install the system prerequisites
2. Configure the Edge devices accounts
3. Configure DropStore Cloud parameters/accounts/encryption key
4. Restore old backup (if needed)
5. Setup the periodic DropStore Cloud Backup job

### DropStore Installation Steps

When you run the DropStore installation script, it will do the following steps:
1. Install the system prerequisites (This step is done automatically and do not need user intervention)
```

=========================================================================

                   Welcome to DropStore Installation

=========================================================================

#########################

# Install prerequisites

#########################
Reading package lists... Done
Building dependency tree       
Reading state information... Done
cron is already the newest version (3.0pl1-134+deb10u1).
git is already the newest version (1:2.20.1-2+deb10u3).
gnupg is already the newest version (2.2.12-1+rpi1+deb10u1).
The following additional packages will be installed:
  bzip2-doc dh-python gir1.2-glib-2.0 libbz2-dev libcroco3 libexpat1-dev libgirepository-1.0-1 libpopt-dev libpython3-dev libpython3.7-dev librsync1 python-pip-whl
  python3-asn1crypto python3-cffi-backend python3-crypto python3-cryptography python3-dbus python3-entrypoints python3-gi python3-keyring python3-keyrings.alt python3-lib2to3
  python3-secretstorage python3-wheel python3-xdg python3.7-dev vim-runtime
Suggested packages:
  gettext-doc autopoint libasprintf-dev libgettextpo-dev python-crypto-doc python-cryptography-doc python3-cryptography-vectors python-dbus-doc python3-dbus-dbg gnome-keyring
  libkf5wallet-bin gir1.2-gnomekeyring-1.0 python-secretstorage-doc python-setuptools-doc ctags vim-doc vim-scripts
The following NEW packages will be installed:
  bzip2-doc dh-python gettext gir1.2-glib-2.0 libbz2-dev libcroco3 libexpat1-dev libgirepository-1.0-1 libpopt-dev libpython3-dev libpython3.7-dev librsync-dev librsync1
  python-pip-whl python3-asn1crypto python3-cffi-backend python3-crypto python3-cryptography python3-dbus python3-dev python3-distutils python3-entrypoints python3-gi
  python3-keyring python3-keyrings.alt python3-lib2to3 python3-pip python3-secretstorage python3-setuptools python3-wheel python3-xdg python3.7-dev vim vim-runtime
0 upgraded, 34 newly installed, 0 to remove and 0 not upgraded.
Need to get 60.2 MB of archives.
After this operation, 125 MB of additional disk space will be used.
Get:1 http://archive.raspberrypi.org/debian buster/main armhf python-pip-whl all 18.1-5+rpt1 [1591 kB]
Get:2 http://mirror.as43289.net/raspbian/raspbian buster/main armhf librsync1 armhf 0.9.7-10 [69.9 kB]
.
.
.
```

2. Configure DropStore folder location (This folder will contain the DropStore configuration files and the user data as well)
```
#################################

# Configure DropStore location

#################################
Default DropStore Location is /opt/dropstore, Do you like to change it [y/n]? y
Please Enter the path to the new location: /opt/dropstore
```
You can use an external hard disk with large space to accommodate the data (if needed).

3. Install the DropStore custom Duplicity version (no user intervention is needed)
```
#################################################

# Install the DropStore version of Duplicity

#################################################
Cloning into '/tmp/DropStore_duplicity'...
remote: Enumerating objects: 28860, done.
remote: Counting objects: 100% (28860/28860), done.
remote: Compressing objects: 100% (4526/4526), done.
remote: Total 28860 (delta 24267), reused 28859 (delta 24266), pack-reused 0
.
.
.
```

4. Configure the accounts of the Edge devices
```
########################################

# Configure the Edge devices accounts

########################################
Enter the count of the Edge Devices: 1
The Edge devices count is 1, please confirm [y/n]? y
Enter the user name for Edge Device 0: reda
Enter the password for Edge Device 0: 
```
You can configure as many accounts as you need. These accounts can be used from any edge device to upload/download data to DropStore using any SFTP client.

5. Configure the parameters of the cloud servers that will be used for periodic backups (Here you can configure the number of cloud servers, the data replica count, and the data chunk size)
```
########################################

# Configure DropStore Cloud Parameters

########################################
Enter the count of Cloud Servers: 5
Enter the Replica Count         : 3
Enter the data Chunk Size       : 10
DropStore Cloud Configurations:
    Number of Cloud Servers: 5
    Replica Count          : 3
    Data Chunk Size        : 10
Please confirm [y/n]? y
```

6. Configure the accounts of the cloud servers
```
#########################################

# Configure the Cloud Servers accounts

#########################################

Please enter the cloud server URL in the following format:

   scheme://[user[:password]@]host[:port]/[/]path

   for more information, please refer to Duplicity manual page

Cloud Server 0: mf://user@mail.com:password@mediafire.com/path/to/folder0
Cloud Server 1: mf://user@mail.com:password@mediafire.com/path/to/folder1
Cloud Server 2: mf://user@mail.com:password@mediafire.com/path/to/folder2
Cloud Server 3: mf://user@mail.com:password@mediafire.com/path/to/folder3
Cloud Server 4: mf://user@mail.com:password@mediafire.com/path/to/folder4
````
You can check the Duplicity manual page for more information on how to format the cloud server URL.
Duplicity supports many cloud providers and protocols including Amazon, Azure, One Drive, DropBox, Mediafire, rsync, ssh, etc.
DropStore is tested against local servers and Mediafire cloud storage.

7. Configure the DropStore Encryption Key
```
###########################################

# Configure the DropStore Encryption Key

###########################################
1) Generate a New Key.
2) Import an existing Key.
3) List the available Public Keys.
4) List the available Private Keys
5) Configure DropStore Key ID and Continue.
Type your selected option number: 

```
Here you can generate a new key or import existing key then configure the DropStore Key (using option 5). Whether you will generate or import a key, you need to select option 5 at the end to choose which key will be used for DropStore.

8. DropStore will prompt you to restore an old backup from the configured cloud servers (if there is any)
```
Do you like to restore an old backup from the cloud [y/n]?
```

9. Finally, DropStore is ready and you can access it from the Edge devices. Upload/Download your files and it will take care of the periodic backups to the cloud servers.
```
######################################################################################################################

# DropStore Setup was Successfully Done !

# CAUTION: DropStore Retrieval Information was saved in:
#    /opt/dropstore/config
# Please save it in a secure external storage for disaster recovery.

#######################################################################################################################
```

## Raspberry Pi Preparation

DropStore can be installed on a Raspberry Pi that can be used as an always connected device. To prepare Raspberry Pi for DropStore installation, follow these steps:

* Insert an SD Card in your computre.
* Open a terminal and run `lsblk -p` to locate the SD Card (Usually the SD Card appears as `/dev/mmcblk0`).
* Unmount the card if it is mounted.
* Download the Raspberry Pi OS from [Raspberry Pi Official Site](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit). ***Raspberry Pi OS Lite*** is enough for DropStore.
* Unpack the downloaded OS on the SD Card using the following command:
```
$ unzip -p 2021-01-11-raspios-buster-armhf-lite.zip | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync status=progress
```
* After finishing, the SD Card will have two partitions (`boot` and `rootfs`).
* Now you can insert the SD Card in the board and connect a mouse, keyboard, and screen to use it.
* If you do not have a mouse and a screen to use with the board, you can enable and use ssh as follows:
	* After unpacking the OS zip file on the SD Card, reinsert the card in your computer (the `boot` and `rootfs` partitions will be mounted).
	* Create an empty file in the `boot` partition with name of `ssh`
  ```
  $ touch /media/${USER}/boot/ssh
  ```
	* Insert the SD Card in the board and connect it to the LAN using an ethernet cable.
	* Power up the board and wait some time until it boots.
	* Now you can ssh to the board without the need to connect a screen to the board:
  ```
  $ ssh pi@ip # Default password is `raspberry`
  ```
		* You can get the IP of the board from your router web interface.
	* Now you can install DropStore as specified in the previous section.
