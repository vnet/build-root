# e2fsimage depends on e2fsprogs library
e2fsimage_configure_depend = e2fsprogs-install

e2fsimage_CPPFLAGS = -I$(TOOL_INSTALL_DIR)/include
e2fsimage_LDFLAGS = -L$(TOOL_INSTALL_DIR)/lib$($(ARCH)_libdir)

