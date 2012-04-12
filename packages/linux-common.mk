# Map our notion of ARCH to Linux kernel Makefile's.
linux_makefile_arch =				\
   ${shell case '$(ARCH)' in			\
      (i*86*) echo i386 ;;			\
      (x86_64) echo x86_64 ;;			\
      (ppc*|powerpc*) echo powerpc ;;		\
      (tic6x*) echo c6x ;;			\
      (*) echo '$(ARCH)' ;;			\
     esac }

linux_arch =										\
  $(if $($(PLATFORM)_linux_arch),$($(PLATFORM)_linux_arch),$(linux_makefile_arch))

linux_build_dir = linux-$(PLATFORM)

linux_make =						\
  $(MAKE) -C $(call find_source_fn,$(PACKAGE_SOURCE))	\
    O=$(PACKAGE_BUILD_DIR)				\
    ARCH=$(linux_arch)					\
    CROSS_COMPILE=$(TARGET)-

linux_main_config_file_for_platform = \
  $(call find_build_data_dir_for_platform_fn,$(PLATFORM))/packages/linux-$(PLATFORM).config

linux_config_files_for_platform = $(linux_main_config_file_for_platform)

# Copy pre-built linux config into compile directory
# Move include files to install area for compiling glibc
linux_configure =									\
  mkdir -p $(PACKAGE_BUILD_DIR) ;							\
  : construct linux config from ARCH and PLATFORM specific pieces ;			\
  b="`mktemp $(PACKAGE_BUILD_DIR)/.tmp-config-XXXXXX`" ;				\
  if [ "`echo $(linux_config_files_for_platform)`" != "" ]; then			\
    cat $(linux_config_files_for_platform) >> $${b} ;					\
  fi ;											\
  if [ '0' = `wc -c $${b} | awk '{ print $$1; }'` ]; then				\
    $(call build_msg_fn,No Linux config for platform $(PLATFORM) or arch $(ARCH)) ;	\
    exit 1;										\
  fi ;											\
  $(call build_msg_fn,Linux config for platform $(PLATFORM)				\
      from $(linux_config_files_for_platform)) ;					\
  : compare config with last used config ;						\
  l=$(PACKAGE_BUILD_DIR)/.last-config ;							\
  c=$(PACKAGE_BUILD_DIR)/.config ;							\
  cmp --quiet $$b $$l || {								\
	cp $$b $$l ;									\
	cp $$b $$c ;									\
	$(linux_make) oldconfig ;							\
  } ;											\
  $(linux_make) Makefile prepare archprepare

# kernel configure depends on config file fragments for platform
linux_configure_depend = $(linux_config_files_for_platform)

%-gconfig %-xconfig %-menuconfig:
	@$(BUILD_ENV) ;											\
	if [ "$(PACKAGE)" != linux ]; then								\
	  $(call build_msg_fn, Config targets only apply to linux);					\
	  exit 1;											\
	fi ;												\
	mkdir -p $(PACKAGE_BUILD_DIR) ;									\
	cd $(PACKAGE_BUILD_DIR) ;									\
	: call linux makefile to perform config ;							\
	$(linux_make) $(patsubst linux-%,%,$@) ;							\
	: copy back resulting config if changed ;							\
	orig="$(linux_main_config_file_for_platform)" ;							\
	if cmp --quiet $${orig} .config ; then								\
	  $(call build_msg_fn, Linux config unchanged $(linux_main_config_file_for_platform)) ;		\
	else												\
	  $(call build_msg_fn, Saving changed linux config to $(linux_main_config_file_for_platform)) ;	\
	  cp .config  $${orig} ;									\
	fi
