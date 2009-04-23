spp_configure_depend = clib-install

spp_CPPFLAGS = $(call installed_includes_fn, clib)
spp_LDFLAGS = $(call installed_libs_fn, clib)
