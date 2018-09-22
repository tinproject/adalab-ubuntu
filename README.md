# Adalab Ubuntu

This repository creates an automated Ubuntu Linux image for Adalab's laptop provisioning.

## Image creation

The process is meant to be done on Debian/Ubuntu/Mint GNU/Linux distributions.

### Prerequisites

The process needs this packages to be installed:
```bash
sudo apt-get update
sudo apt-get install -y make wget gnupg xorriso isolinux
```

### Create the image

First you need to download locally the Ubuntu image. To do so run:

```bash
make download
```

It downloads and verify the authenticity of the Ubuntu image.

To create the Adalab custom Ubuntu image run:

```bash
make create-iso-image
```

When the process is finished a iso image will be ready on the `dist` folder.

Just burn into a DVD or to a USB stick using the same process of the Raspberry Pi images. 
('USB image recorder' from Linux Mint works perfectly for this function.)

## Install & provision Adalab Ubuntu

Once burned the image on a DVD or on an USB pendrive use it to start the installation.

The installation process should be completely automatically, without any operator intervention.
 
**WARNING**: The installer will **erase the whole computer disk** so **all the existing data will be lost**.

After the Ubuntu install is finished the system will reboot automatically. At this point the install media will not be 
needed so it can be removed and used to provision another machine.

Once rebooted, the computer will show a normal login screen but he provision step is not executed yet. 
It will be executed in background using a systemd timer that start 3 minutes after the computer boots, 
and will finish removing itself and shutting down the computer when done. 

When the computer poweroff itself the installation is done and is ready to use by end users.
It should not require any attention from the operator. 

## Links & other documentation

- https://askubuntu.com/questions/806820/how-do-i-create-a-completely-unattended-install-of-ubuntu-desktop-16-04-1-lts
- https://help.ubuntu.com/community/InstallCDCustomization
- https://help.ubuntu.com/lts/installation-guide/amd64/index.html
- https://github.com/tinproject/packer-esxi-iso-example
