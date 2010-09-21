# nothing to do

libtool_configure =                                            \
  s=$(call find_source_fn,$(PACKAGE_SOURCE)) ;                  \
  cd $$s ;                                                      \
  $$s/bootstrap ;                                               \
  cd $(PACKAGE_BUILD_DIR) ;                                     \
  env $(CONFIGURE_ENV)                                          \
    $$s/configure --prefix=$(PACKAGE_INSTALL_DIR)

