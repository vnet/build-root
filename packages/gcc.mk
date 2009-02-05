# GCC install depends on ranlib from binutils
gcc_configure_depend = binutils-install

gcc_configure_host_and_target = --target=$(TARGET)

# Remove unneeded stuff
gcc_configure_args = --disable-nls
gcc_configure_args += --disable-multilib
gcc_configure_args += --disable-libmudflap
gcc_configure_args += --disable-libssp
gcc_configure_args += --disable-libgomp

# Don't want libgcc.a to be shared; this breaks cross-build
gcc_configure_args += --disable-shared

# Depends on GLIBC
gcc_configure_args += --enable-decimal-float=no

# Only need C compiler
gcc_configure_args += --enable-languages=c

# Disables threads in libgcc.a.  Otherwise we would depend on GLIBC
# while compiling GCC (chicken & egg problem)
gcc_configure_args += --enable-threads=single

# Newer versions of GCC depend on MPFR/GMP libraries
gcc_configure_args += \
  --with-mpfr-include=$(call installed_include_fn,mpfr) \
  --with-mpfr-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
gcc_configure_args += \
  --with-gmp-include=$(call installed_include_fn,gmp) \
  --with-gmp-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)

# Could put $(ARCH) dependent flags here
# For example, if $(ARCH)=foo
# gcc_configure_args_foo = --enable-foo-bar

gcc_configure_args_armiwmmxt = --with-arch=iwmmxt --with-abi=iwmmxt

# Architecture dependent configure flags
gcc_configure_args += $(gcc_configure_args_$(ARCH))

# Platform dependent configure flags
gcc_configure_args += $(gcc_configure_args_$(PLATFORM))

# We need LIMITS_H_TEST=true to appease gcc/gcc/Makefile.in
# Otherwise gcc-lib/include/limits.h will be missing #include_next <limits.h>
# to pick up the linux's limits.h
gcc_make_args += LIMITS_H_TEST=true

gcc_make_args += \
  LIBGCC2_INCLUDES="-idirafter $(PACKAGE_BUILD_DIR)/limits_h_kludge"

gcc_build = \
  mkdir -p $(PACKAGE_BUILD_DIR)/limits_h_kludge ; \
  touch $(PACKAGE_BUILD_DIR)/limits_h_kludge/limits.h ; \
  $(PACKAGE_MAKE) ; \
  rm -rf $(PACKAGE_BUILD_DIR)/limits_h_kludge
