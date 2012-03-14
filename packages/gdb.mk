gdb_source = gdb

gdb_configure_args = --disable-nls
gdb_configure_args += --disable-multi-ice
gdb_configure_args += --disable-gdbtk
gdb_configure_args += --disable-netrom
gdb_configure_args += --disable-sim
gdb_configure_args += --disable-tui
gdb_configure_args += --disable-profiling
gdb_configure_args += --with-mmalloc=no
gdb_configure_args += --with-included-regex=no
gdb_configure_args += --with-included-gettext=no
gdb_configure_args += --with-uiout=no

# gdb currently does not compile with -Werror for gcc-3.4.2
gdb_configure_args += --disable-werror

gdb_LDFLAGS = -L$(TOOL_INSTALL_DIR)/lib$(native_libdir)

gdb_configure_host_and_target = --target=$(TARGET)

gdb_make_parallel_fails = yes
