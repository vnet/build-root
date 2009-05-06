#
# Copyright (c) 2007-2008 Eliot Dresselhaus
#
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

######################################################################
# Collect makefile fragments
######################################################################

# Where this makefile lives
MU_BUILD_ROOT_DIR = $(shell pwd)
MU_BUILD_NAME = $(shell basename $(MU_BUILD_ROOT_DIR))

# Search path (e.g. multiple directories) where sources are found.
SOURCE_PATH =

# Pick up user's definitions for variables e.g. SOURCE_PATH, etc.
-include build-config.mk

MU_BUILD_ROOT_NAME = $(shell basename $(MU_BUILD_ROOT_DIR))
MU_BUILD_DATA_DIR_NAME = build-data

SOURCE_PATH_BUILD_ROOT_DIRS = $(addsuffix /$(MU_BUILD_NAME),$(SOURCE_PATH))
SOURCE_PATH_BUILD_DATA_DIRS = $(addsuffix /$(MU_BUILD_DATA_DIR_NAME),$(SOURCE_PATH))

# For tools use build-root as source path, otherwise use given source path
FIND_SOURCE_PATH =						\
  $(if $(is_build_tool),					\
    $(SOURCE_PATH_BUILD_ROOT_DIRS) $(MU_BUILD_ROOT_DIR),	\
    $(SOURCE_PATH_BUILD_DATA_DIRS))

# First search given source path, then default to build-root
FULL_SOURCE_PATH = $(SOURCE_PATH_BUILD_DATA_DIRS) $(MU_BUILD_ROOT_DIR)

# Find root directory for package based on presence of package .mk
# makefile fragment on source path.
find_build_data_dir_for_package_fn = $(shell			\
  set -eu$(BUILD_DEBUG) ;					\
  for d in $(FIND_SOURCE_PATH) ; do				\
    f="$${d}/packages/$(1).mk" ;				\
    [[ -f $${f} ]] && echo `cd $${d} && pwd` && exit 0 ;	\
  done ;							\
  echo "")

# dir/PACKAGE
find_source_fn = $(shell				\
  set -eu$(BUILD_DEBUG) ;				\
  d="$(call find_build_data_dir_for_package_fn,$(1))" ;	\
  [[ -n "$${d}" ]] && d="$${d}/../$(1)" ;		\
  echo "$${d}")

# Find given FILE in source path as build-data/packages/FILE
find_package_file_fn = $(shell				\
  set -eu$(BUILD_DEBUG) ;				\
  d="$(call find_build_data_dir_for_package_fn,$(1))" ;	\
  [[ -n "$${d}" ]] && d="$${d}/packages/$(2)" ;		\
  [[ -f "$${d}" ]] && echo "$${d}")

# Find first FILE in source path with name PATH/build-data/FILE
find_build_data_file_fn = $(shell				\
  set -eu$(BUILD_DEBUG) ;					\
  for d in $(FIND_SOURCE_PATH) ; do				\
    f="$${d}/$(1)" ;						\
    [[ -f $${f} ]] && echo `cd $${d} && pwd`/$(1) && exit 0 ;	\
  done ;							\
  echo "")

######################################################################
# ARCH, PLATFORM
######################################################################

NATIVE_ARCH = $(shell gcc -dumpmachine | sed -e 's/\([a-zA-Z_0-9]*\)-.*/\1/')

# Find all platforms.mk that we can, including those from build-root
$(foreach d,$(FULL_SOURCE_PATH), \
  $(eval -include $(d)/platforms.mk))

# Platform should be defined somewhere by specifying $($(PLATFORM)_arch)
ARCH = $($(PLATFORM)_arch)
ifeq ($(ARCH),)
  $(error "Unknown platform `$(PLATFORM)'")
endif

# map e.g. ppc7450 -> ppc
BASIC_ARCH = \
   ${shell case '$(ARCH)' in \
      (i*86*) echo i386 ;; \
      (ppc*|powerpc*) echo ppc ;; \
      (*) echo '$(ARCH)' ;; \
     esac }

# OS to configure for.  configure --host will be set to $(ARCH)-$(OS)
OS = mu-linux

ifdef_fn = $(if $(patsubst undefined,,$(origin $(1))),$($(1)),$(2))

spu_target = spu
native_target =
ARCH_TARGET_tmp = $(call ifdef_fn,$(ARCH)_target,$(ARCH)-$(OS))
TARGET = $(call ifdef_fn,$(PLATFORM)_target,$(ARCH_TARGET_tmp))
TARGET_PREFIX = $(if $(ARCH:native=),$(TARGET)-,)

