# GCC install depends on ranlib from binutils
gcc_configure_depend = $(libc_for_platform)-bootstrap-install binutils-install

gcc_configure_host_and_target = --target=$(TARGET)

# gcc_make_parallel_fails = yes

# kludge to get x86_64 toolchain to build on x86_64
# see gcc/configure.ac
gcc_configure_env_x86_64 += GCC_CANADIAN_CROSS_LIB_SUFFIX=64

gcc_configure_env += $(gcc_configure_env_$(ARCH))

# Remove unneeded stuff
gcc_configure_args = --disable-nls
gcc_configure_args += --enable-multilib=no
gcc_configure_args += --disable-libmudflap
gcc_configure_args += --disable-libssp
gcc_configure_args += --disable-libgomp
gcc_configure_args += --disable-libquadmath

gcc_configure_args += --enable-languages=c

# Newer versions of GCC depend on MPFR/GMP libraries
gcc_configure_args += \
  --with-mpfr-include=$(call installed_include_dir_fn,mpfr) \
  --with-mpfr-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
gcc_configure_args += \
  --with-gmp-include=$(call installed_include_dir_fn,gmp) \
  --with-gmp-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
gcc_configure_args += \
  --with-mpc-include=$(call installed_include_dir_fn,mpc) \
  --with-mpc-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)

# Could put $(ARCH) dependent flags here
# For example, if $(ARCH)=foo
# gcc_configure_args_foo = --enable-foo-bar

# Architecture dependent configure flags
gcc_configure_args += $(gcc_configure_args_$(ARCH))

# Platform dependent configure flags
gcc_configure_args += $(gcc_configure_args_$(PLATFORM))

# We need LIMITS_H_TEST=true to appease gcc/gcc/Makefile.in
# Otherwise gcc-lib/include/limits.h will be missing #include_next <limits.h>
# to pick up the linux's limits.h
gcc_make_args += LIMITS_H_TEST=true
