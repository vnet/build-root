# depends on gmp
mpfr_configure_depend = gmp-install

mpfr_CPPFLAGS = $(call installed_includes_fn, gmp)

mpfr_LDFLAGS = $(call installed_libs_fn, gmp)