######################################################################
# Generic build stuff
######################################################################

# The package we are currently working on
PACKAGE = $*

BUILD_PREFIX_package = build-
BUILD_PREFIX_tool = build-tool-
INSTALL_PREFIX = install-
IMAGES_PREFIX = images-

# Whether we are building a tool or not
tool_or_package_fn = $(if $(is_build_tool),tool,package)

# Directory where packages are built & installed
BUILD_DIR = $(MU_BUILD_ROOT_DIR)/$(BUILD_PREFIX_$(call tool_or_package_fn))$(ARCH)
INSTALL_DIR = $(MU_BUILD_ROOT_DIR)/$(INSTALL_PREFIX)$(ARCH)
PLATFORM_IMAGE_DIR = $(MU_BUILD_ROOT_DIR)/$(IMAGES_PREFIX)$(PLATFORM)

# Default VAR, package specified override of default PACKAGE_VAR
package_var_fn = $(if $($(1)_$(2)),$($(1)_$(2)),$(1))

package_build_dir_fn = $(call package_var_fn,$(1),build_dir)

package_install_dir_fn = \
  $(if $(is_build_tool),$(TOOL_INSTALL_DIR),$(INSTALL_DIR)/$(call package_build_dir_fn,$(1)))

PACKAGE_BUILD_DIR = \
  $(BUILD_DIR)/$(call package_build_dir_fn,$(PACKAGE))
PACKAGE_INSTALL_DIR = \
  $(call package_install_dir_fn,$(PACKAGE))

# Tools (gcc, binutils, glibc...) are installed here
TOOL_INSTALL_DIR = $(MU_BUILD_ROOT_DIR)/tools

# Target specific tools go here e.g. mu-build/tools/ppc-mu-linux
TARGET_TOOL_INSTALL_DIR = $(TOOL_INSTALL_DIR)/$(TARGET)

# Set BUILD_DEBUG to vx or x enable shell command tracing.
BUILD_DEBUG =

# Message from build system itself (as opposed to make or shell commands)
build_msg_fn = echo "@@@@ $(1) @@@@"

# Always prefer our own tools to those installed on system.
# Note: ccache-bin must be before tool bin.
BUILD_ENV = \
    export PATH=$(TOOL_INSTALL_DIR)/ccache-bin:$${PATH} ; \
    export PATH=$(TOOL_INSTALL_DIR)/bin:$${PATH} ; \
    : remove . from path present so that we dont try to run ; \
    : ./mv while cross-compiling mv itself ; \
    export PATH="`echo $${PATH} | sed -e s/[.]://`" ; \
    export LD_LIBRARY_PATH=$(TOOL_INSTALL_DIR)/lib64:$(TOOL_INSTALL_DIR)/lib ; \
    set -eu$(BUILD_DEBUG)

######################################################################
# Package build generic definitions
######################################################################

package_dir_fn = \
  $(call find_build_data_dir_for_package_fn,$(1))/packages

package_mk_fn = $(call package_dir_fn,$(1))/$(1).mk

