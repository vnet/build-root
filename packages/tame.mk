tame_source = sfslite

is_build_tool = yes

tame_configure_args = --enable-system-bin --enable-tame-build

tame_configure_args += --with-gmp=$(BUILD_DIR)/gmp

tame_build =
tame_build += $(MAKE) -C $(PACKAGE_BUILD_DIR) autoconf.h ;
tame_build += $(MAKE) -C $(PACKAGE_BUILD_DIR)/async libasync.la ;
tame_build += $(MAKE) -C $(PACKAGE_BUILD_DIR)/tame

tame_install = $(MAKE) -C $(PACKAGE_BUILD_DIR)/tame DESTDIR=$(DESTDIR) install
