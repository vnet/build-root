-include $(MU_BUILD_ROOT_DIR)/packages/linux-common.mk

# nothing to build; we just want to install kernel headers
linux_build =					\
  : nothing to do

# Install kernel headers for C library build
# Setting "unwanted" to the NULL string prevents this target from trashing the
# glibc headers that may already be present. See .../linux/scripts/Makefile.headersinst.
linux_install = \
  i=$(TARGET_TOOL_INSTALL_DIR) ; \
  mkdir -p $$i ; \
  $(linux_make) INSTALL_HDR_PATH="$$i" unwanted= headers_install
