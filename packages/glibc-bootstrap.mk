glibc-bootstrap_source = glibc

# Need linux includes to build glibc
glibc-bootstrap_configure_depend = gcc-bootstrap-install linux-install

# Point GLIBC at installed Linux headers
glibc-bootstrap_configure_args = --with-headers=$(TARGET_TOOL_INSTALL_DIR)/include

# Override default prefix of $(PACKAGE_INSTALL_DIR)
glibc-bootstrap_configure_prefix = --prefix=/usr

# This saves a bit of time
glibc-bootstrap_configure_args += --disable-profile

# Platform dependent configure flags
glibc-bootstrap_configure_args += $(glibc-bootstrap_configure_args_$(PLATFORM))

# Hack to allow glibc to compile with static libgcc.a
glibc-bootstrap_make_args = glibc_bootstrap_kludge=yes

# install everything in the tool install area
glibc-bootstrap_make_args += prefix= install_root=$(TARGET_TOOL_INSTALL_DIR)

# parallel build
glibc-bootstrap_make_args += PARALLELMFLAGS="$(MAKE_PARALLEL_FLAGS)"

glibc-bootstrap_install = $(PACKAGE_MAKE) $(glibc-bootstrap_make_args) install
