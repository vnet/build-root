git_configure = \
  rm -rf $(PACKAGE_BUILD_DIR) ; \
  mkdir -p $(PACKAGE_BUILD_DIR) ; \
  cd $(PACKAGE_BUILD_DIR) ; \
  : Copy in sources since git does not use GNU tools ; \
  cp --no-dereference --recursive --symbolic-link \
    $(call find_source_fn,git)/* . ; \
  ./configure --prefix="$(PACKAGE_INSTALL_DIR)"
