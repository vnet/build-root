binutils_configure_host_and_target = --target=$(TARGET)

binutils_configure_args = --disable-nls

binutils_configure_args += --with-sysroot=$(TARGET_TOOL_INSTALL_DIR)

# binutils 2.20 won't compile with -Werror on
binutils_configure_args += --disable-werror

