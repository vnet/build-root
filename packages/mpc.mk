mpc_configure_depend = gmp-install mpfr-install

mpc_CPPFLAGS = $(call installed_includes_fn, gmp mpfr)
mpc_LDFLAGS = $(call installed_libs_fn, gmp mpfr)
