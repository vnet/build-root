# GCC install depends on ranlib from binutils
cxx_source = gcc
cxx_configure_depend = gcc-install glibc-install
is_build_tool = yes
cxx_configure_host_and_target = --target=$(TARGET)

# cxx_make_parallel_fails = yes

# kludge to get x86_64 toolchain to build on x86_64
# see gcc/configure.ac
cxx_configure_env_x86_64 += GCC_CANADIAN_CROSS_LIB_SUFFIX=64

cxx_configure_env += $(cxx_configure_env_$(ARCH))

cxx_configure_args += --enable-multilib=no

cxx_configure_args += --enable-languages=c
cxx_configure_args += --enable-languages=c++

# Newer versions of GCC depend on MPFR/GMP libraries
cxx_configure_args += \
  --with-mpfr-include=$(call installed_include_fn,mpfr) \
  --with-mpfr-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
cxx_configure_args += \
  --with-gmp-include=$(call installed_include_fn,gmp) \
  --with-gmp-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)

# Could put $(ARCH) dependent flags here
# For example, if $(ARCH)=foo
# cxx_configure_args_foo = --enable-foo-bar

cxx_configure_args_armiwmmxt = --with-arch=iwmmxt --with-abi=iwmmxt

# Architecture dependent configure flags
cxx_configure_args += $(cxx_configure_args_$(ARCH))

# Platform dependent configure flags
cxx_configure_args += $(cxx_configure_args_$(PLATFORM))

# We need LIMITS_H_TEST=true to appease gcc/gcc/Makefile.in
# Otherwise gcc-lib/include/limits.h will be missing #include_next <limits.h>
# to pick up the linux's limits.h
cxx_make_args += LIMITS_H_TEST=true

cxx_make_args += \
  LIBGCC2_INCLUDES="-idirafter $(PACKAGE_BUILD_DIR)/limits_h_kludge"

cxx_build = \
  mkdir -p $(PACKAGE_BUILD_DIR)/limits_h_kludge ; \
  touch $(PACKAGE_BUILD_DIR)/limits_h_kludge/limits.h ; \
  $(PACKAGE_MAKE) ; \
  rm -rf $(PACKAGE_BUILD_DIR)/limits_h_kludge
