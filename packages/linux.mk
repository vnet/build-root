# Map our notion of ARCH to Linux kernel's.
BASIC_LINUX_ARCH = \
   ${shell case '$(ARCH)' in \
      (i*86*) echo i386 ;; \
      (ppc*|powerpc*) echo powerpc ;; \
      (*) echo '$(ARCH)' ;; \
     esac }

# Arch could be e.g. ppc7450 which we map to e.g. ppc
DEFAULT_LINUX_ARCH = \
   ${shell case '$(ARCH)' in \
      (i*86*) echo i386 ;; \
      (ppc*|powerpc*) echo ppc ;; \
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
  f="$(call find_package_file_fn,linux,linux-default-$(DEFAULT_LINUX_ARCH).config)" ; \
  [[ -f "$${f}" ]] && cat $${f} >> $${b} ; \
  f="$(call find_package_file_fn,linux,linux-$(ARCH).config)" ; \
  [[ -f "$${f}" ]] && cat $${f} >> $${b} ; \
  f="$(call find_package_file_fn,linux,linux-$(PLATFORM).config)" ; \
  [[ -f "$${f}" ]] && cat $${f} >> $${b} ; \
  if [ '0' = `wc -c $${b} | awk '{ print $$1; }'` ]; then \
    $(call build_msg_fn,No Linux config for platform $(PLATFORM) or arch $(ARCH)) ; \
    exit 1; \
  fi ; \
  : compare config with last used config ; \
  l=$(LINUX_BUILD_DIR)/.last-config ; \
  c=$(LINUX_BUILD_DIR)/.config ; \
  cmp --quiet $$b $$l || { \
	cp $$b $$l ; \
	cp $$b $$c ; \
	$(LINUX_MAKE) oldconfig ; \
  } ; \
  $(LINUX_MAKE) Makefile prepare archprepare

# Install kernel headers for glibc build
linux-install-headers: linux-configure
	@$(call build_msg_fn,Install linux headers in $(TARGET_TOOL_INSTALL_DIR)) ; \
	$(BUILD_ENV) ; \
	i=$(TARGET_TOOL_INSTALL_DIR) ; \
	mkdir -p $$i ; \
	$(LINUX_MAKE) INSTALL_HDR_PATH="$$i" headers_install
