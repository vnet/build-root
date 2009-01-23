# to find installed zlib
squashfs_CPPFLAGS = -I$(TOOL_INSTALL_DIR)/include
squashfs_LDFLAGS = -L$(TOOL_INSTALL_DIR)/lib$(native_libdir)
