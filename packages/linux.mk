# Map our notion of ARCH to Linux kernel Makefile's.
LINUX_MAKEFILE_ARCH =				\
   ${shell case '$(ARCH)' in			\
      (i*86*) echo i386 ;;			\
      (x86_64) echo x86_64 ;;			\
      (ppc*|powerpc*) echo powerpc ;;		\
      (*) echo '$(ARCH)' ;;			\
     esac }

LINUX_ARCH =										\
  $(if $($(PLATFORM)_linux_arch),$($(PLATFORM)_linux_arch),$(LINUX_MAKEFILE_ARCH))

linux_build_dir = linux-$(PLATFORM)

LINUX_MAKE =						\
  $(MAKE) -C $(call find_source_fn,$(PACKAGE_SOURCE))	\
    O=$(PACKAGE_BUILD_DIR)				\
    ARCH=$(LINUX_ARCH)					\
    CROSS_COMPILE=$(TARGET)-

linux_config_files_for_platform =							\
  $(call find_build_data_file_fn,packages/linux-default-$(LINUX_MAKEFILE_ARCH).config)	\
  $(call find_build_data_file_fn,packages/linux-$(ARCH).config)				\
  $(call find_build_data_file_fn,packages/linux-$(PLATFORM).config)

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
	$(LINUX_MAKE) oldconfig ;							\
  } ;											\
  $(LINUX_MAKE) Makefile prepare archprepare

# kernel configure depends on config file fragments for platform
linux_configure_depend = $(linux_config_files_for_platform)

linux_build =					\
  : nothing to do

# Install kernel headers for glibc build
# Setting "unwanted" to the NULL string prevents this target from trashing the
# glibc headers. See .../linux/scripts/Makefile.headersinst.
linux_install = \
  i=$(TARGET_TOOL_INSTALL_DIR) ; \
  mkdir -p $$i ; \
  $(LINUX_MAKE) INSTALL_HDR_PATH="$$i" unwanted= headers_install
