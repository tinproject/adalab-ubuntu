.PHONY: clean clean-full download download-check

# Change this to set the Ubuntu version
UBUNTU_VERSION := 18.04
UBUNTU_ISO_NAME := ubuntu-$(UBUNTU_VERSION)-desktop-amd64.iso

#UBUNTU_MIRROR := http://releases.ubuntu.com/
UBUNTU_MIRROR := http://ftp.rediris.es/sites/releases.ubuntu.com/

UBUNTU_BASE_URL := $(UBUNTU_MIRROR)$(UBUNTU_VERSION)
DOWNLOAD_FILES := SHA256SUMS SHA256SUMS.gpg $(UBUNTU_ISO_NAME)

downloads/$(DOWNLOAD_FILES):
	@echo "--> Downloading $(@F)..."
	@wget -nv -N -P downloads --progress=bar:force:noscroll "$(UBUNTU_BASE_URL)/$(@F)"


# Gpg data to check Ubuntu image authenticity https://tutorials.ubuntu.com/tutorial/tutorial-how-to-verify-ubuntu
GPG_SING_KEY_FP1 := 843938DF228D22F7B3742BC0D94AA3F0EFE21092
GPG_SING_KEY_FP2 := C5986B4F1257FFA86632CBA746181433FBB75451
GPG_KEYSERVER := hkp://keyserver.ubuntu.com/

download-check: downloads/$(DOWNLOAD_FILES)
	@echo "--> Checking SHA256SUMS file signature..."
	@export GNUPGHOME=$(mktemp -d)
	@gpg -q --keyserver $(GPG_KEYSERVER) --recv-keys $(GPG_SING_KEY_FP1) > /dev/null
	@gpg -q --keyserver $(GPG_KEYSERVER) --recv-keys $(GPG_SING_KEY_FP2) > /dev/null
	@gpg -q --batch \
		--trusted-key 0x$(shell echo "$(GPG_SING_KEY_FP1)" | cut -c25-) \
		--trusted-key 0x$(shell echo "$(GPG_SING_KEY_FP2)" | cut -c25-) \
		--verify downloads/SHA256SUMS.gpg downloads/SHA256SUMS > /dev/null
	@rm -rf $${GNUPGHOME}

	@echo "--> Checking ISO image SHA sum..."
	@(cd downloads && sha256sum --ignore-missing --check SHA256SUMS)

	@echo "--> Ubuntu ISO image validated!"


download: download-check



clean-build:
	@echo "--> Cleaning build files..."
	@mkdir -p build
	@chmod -R +w build
	@rm -rf build

clean: clean-build

clean-full: clean
	rm -rf dist/*
	rm -rf downloads/*


# This task extract ISO image contents for later modifications
extract-image: clean-build
	@echo "--> Mounting ISO image (needs sudo)..."
	@mkdir -p iso_mount
	@mkdir -p build
	@-sudo mount -o loop downloads/$(UBUNTU_ISO_NAME) iso_mount
	@echo "--> Copying ISO image files to build folder..."
	@-cp -rT ./iso_mount ./build
	@echo "--> Unmounting ISO image (needs sudo)..."
	@sudo umount iso_mount
	@rm -rf iso_mount

# This task change the menu to add
ADALAB_KERNEL_PARAMS=file=/cdrom/custom/adalab.preseed boot=casper automatic-ubiquity initrd=/casper/initrd.lz quiet splash priority=low debian-installer/locale=es_ES keyboard-configuration/layoutcode=es languagechooser/language-name=Spanish countrychooser/shortlist=ES localechooser/supported-locales=es_ES.UTF-8

edit-menu: extract-image
	@echo "--> Modifiying ISOLINUX image menu, add Adalab installer..."
	@chmod +w build/isolinux
	@chmod +w build/isolinux/txt.cfg
#	@sed -i 's/^default.*$$/default\ adalab-install/g' build/isolinux/txt.cfg
	@echo "default adalab-install" > build/isolinux/txt.cfg

	@echo "label adalab-install" >> build/isolinux/txt.cfg
	@echo "  menu label ^Install Adalab Ubuntu" >> build/isolinux/txt.cfg
	@echo "  kernel /casper/vmlinuz" >> build/isolinux/txt.cfg
	@echo "  append	$(ADALAB_KERNEL_PARAMS) ---" >> build/isolinux/txt.cfg
	@echo "" >> build/isolinux/txt.cfg
	@echo "TIMEOUT 50" >> build/isolinux/txt.cfg

	@echo "--> Modifiying GRUB image menu, add Adalab installer..."
	@chmod +w build/boot/grub/grub.cfg
	@echo "menuentry \"Install Adalab Ubuntu\" {" >> build/boot/grub/grub.cfg
	@echo "	set gfxpayload=keep" >> build/boot/grub/grub.cfg
	@echo "	linux	/casper/vmlinuz	$(ADALAB_KERNEL_PARAMS) ---" >> build/boot/grub/grub.cfg
	@echo "	initrd	/casper/initrd.lz" >> build/boot/grub/grub.cfg
	@echo "}" >> build/boot/grub/grub.cfg


# This task add the custom preseed and provision files
copy-custom-files: edit-menu
	@echo "--> Copying custom files (preseed & provision)..."
	@mkdir -p build/custom
	@cp adalab.preseed build/custom/
	@cp adalab_provision.yml build/custom/

create-iso-image: copy-custom-files
	@echo "--> Creating custom Adalab Ubuntu ISO..."
	@xorrisofs -D -r -V "ADALAB_UBUNTU" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat \
		-no-emul-boot -boot-load-size 4 -boot-info-table -o dist/adalab-$(UBUNTU_ISO_NAME) build
