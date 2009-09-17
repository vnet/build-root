apigen_configure_depend = clib-install

apigen_CPPFLAGS = $(call installed_includes_fn, clib)

apigen_LDFLAGS = $(call installed_libs_fn, clib)
