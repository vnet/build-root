cxx_configure_depend = gcc-install glibc-install

cxx_source = gcc

cxx_configure_host_and_target = --target=$(TARGET)

# Remove unneeded stuff
cxx_configure_args = --disable-nls
cxx_configure_args += --disable-multilib
cxx_configure_args += --disable-libmudflap
cxx_configure_args += --disable-libssp
cxx_configure_args += --disable-libgomp

# Don't want libgcc.a to be shared; this breaks cross-build
cxx_configure_args += --disable-shared

# Depends on GLIBC
cxx_configure_args += --enable-decimal-float=no

cxx_configure_args += --enable-languages=c++

# Newer versions of GCC depend on MPFR/GMP libraries
cxx_configure_args += \
  --with-mpfr-include=$(call installed_include_fn,mpfr) \
  --with-mpfr-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)
cxx_configure_args += \
  --with-gmp-include=$(call installed_include_fn,gmp) \
  --with-gmp-lib=$(TOOL_INSTALL_DIR)/lib$(native_libdir)

