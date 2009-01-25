# Map our notion of ARCH to Linux kernel's.
BASIC_LINUX_ARCH = \
   ${shell case '$(ARCH)' in \
      (i*86*) echo i386 ;; \
      (ppc*|powerpc*) echo powerpc ;; \
      (*) echo '$(ARCH)' ;; \
     esac }

LINUX_ARCH = \
  $(if $($(PLATFORM)_linux_arch),$($(PLATFORM)_linux_arch),$(BASIC_LINUX_ARCH))

LINUX_BUILD_DIR = $(BUILD_DIR)/linux-$(PLATFORM)

LINUX_MAKE = \
  $(MAKE) -C $(call find_source_fn,linux) \
    O=$(LINUX_BUILD_DIR) \
    ARCH=$(LINUX_ARCH) \
    CROSS_COMPILE=$(TARGET)-

# Copy pre-built linux config into compile directory
# Move include files to install area for compiling glibc
linux_configure = \
  mkdir -p $(LINUX_BUILD_DIR) ; \
  : construct linux config from ARCH and PLATFORM specific pieces ; \
  b="`mktemp $(LINUX_BUILD_DIR)/.tmp-config-XXXXXX`" ; \
  f="$(call find_package_file_fn,linux,linux-$(ARCH).config)" ; \
  [[ -f "$${f}" ]] && cat $${f} >> $${b} ; \
  f="$(call find_package_file_fn,linux,linux-$(PLATFORM).config)" ; \
  [[ -f "$${f}" ]] && cat $${f} >> $${b} ; \
  : compare config with last used config ; \
  l=$(LINUX_BUILD_DIR)/.last-config ; \
  c=$(LINUX_BUILD_DIR)/.config ; \
  cmp --quiet $$b $$l || { \
	cp $$b $$l ; \
	cp $$b $$c ; \
	$(LINUX_MAKE) oldconfig ; \
  } ; \
  $(LINUX_MAKE) Makefile prepare archprepare ; \
  [[ "$(LINUX_ARCH)" = "um" ]] && \
    ln -sf $(call find_source_fn,linux)/include/asm-$(BASIC_LINUX_ARCH) \
      $(LINUX_BUILD_DIR)/arch/um/include/asm

LINUX_BUILD_TARGET = \
   ${shell case '$(ARCH)' in \
      (ppc*|powerpc*) echo zImage.initrd ;; \
      (*) echo "vmlinux" ;; \
     esac }

linux_build_depend = $(call find_package_file_fn,linux,linux-$(PLATFORM).config)

# ARCH dependent initrd
linux_initrd_powerpc = arch/powerpc/boot/ramdisk.image.gz

# Add dependency for initrd if its built into linux image
ifneq (,$(linux_initrd_$(LINUX_ARCH)))
  linux_build_depend += linuxrc-install $(INSTALL_DIR)/linuxrc/initrd.img
endif

linux_build = \
  cd $(LINUX_BUILD_DIR) ; \
  : copy embedded initrd into place for platforms that support one ; \
  [[ -n "$(linux_initrd_$(LINUX_ARCH))" ]] \
    && mkdir -p "`dirname $(linux_initrd_$(LINUX_ARCH))`" \
    && gzip -9 -c $(INSTALL_DIR)/linuxrc/initrd.img \
         > $(LINUX_BUILD_DIR)/$(linux_initrd_$(LINUX_ARCH)) ; \
  $(LINUX_MAKE) $(LINUX_BUILD_TARGET) modules

linux_install = \
  cd $(LINUX_BUILD_DIR) ; \
  : nothing to do for now

linux_clean = rm -rf $(LINUX_BUILD_DIR)

# Install kernel headers for glibc build
linux-install-headers: linux-find-source
	@$(call build_msg_fn,Install linux headers in $(TARGET_TOOL_INSTALL_DIR)) ; \
	$(BUILD_ENV) ; \
	default_platform="default-$(ARCH)" ; \
	$(TOOL_MAKE) PLATFORM=$${default_platform} linux-configure ; \
	i=$(TARGET_TOOL_INSTALL_DIR) ; \
	mkdir -p $$i ; \
	$(MAKE) -C $(call find_source_fn,linux) \
	    O=$(BUILD_DIR)/linux-$${default_platform} \
	    ARCH=$(LINUX_ARCH) \
	    CROSS_COMPILE=$(TARGET)- \
		INSTALL_HDR_PATH="$$i" headers_install

linux_update_config_fn = \
  @$(BUILD_ENV) ; \
  cd $(LINUX_BUILD_DIR) ; \
  tmp="`mktemp .config-XXXXXX`" ; \
  cp .config $${tmp} ; \
  $(LINUX_MAKE) $(1) ; \
  : copy back resulting config if changed ; \
  cmp --quiet $${tmp} .config \
    || cp .config $(call find_package_file_fn,linux,linux-$(PLATFORM).config) ; \
  rm -f $${tmp}

linux-gconfig linux-xconfig linux-menuconfig: linux-configure
	$(call linux_update_config_fn, $(patsubst linux-%,%,$@))
