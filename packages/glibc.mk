# Need linux includes to build glibc
glibc_configure_depend = gcc-install linux-install

# Point GLIBC at installed Linux headers
glibc_configure_args = --with-headers=$(TARGET_TOOL_INSTALL_DIR)/include

# Override default prefix of $(PACKAGE_INSTALL_DIR)
glibc_configure_prefix = --prefix=/usr

# Platform dependent configure flags
glibc_configure_args += $(glibc_configure_args_$(PLATFORM))

# install everything in the tool install area
glibc_make_args += prefix= install_root=$(TARGET_TOOL_INSTALL_DIR)

# parallel build
glibc_make_args += PARALLELMFLAGS="$(MAKE_PARALLEL_FLAGS)"

# glibc as of 2.14.1 does not install {rpc,rpcsvc}/*.h needed by various things
glibc_install =											\
  $(PACKAGE_MAKE) $(glibc_make_args) install ;							\
  echo mkdir -p $(TARGET_TOOL_INSTALL_DIR)/include/{rpc,rpcsvc} ;					\
  echo cp $(call find_source_fn,glibc)/sunrpc/rpc/*.h $(TARGET_TOOL_INSTALL_DIR)/include/rpc ;	\
  echo cp $(call find_source_fn,glibc)/sunrpc/rpcsvc/*.h $(TARGET_TOOL_INSTALL_DIR)/include/rpcsvc ;	\
  echo cp $(call find_source_fn,glibc)/nis/rpcsvc/*.h $(TARGET_TOOL_INSTALL_DIR)/include/rpcsvc
