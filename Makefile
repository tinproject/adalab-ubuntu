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



clean:
	rm -rf build/*

clean-full: clean
	rm -rf dist/*
	rm -rf downloads/*

