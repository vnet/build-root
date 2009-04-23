jffs2_configure_depend = zlib-install lzo-install

jffs2_CPPFLAGS += -I$(TOOL_INSTALL_DIR)/include
jffs2_LDFLAGS += -L$(TOOL_INSTALL_DIR)/lib$($(ARCH)_libdir)
