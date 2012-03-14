# other library is not installed (needed by e2fsimage)
e2fsprogs_install = $(PACKAGE_MAKE) install install-libs

e2fsprogs_configure_args = --disable-fsck
