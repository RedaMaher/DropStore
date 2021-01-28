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
