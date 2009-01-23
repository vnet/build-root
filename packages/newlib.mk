newlib_configure_host_and_target = --target=$(TARGET)

# make clean is not clean enough so we just delete everything
newlib_clean = rm -rf $(PACKAGE_BUILD_DIR)


