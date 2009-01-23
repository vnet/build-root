toolgdb_source = gdb

toolgdb_configure_args = --disable-nls
toolgdb_configure_args += --disable-multi-ice
toolgdb_configure_args += --disable-gdbtk
toolgdb_configure_args += --disable-netrom
toolgdb_configure_args += --disable-sim
toolgdb_configure_args += --disable-tui
toolgdb_configure_args += --disable-profiling
toolgdb_configure_args += --with-mmalloc=no
toolgdb_configure_args += --with-included-regex=no
toolgdb_configure_args += --with-included-gettext=no
toolgdb_configure_args += --with-uiout=no

# gdb currently does not compile with -Werror for gcc-3.4.2
toolgdb_configure_args += --disable-werror

toolgdb_configure_host_and_target = --target=$(TARGET)
