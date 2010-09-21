rpcc_source = sfslite

is_build_tool = yes

rpcc_configure_args = --enable-system-bin --enable-rpcc-build

rpcc_configure_args += --with-gmp=$(BUILD_DIR)/gmp

rpcc_build = $(MAKE) -C $(PACKAGE_BUILD_DIR) autoconf.h ; \
	     $(MAKE) -C $(PACKAGE_BUILD_DIR)/async libasync.la ; \
	     $(MAKE) -C $(PACKAGE_BUILD_DIR)/rpcc

rpcc_install = $(MAKE) -C $(PACKAGE_BUILD_DIR)/rpcc DESTDIR=$(DESTDIR) install
