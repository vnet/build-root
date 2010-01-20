sign_configure_depend = clib-install

sign_CPPFLAGS = $(call installed_includes_fn, clib)

sign_LDFLAGS = $(call installed_libs_fn, clib)
