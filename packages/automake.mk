automake_configure_depend = autoconf-install

automake_configure =						\
  s=$(call find_source_fn,$(PACKAGE_SOURCE)) ;                  \
  cd $$s ;							\
  $$s/bootstrap ;						\
  if [ ! -f $$s/configure ] ; then                              \
    autoreconf -i -f $$s ;                                      \
  fi ;                                                          \
  cd $(PACKAGE_BUILD_DIR) ;                                     \
  env $(CONFIGURE_ENV)                                          \
    $$s/configure --prefix=$(PACKAGE_INSTALL_DIR)
