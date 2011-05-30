gcc-bootstrap_source = gcc

# GCC install depends on ranlib from binutils
gcc-bootstrap_configure_depend = binutils-install

gcc-bootstrap_configure_host_and_target = --target=$(TARGET)

# gcc-bootstrap_make_parallel_fails = yes

# Remove unneeded stuff
gcc-bootstrap_configure_args = --disable-nls
gcc-bootstrap_configure_args += --disable-multilib
gcc-bootstrap_configure_args += --disable-libmudflap
gcc-bootstrap_configure_args += --disable-libssp
gcc-bootstrap_configure_args += --disable-libgomp

# Don't want libgcc.a to be shared; this breaks cross-build
gcc-bootstrap_configure_args += --disable-shared

# Disables threads in libgcc.a.  Otherwise we would depend on GLIBC
# while compiling GCC (chicken & egg problem)
gcc-bootstrap_configure_args += --enable-threads=single

# Depends on GLIBC
gcc-bootstrap_configure_args += --enable-decimal-float=no

gcc-bootstrap_configure_args += --enable-languages=c

# Newer versions of GCC depend on MPFR/GMP libraries which must
# be installed via native tools install
gcc-bootstrap_configure_args += \
  --with-gmp-include=$(call installed_include_fn,gmp) \
  --with-gmp-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
gcc-bootstrap_configure_args += \
  --with-mpfr-include=$(call installed_include_fn,mpfr) \
  --with-mpfr-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
gcc-bootstrap_configure_args += \
  --with-mpc-include=$(call installed_include_fn,mpc) \
  --with-mpc-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)

# Could put $(ARCH) dependent flags here
# For example, if $(ARCH)=foo
# gcc-bootstrap_configure_args_foo = --enable-foo-bar

gcc-bootstrap_configure_args_armiwmmxt = --with-arch=iwmmxt --with-abi=iwmmxt

# Architecture dependent configure flags
gcc-bootstrap_configure_args += $(gcc-bootstrap_configure_args_$(ARCH))

# Platform dependent configure flags
gcc-bootstrap_configure_args += $(gcc-bootstrap_configure_args_$(PLATFORM))

# We need LIMITS_H_TEST=true to appease gcc/gcc/Makefile.in
# Otherwise gcc-lib/include/limits.h will be missing #include_next <limits.h>
# to pick up the linux's limits.h
gcc-bootstrap_make_args += LIMITS_H_TEST=true

gcc-bootstrap_build =				\
  $(MAKE)					\
    -C $(PACKAGE_BUILD_DIR)			\
    $(MAKE_PARALLEL_FLAGS)			\
    all-host all-target-libgcc

gcc-bootstrap_install =	\
  $(PACKAGE_MAKE) installdirs install-host install-target-libgcc

