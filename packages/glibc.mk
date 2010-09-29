# Need linux includes to build glibc
glibc_configure_depend = gcc-bootstrap-install linux-install

# Point GLIBC at installed Linux headers
glibc_configure_args = --with-headers=$(TARGET_TOOL_INSTALL_DIR)/linux/include

# Override default prefix of $(PACKAGE_INSTALL_DIR)
glibc_configure_prefix = --prefix=/usr

# This saves a bit of time
glibc_configure_args += --disable-profile

# Platform dependent configure flags
glibc_configure_args += $(glibc_configure_args_$(PLATFORM))

# Hack to allow glibc to compile with static libgcc.a
glibc_make_args = libgcc_eh=-lgcc static-gnulib=-lgcc

# GLIBC -j 16 does not make install properly on some machines.
# Is this still true? Yes it is..

glibc_make_parallel_fails = yes

glibc_install = \
  $(PACKAGE_MAKE) \
    prefix= \
    install_root=$(TARGET_TOOL_INSTALL_DIR) \
    install install-headers
