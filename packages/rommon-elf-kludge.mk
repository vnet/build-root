rommon-elf-kludge_configure_depend = clib-install

rommon-elf-kludge_CPPFLAGS = $(call installed_includes_fn, clib)

rommon-elf-kludge_LDFLAGS = $(call installed_libs_fn, clib)
