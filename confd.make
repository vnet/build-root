######################################################################
# ConfD MAAPI example
# (C) 2006 Tail-f Systems
#
# See the README file for more information
######################################################################

usage:
	@echo "make start    Start ConfD daemon"
	@echo "make stop     Stop any ConfD daemon"
	@echo "make cli      Start the ConfD Command Line Interface"
	@echo "make run      Run qvnet"


######################################################################
# Where is ConfD installed? Make sure CONFD_DIR points it out
CONFD_DIR ?= ./packages-qnative

# In case CONFD_DIR is not set (correctly), this rule will trigger
$(CONFD_DIR)/bin/confd:
	@echo 'Where is ConfD installed? Set $$CONFD_DIR to point it out!'
	@echo ''
	@exit 1

######################################################################
# Example specific definitions and rules

CONFD = $(CONFD_DIR)/bin/confd 
CONFD_CLI = $(CONFD_DIR)/bin/confd_cli 
CONFD_QVNET = $(CONFD_DIR)/bin/qvnet 
CONFD_ETC = $(CONFD_DIR)/etc/confd

######################################################################
start:  stop
	$(CONFD) -c $(CONFD_ETC)/confd.conf

######################################################################
stop:
	### Stopping any confd daemon
	$(CONFD) --stop || true


######################################################################
cli:
	$(CONFD_CLI) -C --user=admin --groups=admin \
		--interactive || echo Exit

######################################################################
run-qvnet:
	$(CONFD_QVNET) unix interactive

######################################################################
