# Adalab Ubuntu

This repository creates an autmate Ubuntu Linux image for Adalab.

## Image creation

The process is meant to be done on Debian/Ubuntu/Mint GNU/Linux distributions.

### Prerequisites

The process needs this packages:
```bash
sudo apt-get update
sudo apt-get install -y wget gnupg xorriso isolinux
```

### Create the image

First you need to download locally the Ubuntu image. To do so run:

```bash
make download
```

It downloads and verify the athenticity of the Ubuntu image.

To create the Adalab custom Ubuntu image run:

```bash
make create-iso-image
```

When the process is finished a iso image will be ready con the `dist` folder.
Just burn into a DVD or to a USB stick using the same process of the Raspberry Pi images.


## Install & provision Adalab Ubuntu

Once burned the image on a DVD or on an USB pendrive use it to start the installation.

The installation process should be completely automatic, whitout any promot.
 
*WARNING*: The installer will *erase the disk* so *all the existing data will be lost*.

After the install is finished the system will reboot automatically. At this point the install media will not be needed 
so it can be removed.

Once rebooted the computer will show a normal login screen. The provision step is not executed yet, it will be executed 
in background using a systemd timer that start 4 minutes after the computer boots, and will finish removing itself and 
shutting down the computer when done. It should not require any attention from the operator.

## Links & other documentation

- https://askubuntu.com/questions/806820/how-do-i-create-a-completely-unattended-install-of-ubuntu-desktop-16-04-1-lts
- https://help.ubuntu.com/community/InstallCDCustomization
- https://help.ubuntu.com/lts/installation-guide/amd64/index.html
- https://github.com/tinproject/packer-esxi-iso-example




