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

# Platform selects e.g. Linux config file
PLATFORM = native

native_arch = native

# Set PREFIX_BASE to empty string is equivalent to setting prefix to /
# You can change PREFIX_BASE and DESTDIR_BASE, along with PER_PACKAGE_{PREFIX,DESTDIR},
#  to meet special requirements.
#
# For example,
#	qnative_PREFIX_BASE = /home/joecisco
#	qnative_DESTDIR_BASE = /
#	PER_PACKAGE_DESTDIR =
#	PER_PACKAGE_PREFIX =
# will install everything under joecisco's home directory, and ready to run,
# i.e., a direct install; no staging area.
#
# Example 2
#	qasmp_PREFIX_BASE = $(DFLT_INSTALL_DIR)
#	qasmp_DESTDIR_BASE =
#	PER_PACKAGE_DESTDIR =
#	PER_PACKAGE_PREFIX = yes
# will create the same style install tree as from the original ebuild.

PER_PACKAGE_DESTDIR =
PER_PACKAGE_PREFIX = yes

qnative_PREFIX_BASE = $(DFLT_INSTALL_DIR)
qnative_LIBDIR = $(prefix)/lib64
qnative_LIBEXECDIR = $(prefix)/usr/libexec
qnative_DATAROOTDIR = $(prefix)/usr/share
qnative_DESTDIR_BASE =

qasmp_PREFIX_BASE = $(DFLT_INSTALL_DIR)
qasmp_LIBDIR = $(prefix)/lib
qasmp_LIBEXECDIR = $(prefix)/usr/libexec
qasmp_DATAROOTDIR = $(prefix)/usr/share
qasmp_DESTDIR_BASE =

qsp_PREFIX_BASE = $(DFLT_INSTALL_DIR)
qsp_LIBDIR = $(prefix)/lib
qsp_LIBEXECDIR = $(prefix)/usr/libexec
qsp_DATAROOTDIR = $(prefix)/usr/share
qsp_DESTDIR_BASE =

qtko_PREFIX_BASE = $(DFLT_INSTALL_DIR)
qtko_LIBDIR = $(prefix)/lib64
qtko_LIBEXECDIR = $(prefix)/usr/libexec
qtko_DATAROOTDIR = $(prefix)/usr/share
qtko_DESTDIR_BASE =

qtkoboot_PREFIX_BASE = $(DFLT_INSTALL_DIR)
qtkoboot_LIBDIR = $(prefix)/lib
qtkoboot_LIBEXECDIR = $(prefix)/usr/libexec
qtkoboot_DATAROOTDIR = $(prefix)/usr/share
qtkoboot_DESTDIR_BASE =

# Default for which packages go into read-only image
# used to have pam
default_root_packages = bash coreutils sysvinit util-linux mingetty procps

# Linux based platforms (PLATFORM=i686 PLATFORM=ppc etc.)
i686_arch = i686
x86_64_arch = x86_64
ppc_arch = ppc

# UML platforms

$(foreach a,i686 x86_64 ppc, \
  $(eval uml-$(a)_arch = $(a)) \
  $(eval uml-$(a)_linux_arch = um) \
  $(eval uml-$(a)_copyimg_env = VIRTUAL_CONSOLES=yes) \
  $(eval uml-$(a)_root_packages = $(default_root_packages) nano net-tools \
				  iputils bridge-utils))

# default arch platforms for installing linux headers
$(foreach a,x86_64 ppc mips i386 i486 i586 i686, \
  $(eval default-$(a)_arch = $(a)))
