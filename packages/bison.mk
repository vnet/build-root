bison_configure_depend = flex-install

# flex/bison output needs to be autowanked
bison_build =					\
  s="$(call find_source_fn,$(PACKAGE_SOURCE))";	\
  touch $${s}/src/parse-gram.c ;		\
  touch $${s}/src/scan-gram.c ;			\
  touch $${s}/src/scan-skel.c ;			\
  touch $${s}/src/scan-code.c ;			\
  $(PACKAGE_MAKE)
