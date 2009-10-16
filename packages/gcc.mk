# GCC install depends on ranlib from binutils
gcc_configure_depend = glibc-install binutils-install

gcc_configure_host_and_target = --target=$(TARGET)

# gcc_make_parallel_fails = yes

gcc_configure_args += --enable-languages=c

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
