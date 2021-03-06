# openssl depends on zlib
openssl_configure_depend = zlib-install

# Build shared libraries
openssl_configure_flags = shared

# openssl insists on using deprecated -m486 so we override it
# with the more modern -mcpu= to silence GCC warnings.
openssl_configure_flags += ${shell case '$(ARCH)' in \
                               (i?86) echo '-mcpu=$(ARCH)' ;; esac }

openssl_configure_flags += --prefix="$(PACKAGE_INSTALL_DIR)"

OPENSSL_SHLIB_VERSION = ${shell \
  grep 'define SHLIB_VERSION_NUMBER' \
       $(call find_source_fn,openssl)/crypto/opensslv.h \
  | cut --fields=3 --delimiter=' ' \
  | sed 's/"//g' }

openssl_configure =							\
  rm -rf $(PACKAGE_BUILD_DIR) ;						\
  mkdir -p $(PACKAGE_BUILD_DIR) ;					\
  cd $(PACKAGE_BUILD_DIR) ;						\
  : Copy in sources since openssl does not use GNU tools ;		\
  cp --no-dereference --recursive --symbolic-link			\
    $(call find_source_fn,openssl)/* . ;				\
  ./config $(openssl_configure_flags)

openssl_make_args += LD='$(TARGET_PREFIX)ld' \
                     AR='$(TARGET_PREFIX)ar r' \
	             CC='$(TARGET_PREFIX)gcc' \
                     RANLIB='$(TARGET_PREFIX)ranlib'

openssl_make_args += LDFLAGS='$(call installed_libs_fn,zlib)'

# gives make errors
openssl_make_parallel_fails = yes
