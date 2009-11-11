ngen_configure_depend = clib-install

ngen_CPPFLAGS = $(call installed_includes_fn, clib)

ngen_LDFLAGS = $(call installed_libs_fn, clib)
