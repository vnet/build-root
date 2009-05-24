binutils_configure_host_and_target = --target=$(TARGET)

binutils_configure_args = --disable-nls
binutils_configure_args += --with-sysroot=$(TARGET_TOOL_INSTALL_DIR)

# this doesn't even seem to be enough!
binutils_make_parallel_fails = yes

