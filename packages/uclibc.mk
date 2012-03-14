# Need linux includes to build uclibc
uclibc_configure_depend = gcc-bootstrap-install linux-install

UCLIBC_MAKE =					\
  $(MAKE) -C $(call find_source_fn,uclibc)	\
    O=$(PACKAGE_BUILD_DIR)			\
    CROSS_COMPILE=$(TARGET)-

uclibc_config_files_for_platform =							\
  $(call find_package_file_fn,uclibc,uclibc-$(ARCH).config)				\
  $(call find_package_file_fn,uclibc,uclibc-$(PLATFORM).config)

# Copy pre-built uclibc config into compile directory
# Move include files to install area for compiling glibc
uclibc_configure =									\
  mkdir -p $(PACKAGE_BUILD_DIR) ;							\
  : construct uclibc config from ARCH and PLATFORM specific pieces ;			\
  b="`mktemp $(PACKAGE_BUILD_DIR)/.tmp-config-XXXXXX`" ;				\
  if [ "`echo $(uclibc_config_files_for_platform)`" != "" ]; then			\
    cat $(uclibc_config_files_for_platform) >> $${b} ;					\
    echo "KERNEL_HEADERS=\"$(TARGET_TOOL_INSTALL_DIR)/include\"" >> $${b} ;		\
  fi ;											\
  if [ '0' = `wc -c $${b} | awk '{ print $$1; }'` ]; then				\
    $(call build_msg_fn,No uClibc config for platform $(PLATFORM) or arch $(ARCH)) ;	\
  else											\
    $(call build_msg_fn,uClibc config for platform $(PLATFORM)				\
        from $(uclibc_config_files_for_platform)) ;					\
  fi ;											\
  : compare config with last used config ;						\
  l=$(PACKAGE_BUILD_DIR)/.last-config ;							\
  c=$(PACKAGE_BUILD_DIR)/.config ;							\
  cmp --quiet $$b $$l || {								\
	mv $$b $$l ;									\
	cp $$l $$c ;									\
	$(UCLIBC_MAKE) oldconfig ;							\
  }

# kernel configure depends on config file fragments for platform
uclibc_configure_depend += $(uclibc_config_files_for_platform)

%-mconfig: %-configure
	@$(BUILD_ENV) ;											\
	cd $(PACKAGE_BUILD_DIR) ;									\
	: call uClibc makefile to perform config ;							\
	$(UCLIBC_MAKE) menuconfig ;									\
	: copy back resulting config if changed ;							\
	orig="$(call find_build_data_dir_for_package_fn,uclibc)/packages/uclibc-$(PLATFORM).config" ;	\
	cmp --quiet $${orig} .config || cp .config  $${orig}

# uclibc_verbose = V=2

uclibc_build =					\
  cd $(PACKAGE_BUILD_DIR) ;			\
  $(UCLIBC_MAKE) $(uclibc_verbose) $(MAKE_PARALLEL_FLAGS)

uclibc_install =				\
  $(UCLIBC_MAKE)				\
    $(uclibc_verbose)				\
    PREFIX=$(TARGET_TOOL_INSTALL_DIR)		\
    DEVEL_PREFIX=/				\
    RUNTIME_PREFIX=/				\
    install

uclibc_clean = $(UCLIBC_MAKE) clean
