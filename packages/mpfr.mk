# depends on gmp
mpfr_configure_depend = gmp-install

# won't bootstrap without it
mpfr_configure_args = --disable-maintainer-mode