$(foreach d,$(addsuffix /packages,$(FIND_SOURCE_PATH)), \
  $(eval -include $(d)/*.mk) \
  $(eval ALL_PACKAGES += $(patsubst $(d)/%.mk,%,$(wildcard $(d)/*.mk))))

# Linux specific native build tools
NATIVE_TOOLS_LINUX =				\
  e2fsimage					\
  e2fsprogs					\
  fakeroot					\
  jffs2						\
  mkimage					\
  zlib						\
  squashfs

IS_LINUX = $(if $(findstring no,$($(PLATFORM)_uses_linux)),no,yes)

NATIVE_TOOLS_$(IS_LINUX) += $(NATIVE_TOOLS_LINUX)

# only build glibc for linux installs
CROSS_TOOLS_$(IS_LINUX) += glibc

# must be first for bootstrapping
NATIVE_TOOLS = findutils make git spp

# basic tools needed for build system
NATIVE_TOOLS += git automake autoconf libtool texinfo bison flex

# needed to compile gcc
NATIVE_TOOLS += mpfr gmp

# Tools needed on native host to build for platform
NATIVE_TOOLS += $(call ifdef_fn,$(PLATFORM)_native_tools,)

# Tools for cross-compiling from native -> ARCH
CROSS_TOOLS = binutils gcc gdb # ccache

# Tools needed on native host to build for platform
CROSS_TOOLS += $(call ifdef_fn,$(PLATFORM)_cross_tools,)

NATIVE_TOOLS += $(NATIVE_TOOLS_yes)
CROSS_TOOLS += $(CROSS_TOOLS_yes)

timestamp_name_fn = .mu_build_$(1)_timestamp
CONFIGURE_TIMESTAMP = $(call timestamp_name_fn,configure)
BUILD_TIMESTAMP = $(call timestamp_name_fn,build)
INSTALL_TIMESTAMP = $(call timestamp_name_fn,install)

TIMESTAMP_DIR = $(PACKAGE_BUILD_DIR)

find_newer_files_fn =						\
  "`for i in $(2) ; do						\
      [[ -f $$i && $$i -nt $(1) ]] && echo "$$i" && exit 0;	\
    done ;							\
    exit 0;`"

find_filter = -not -name '*~'
find_filter += -and -not -path '*/.git*'
find_filter += -and -not -path '*/.svn*'
find_filter += -and -not -path '*/.CVS*'

find_newer_fn =						\
  (! -f $(1)						\
    || -n $(call find_newer_files_fn,$(1),$(3))		\
    || -n "`find $(2) $(find_filter)			\
            -and -type f -newer $(1) -print -quit`")

######################################################################
# Package dependencies
######################################################################

# This must come before %-configure, %-build, %-install pattern rules
# or else dependencies will not work.

package_dependencies_fn =				\
  $(patsubst %-install, %,				\
    $(filter %-install,$($(1)_configure_depend)))

PACKAGE_DEPENDENCIES = $(call package_dependencies_fn,$(PACKAGE))

# package specific configure, build, install dependencies
add_package_dependency_fn = \
  $(if $($(1)_$(2)_depend), \
       $(eval $(1)-$(2) : $($(1)_$(2)_depend)))

$(foreach p,$(ALL_PACKAGES), \
    $(call add_package_dependency_fn,$(p),configure) \
    $(call add_package_dependency_fn,$(p),build) \
    $(call add_package_dependency_fn,$(p),install))

TARGETS_RESPECTING_DEPENDENCIES = image_install wipe push-all pull-all

# carry over packages dependencies to image install, wipe, pull-all, push-all
$(foreach p,$(ALL_PACKAGES),							\
  $(if $($(p)_configure_depend),						\
    $(foreach s,$(TARGETS_RESPECTING_DEPENDENCIES),				\
      $(eval $(p)-$(s):								\
	     $(addsuffix -$(s), $(call package_dependencies_fn,$(p)))))))

######################################################################
# Package configure
######################################################################

# x86_64 can be either 32/64.  set BIACH=32 to get 32 bit libraries.
BIARCH = 64

x86_64_libdir = $(BIARCH)
native_libdir = $($(NATIVE_ARCH)_libdir)

# lib or lib64 depending
arch_lib_dir = lib$($(BASIC_ARCH)_libdir)

# Allow packages to override CPPFLAGS, CFLAGS, and LDFLAGS
CONFIGURE_ENV =								\
    $(if $(ARCH:native=),CONFIG_SITE=$(MU_BUILD_ROOT_DIR)/config.site,)	\
    $(if $($(PACKAGE)_CPPFLAGS),					\
	 CPPFLAGS="$(CPPFLAGS) $($(PACKAGE)_CPPFLAGS)")			\
    $(if $($(PACKAGE)_CFLAGS),						\
	 CFLAGS="$(CFLAGS) $($(PACKAGE)_CFLAGS)")			\
    $(if $($(PACKAGE)_CCASFLAGS),					\
	 CCASFLAGS="$(CCASFLAGS) $($(PACKAGE)_CCASFLAGS)")		\
    $(if $($(PACKAGE)_LDFLAGS),						\
	 LDFLAGS="$(LDFLAGS) $($(PACKAGE)_LDFLAGS)")			\
    $(if $($(PACKAGE)_configure_env),$($(PACKAGE)_configure_env))

configure_package_gnu =						\
  s=$(call find_source_fn,$(PACKAGE_SOURCE)) ;			\
  if [ ! -f $$s/configure ] ; then				\
    autoreconf -i -f $$s ;					\
  fi ;								\
  cd $(PACKAGE_BUILD_DIR) ;					\
  env $(CONFIGURE_ENV)						\
    $$s/configure						\
      $(if $($(PACKAGE)_configure_host_and_target),		\
           $($(PACKAGE)_configure_host_and_target),		\
           $(if $(ARCH:native=),--host=$(TARGET),))		\
      $(if $($(PACKAGE)_configure_prefix),			\
           $($(PACKAGE)_configure_prefix),			\
           --libdir=$(PACKAGE_INSTALL_DIR)/$(arch_lib_dir)	\
           --prefix=$(PACKAGE_INSTALL_DIR))			\
      $($(PACKAGE)_configure_args)

configure_package =							\
  $(call build_msg_fn,Configuring $(PACKAGE) in $(PACKAGE_BUILD_DIR)) ;	\
  mkdir -p $(PACKAGE_BUILD_DIR) ;					\
  $(if $($(PACKAGE)_configure),						\
       $($(PACKAGE)_configure),						\
       $(configure_package_gnu))

# Tools (e.g. gcc, binutils, gdb) required a platform to build for
check_platform =								\
  is_tool="$(is_build_tool)" ;							\
  is_cross_package="$(findstring $(PACKAGE),$(CROSS_TOOLS))" ;			\
  is_arch_native="$(if $(subst native,,$(ARCH)),,yes)" ;			\
  if [ "$${is_tool}" == "yes"							\
       -a "$${is_cross_package}" != ""						\
       -a "$${is_arch_native}" != "" ]; then					\
    $(call build_msg_fn,You must specify PLATFORM for building tools) ;		\
    exit 1 ;									\
  fi ;										\
  : check that platform gcc can be found ;					\
  target_gcc=gcc ;								\
  if [ "$${is_arch_native}" != "yes" ] ; then					\
    target_gcc=$(TARGET)-gcc ;							\
  fi ;										\
  if [ "$${is_tool}" != "yes"							\
       -a "$${is_arch_native}" != "yes"						\
       -a ! -x "`which 2> /dev/null $${target_gcc}`" ] ; then			\
    $(call build_msg_fn,							\
	   No cross-compiler found for platform $(PLATFORM) target $(TARGET);	\
	     try make PLATFORM=$(PLATFORM) install-tools) ;			\
    exit 1 ;									\
  fi
    
configure_check_timestamp =						\
  @$(BUILD_ENV) ;							\
  $(check_platform) ;							\
  mkdir -p $(PACKAGE_BUILD_DIR) ;					\
  mkdir -p $(PACKAGE_INSTALL_DIR) ;					\
  conf="$(TIMESTAMP_DIR)/$(CONFIGURE_TIMESTAMP)" ;			\
  dirs="$(call package_mk_fn,$(PACKAGE))				\
       $(MU_BUILD_ROOT_DIR)/config.site" ;				\
  if [[ $(call find_newer_fn, $${conf}, $${dirs}, $?) ]]; then		\
    $(configure_package) ;						\
    touch $${conf} ;							\
  else									\
    $(call build_msg_fn,Configuring $(PACKAGE): nothing to do) ;	\
  fi

.PHONY: %-configure
%-configure: %-find-source
	$(configure_check_timestamp)

######################################################################
# Package build
######################################################################

linux_n_cpus = `grep '^processor' /proc/cpuinfo | wc -l`

MAKE_PARALLEL_JOBS =				\
  -j $(shell if [ -f /proc/cpuinfo ] ; then	\
		expr 4 '*' $(linux_n_cpus);	\
	     else				\
		echo 1 ;			\
	     fi)

MAKE_PARALLEL_FLAGS = $(if $($(PACKAGE)_make_parallel_fails),,$(MAKE_PARALLEL_JOBS))

# Make command shorthand for packages & tools.
PACKAGE_MAKE =					\
  $(MAKE)					\
    -C $(PACKAGE_BUILD_DIR)			\
    $($(PACKAGE)_make_args)			\
    $(MAKE_PARALLEL_FLAGS)

build_package = \
  $(call build_msg_fn,Compiling $* in $(PACKAGE_BUILD_DIR)) ; \
  mkdir -p $(PACKAGE_BUILD_DIR) ; \
  cd $(PACKAGE_BUILD_DIR) ; \
  $(if $($(PACKAGE)_build), \
       $($(PACKAGE)_build), \
       $(PACKAGE_MAKE))

build_check_timestamp =									\
  @$(BUILD_ENV) ;									\
  comp="$(TIMESTAMP_DIR)/$(BUILD_TIMESTAMP)" ;						\
  conf="$(TIMESTAMP_DIR)/$(CONFIGURE_TIMESTAMP)" ;					\
  dirs="$(call find_source_fn,$(PACKAGE_SOURCE))					\
       $(if $(is_build_tool),,$(addprefix $(INSTALL_DIR)/,$(PACKAGE_DEPENDENCIES)))" ;	\
  if [[ $${conf} -nt $${comp}								\
        || $(call find_newer_fn, $${comp}, $${dirs}, $?) ]]; then			\
    $(build_package) ;									\
    touch $${comp} ;									\
  else											\
    $(call build_msg_fn,Compiling $(PACKAGE): nothing to do) ;				\
  fi

.PHONY: %-build
%-build: %-configure
	$(build_check_timestamp)

.PHONY: %-rebuild
%-rebuild: %-wipe %-build
	@ :

######################################################################
# Package install
######################################################################

installed_lib_fn = $(call package_install_dir_fn,$(1))/$(arch_lib_dir)
installed_include_fn = $(call package_install_dir_fn,$(1))/include

installed_includes_fn = $(foreach i,$(1),-I$(call installed_include_fn,$(i)))
installed_libs_fn = $(foreach i,$(1),-L$(call installed_lib_fn,$(i)))

install_package =								\
    : for non-tools remove anything that might have already been there ;	\
    $(if $(is_build_tool),,rm -rf $(PACKAGE_INSTALL_DIR) ;)			\
    mkdir -p $(PACKAGE_INSTALL_DIR) ;						\
    $(if $($(PACKAGE)_install),							\
	 $($(PACKAGE)_install),							\
	 $(PACKAGE_MAKE)							\
	    $($(PACKAGE)_install_args)						\
	    install)

install_check_timestamp =					\
  @$(BUILD_ENV) ;						\
  inst=$(TIMESTAMP_DIR)/$(INSTALL_TIMESTAMP) ;			\
  dirs="$(PACKAGE_BUILD_DIR)" ;					\
  if [[ $(call find_newer_fn, $${inst}, $${dirs}, $?) ]]; then	\
    $(install_package) ;					\
    touch $${inst} ;						\
  else								\
    $(call build_msg_fn,Installing $(PACKAGE): nothing to do) ;	\
  fi

.PHONY: %-install
%-install: %-build
	$(install_check_timestamp)

######################################################################
# Source code managment
######################################################################

GIT = git

# Maps package name to source directory root.
# Multiple packages may use a single source tree.
# For example, gcc-bootstrap package shares gcc source.
PACKAGE_SOURCE = $(if $($(PACKAGE)_source),$($(PACKAGE)_source),$(PACKAGE))

# Use git to download source if directory is not found
find_source_for_package =									\
  @$(BUILD_ENV) ;										\
  $(call build_msg_fn,Arch for platform '$(PLATFORM)' is $(ARCH)) ;				\
  $(call build_msg_fn,Finding source for $(PACKAGE)) ;						\
  s="$(call find_source_fn,$(PACKAGE_SOURCE))" ;						\
  [[ -z "$${s}" ]]										\
    && $(call build_msg_fn,Package $(PACKAGE) not found with path $(SOURCE_PATH))						\
    && exit 1;											\
  mk="$(call find_build_data_dir_for_package_fn,$(PACKAGE_SOURCE))/packages/$(PACKAGE).mk";	\
  $(call build_msg_fn,Makefile fragment found in $${mk}) ;					\
  if [ ! -d "$${s}" ] ; then									\
    d=`dirname $${mk}` ;									\
    i=`cd $${d}/.. && ($(GIT) config remote.origin.url ||						\
                    awk '/URL/ { print $$2; }' .git/remotes/origin)`;				\
    g=`dirname $${i}` ;										\
    $(call build_msg_fn,Fetching source: $(GIT) clone $${g}/$(PACKAGE_SOURCE) $$s) ;		\
    if ! $(GIT) clone $${g}/$(PACKAGE_SOURCE) $$s; then						\
      $(call build_msg_fn,No source for $(PACKAGE) in $${g});					\
      exit 1;											\
    fi ;											\
    $(call build_msg_fn,Autowanking $${g}/$(PACKAGE_SOURCE)) ;					\
    (cd $${s} ; $(MU_BUILD_ROOT_DIR)/autowank --touch) ;					\
  fi ;												\
  s=`cd $${s} && pwd` ;										\
  $(call build_msg_fn,Source found in $${s})

.PHONY: %-find-source
%-find-source:
	$(find_source_for_package)

.PHONY: %-push %-pull %-push-all %-pull-all
%-push %-pull %-push-all %-pull-all:
	@$(BUILD_ENV) ;								\
	push_or_pull=$(patsubst %-all,%,$(subst $(PACKAGE)-,,$@)) ;		\
	$(call build_msg_fn,Git $${push_or_pull} source for $(PACKAGE)) ;	\
	s=$(call find_source_fn,$(PACKAGE_SOURCE)) ;				\
	if [ "x$$s" = "x" ]; then						\
	     $(call build_msg_fn,No source for $(PACKAGE)) ;			\
	     exit 1;								\
	fi ;									\
	cd $$s && $(GIT) $${push_or_pull}

# Pull all packages for platform
.PHONY: pull-all
pull-all:
	@$(BUILD_ENV) ;								\
	$(call build_msg_fn,Git pull build system) ;				\
	for d in $(MU_BUILD_ROOT_DIR)						\
		 $(SOURCE_PATH_BUILD_ROOT_DIRS)					\
	 	 $(SOURCE_PATH_BUILD_DATA_DIRS); do				\
	  $(call build_msg_fn,Git pull $${d}) ;					\
	  pushd $${d} >& /dev/null && $(GIT) pull && popd >& /dev/null ;	\
	done ;									\
	$(call build_msg_fn,Git pull build tools) ;				\
	$(call tool_make_target_fn,pull-all) ;					\
	$(call build_msg_fn,Git pull packages for platform $(PLATFORM)) ;	\
	make PLATFORM=$(PLATFORM) $(patsubst %,%-pull-all,$(ROOT_PACKAGES))

######################################################################
# System images
######################################################################

IMAGE_DIR = $(MU_BUILD_ROOT_DIR)/image-$(PLATFORM)

# Reports shared libraries in given directory
find_shared_libs_fn =				\
  find $(1)					\
    -maxdepth 1					\
       -regex '.*/lib[a-z_]+.so'		\
    -o -regex '.*/lib[a-z_]+-[0-9.]+.so'	\
    -o -regex '.*/lib[a-z_]+.so.[0-9.]+'

# By default pick up files from binary directories and /etc.
# Also include shared libraries.
DEFAULT_IMAGE_INCLUDE =					\
  for d in bin sbin libexec				\
           usr/bin usr/sbin usr/libesec			\
           etc; do					\
    [[ -d $$d ]] && echo $$d;				\
  done ;						\
  [[ -d $(arch_lib_dir) ]]				\
    && $(call find_shared_libs_fn,$(arch_lib_dir))

# Define any shell functions needed by install scripts
image_install_functions =			\
  $(foreach p,$(ALL_PACKAGES),			\
    $(if $($(p)_image_install_functions),	\
	 $($(p)_image_install_functions)))

# Should always be over-written by temp dir in %-root-image rule
IMAGE_INSTALL_DIR = $(error you need to set IMAGE_INSTALL_DIR)

image_install_fn =								\
  @$(BUILD_ENV) ;								\
  $(call build_msg_fn,Image-install $(1) for platform $(PLATFORM)) ;		\
  inst_dir=$(IMAGE_INSTALL_DIR) ;						\
  mkdir -p $${inst_dir} ;							\
  cd $(2) ;									\
  : select files to include in image ;						\
  image_include_files="								\
    `$(call ifdef_fn,$(1)_image_include,$(DEFAULT_IMAGE_INCLUDE)) ;		\
     echo "" ;									\
     exit 0 ; `";								\
  : select files regexps to exclude from image ;				\
  image_exclude_files="" ;							\
  if [ ! -z "$($(1)_image_exclude)" ] ; then					\
    image_exclude_files="${image_exclude_files}					\
                         $(patsubst %,--exclude=%,$($(1)_image_exclude))" ;	\
  fi ;										\
  [[ -z "$${image_include_files}" ]]						\
    || tar cf - $${image_include_files} $${image_exclude_files}			\
       | tar xf - -C $${inst_dir} ;						\
  : copy files from copyimg directory if present ;				\
  d="$(call package_dir_fn,$(1))/$(1).copyimg" ;				\
  [[ -d "$${d}" ]]								\
    && env $($(PLATFORM)_copyimg_env)						\
	$(MU_BUILD_ROOT_DIR)/copyimg $$d $${inst_dir} ;				\
  : run package dependent install script ;					\
  $(if $($(1)_image_install),							\
       $(image_install_functions)						\
       cd $${inst_dir} ;							\
       $($(1)_image_install))

.PHONY: %-image_install
%-image_install: %-install
	$(call image_install_fn,$(PACKAGE),$(PACKAGE_INSTALL_DIR))

basic_system_image_include =				\
  echo bin/ldd ;					\
  echo $(arch_lib_dir)/ld*.so* ;			\
  $(call find_shared_libs_fn, $(arch_lib_dir))

basic_system_image_install =				\
  mkdir -p bin lib mnt proc root sbin sys tmp etc ;	\
  mkdir -p usr usr/{bin,sbin} usr/lib ;			\
  mkdir -p var var/{lib,lock,log,run,tmp} ;		\
  mkdir -p var/lock/subsys var/lib/urandom ;		\
  : make dev directory ;				\
  $(linuxrc_makedev)

.PHONY: basic_system-image_install
basic_system-image_install:
	$(call image_install_fn,basic_system,			\
	   $(if $(ARCH:native=),				\
	        $(TARGET_TOOL_INSTALL_DIR),			\
	        $(TOOL_INSTALL_DIR)/$(NATIVE_ARCH)-$(OS)))

ROOT_PACKAGES = $(if $($(PLATFORM)_root_packages),$($(PLATFORM)_root_packages),$(default_root_packages))

# readonly root squashfs image
.PHONY: ro-image
$(PLATFORM_IMAGE_DIR)/ro.img ro-image: $(patsubst %,%-find-source,$(ROOT_PACKAGES))
	@$(BUILD_ENV) ;							\
	d=$(PLATFORM_IMAGE_DIR) ;					\
	mkdir -p $$d;							\
	ro_image=$$d/ro.img ;						\
	rm -f $${ro_image} ;						\
	tmp_dir="`mktemp -d $$d/ro-image-XXXXXX`" ;			\
	chmod 0755 $${tmp_dir} ;					\
	cd $${tmp_dir} ;						\
	trap "rm -rf $${tmp_dir}" err ;					\
	fakeroot /bin/bash -c "{					\
	  set -eu$(BUILD_DEBUG) ;					\
	  $(MAKE) -C $(MU_BUILD_ROOT_DIR) IMAGE_INSTALL_DIR=$${tmp_dir}	\
	    $(patsubst %,%-image_install,				\
	      basic_system						\
	      $(ROOT_PACKAGES)) ;					\
	  : strip symbols from files ;					\
	  find $${tmp_dir} -type f					\
	    -exec							\
              $(TARGET_PREFIX)strip					\
                --strip-unneeded '{}' ';'				\
	        >& /dev/null ;						\
	  : make read-only file system ;				\
	  mksquashfs							\
	    $${tmp_dir} $${ro_image}					\
	    -no-exports -no-progress -no-recovery ;			\
	}" ;								\
	: cleanup tmp directory ;					\
	rm -rf $${tmp_dir}

MKFS_JFFS2_BYTE_ORDER_x86_64 = -l
MKFS_JFFS2_BYTE_ORDER_i686 = -l
MKFS_JFFS2_BYTE_ORDER_ppc = -b
MKFS_JFFS2_BYTE_ORDER_mips = -b
MKFS_JFFS2_BYTE_ORDER_native = $(MKFS_JFFS2_BYTE_ORDER_$(NATIVE_ARCH))

mkfs_fn_jffs2 = mkfs.jffs2			\
  --eraseblock=256KiB				\
  --root=$(1) --output=$(2)			\
  $(MKFS_JFFS2_BYTE_ORDER_$(BASIC_ARCH))

EXT2_RW_IMAGE_SIZE = 16384

mkfs_fn_ext2 = \
  e2fsimage -d $(1) -f $(2) -s $(EXT2_RW_IMAGE_SIZE)

RW_IMAGE_TYPE=jffs2

make_rw_image_fn = \
  $(call mkfs_fn_$(RW_IMAGE_TYPE),$(1),$(2))

rw_image_embed_ro_image_fn =			\
  mkdir -p proc initrd images ro rw union ;	\
  cp $(PLATFORM_IMAGE_DIR)/$(1) images/$(1) ;	\
  md5sum images/$(1) > images/$(1).md5 ;	\
  mkdir -p changes/$(1)

# make sure RW_IMAGE_TYPE is a type we know how to build
.PHONY: rw-image-check-type
rw-image-check-type:
	@$(BUILD_ENV) ;								\
	if [ -z "$(make_rw_image_fn)" ] ; then					\
	  $(call build_msg_fn,Unknown read/write fs image type;			\
		              try RW_IMAGE_TYPE=ext2 or RW_IMAGE_TYPE=jffs2) ;	\
	  exit 1;								\
	fi

# read write image
.PHONY: rw-image
rw-image: rw-image-check-type ro-image
	@$(BUILD_ENV) ;						\
	d=$(PLATFORM_IMAGE_DIR) ;				\
	mkdir -p $$d ;						\
	rw_image="$$d/rw.$(RW_IMAGE_TYPE)" ;			\
	ro_image="ro.img" ;					\
	rm -f $$rw_image ;					\
	tmp_dir="`mktemp -d $$d/rw-image-XXXXXX`" ;		\
	chmod 0755 $${tmp_dir} ;				\
	cd $${tmp_dir} ;					\
	trap "rm -rf $${tmp_dir}" err ;				\
	fakeroot /bin/bash -c "{				\
	  set -eu$(BUILD_DEBUG) ;				\
	  $(linuxrc_makedev) ;					\
	  $(call rw_image_embed_ro_image_fn,$${ro_image}) ;	\
	  $(call make_rw_image_fn,$${tmp_dir},$${rw_image}) ;	\
	}" ;							\
	: cleanup tmp directory ;				\
	rm -rf $${tmp_dir}

images: rw-image linux-install linuxrc-install
	@$(BUILD_ENV) ;						\
	d=$(PLATFORM_IMAGE_DIR) ;				\
	cd $(BUILD_DIR)/linux-$(PLATFORM) ;			\
	i="" ;							\
	[[ -z $$i && -f bzImage ]] && i=bzImage ;		\
	[[ -z $$i && -f zImage ]] && i=zImage ;			\
	[[ -z $$i && -f linux ]] && i=linux ;			\
	[[ -z $$i && -f vmlinux ]] && i=vmlinux ;		\
	[[ -z $$i ]]						\
	  && $(call build_msg_fn,no linux image to install	\
		in $(BUILD_DIR)/linux-$(PLATFORM))		\
	  && exit 1 ;						\
	cp $$i $$d

######################################################################
# Tool chain build/install
######################################################################

.PHONY: ccache-install
ccache-install:
	if which ccache >& /dev/null; then				\
	  mkdir -p $(TOOL_INSTALL_DIR)/ccache-bin ;			\
	  c=`which ccache` ;						\
	  : Link to ccache for native gcc ;				\
	  ln -sf $$c $(TOOL_INSTALL_DIR)/ccache-bin/gcc ;		\
	  : Link to ccache for cross-buildr gcc ;			\
	  ln -sf $$c $(TOOL_INSTALL_DIR)/ccache-bin/$(TARGET)-gcc ;	\
	fi

TOOL_MAKE = $(MAKE) is_build_tool=yes

tool_make_target_fn = 							\
  $(if $(strip $(NATIVE_TOOLS)),					\
    $(TOOL_MAKE) $(patsubst %,%-$(1),$(NATIVE_TOOLS)) ARCH=native ;)	\
  $(TOOL_MAKE) $(patsubst %,%-$(1),$(CROSS_TOOLS))

.PHONY: install-tools
install-tools:
	$(call tool_make_target_fn,install)

######################################################################
# Clean
######################################################################

package_clean_script =							\
  @$(call build_msg_fn, Cleaning $* in $(PACKAGE_INSTALL_DIR)) ;	\
  $(BUILD_ENV) ;							\
  $(if $(is_build_tool),,rm -rf $(PACKAGE_INSTALL_DIR) ;)		\
  rm -rf $(TIMESTAMP_DIR)/$(call timestamp_name_fn,*) ;			\
  $(if $($(PACKAGE)_clean),						\
    $($(PACKAGE)_clean),						\
    $(PACKAGE_MAKE) clean)

.PHONY: %-clean
%-clean:
	$(package_clean_script)

# Wipe e.g. remove build and install directories for packages.
package_wipe_script =						\
  @$(call build_msg_fn, Wiping build/install $(PACKAGE)) ;	\
  $(BUILD_ENV) ;						\
  rm -rf $(PACKAGE_INSTALL_DIR) $(PACKAGE_BUILD_DIR)

.PHONY: %-wipe
%-wipe:
	$(package_wipe_script)

# Clean everything
distclean:
	rm -rf $(MU_BUILD_ROOT_DIR)/$(BUILD_PREFIX_package)*/
	rm -rf $(MU_BUILD_ROOT_DIR)/$(BUILD_PREFIX_tool)*
	rm -rf $(MU_BUILD_ROOT_DIR)/$(INSTALL_PREFIX)*
	rm -rf $(MU_BUILD_ROOT_DIR)/$(IMAGES_PREFIX)*
	rm -rf $(TOOL_INSTALL_DIR)
