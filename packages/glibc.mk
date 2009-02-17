# Need linux includes to build glibc
glibc_configure_depend = gcc-install linux-install

# Point GLIBC at installed Linux headers
glibc_configure_args = --with-headers=$(TARGET_TOOL_INSTALL_DIR)/include

# Override default prefix of $(PACKAGE_INSTALL_DIR)
glibc_configure_prefix = --prefix=/usr

# This saves a bit of time
glibc_configure_args += --disable-profile

# Hack to allow glibc to compile with static libgcc.a
glibc_make_args = libgcc_eh=-lgcc static-gnulib=-lgcc

# GLIBC -j 16 does not make install properly on some machines
glibc_make_parallel_fails = yes

glibc_install = \
  $(PACKAGE_MAKE) \
    prefix= \
    install_root=$(TARGET_TOOL_INSTALL_DIR) \
    install install-headers
