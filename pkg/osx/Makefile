#
# Build file for creating DMG files.
#
# The DMG packager looks for a template.dmg.bz2 for using as its 
# DMG template. If it doesn't find one, it generates a clean one.
#
# If you create a DMG template, you should make one containing all
# the files listed in $(SOURCE_FILES) below, and arrange everything to suit
# your style. The contents of the files themselves does not matter, so
# they can be empty (they will be overwritten later). 
#
# Remko Tronçon 
# http://el-tramo.be/about
# Licensed under the MIT License. See COPYING for details.


################################################################################
# Customizable variables
################################################################################

NAME ?= LEAP_Client_installer
VERSION ?= 0.2.2

SOURCE_DIR ?= ../leap-launcher-osx
SOURCE_FILE ?= LEAP\ Client.app
SOURCE_FILE2 ?= "LEAP Client.app"

TEMPLATE_DMG ?= leap-template.dmg


################################################################################
# DMG building. No editing should be needed beyond this point.
################################################################################

MASTER_DMG=$(NAME)-$(VERSION).dmg
WC_DMG=wc.dmg
WC_DIR=wc

.PHONY: all
all: $(MASTER_DMG)

$(TEMPLATE_DMG): $(TEMPLATE_DMG).bz2
	bunzip2 -k $<

$(TEMPLATE_DMG).bz2: 
	@echo
	@echo --------------------- Generating empty template --------------------
	mkdir template
	hdiutil create -fs HFSX -layout SPUD -size 40m "$(TEMPLATE_DMG)" -srcfolder template -format UDRW -volname "$(NAME)" -quiet
	rmdir template
	bzip2 "$(TEMPLATE_DMG)"
	@echo

$(WC_DMG): $(TEMPLATE_DMG)
	cp $< $@

$(MASTER_DMG): $(WC_DMG) $(SOURCE_DIR)/$(SOURCE_FILE)
	@echo
	@echo --------------------- Creating Disk Image --------------------
	mkdir -p $(WC_DIR)
	hdiutil attach "$(WC_DMG)" -noautoopen -quiet -mountpoint "$(WC_DIR)"
	rm -rf "$(WC_DIR)/$(SOURCE_FILE)"; \
	ditto -rsrc "$(SOURCE_DIR)/LEAP Client.app" "$(WC_DIR)/LEAP Client.app"; \
	#rm -f "$@"
	#hdiutil create -srcfolder "$(WC_DIR)" -format UDZO -imagekey zlib-level=9 "$@" -volname "$(NAME) $(VERSION)" -scrub -quiet
	WC_DEV=`hdiutil info | grep "$(WC_DIR)" | grep "Apple_HFS" | awk '{print $$1}'` && \
	hdiutil detach $$WC_DEV -quiet -force
	rm -f "$(MASTER_DMG)"
	hdiutil convert "$(WC_DMG)" -quiet -format UDZO -imagekey zlib-level=9 -o "$@"
	rm -rf $(WC_DIR)
	@echo

.PHONY: clean
clean:
	-rm -rf $(TEMPLATE_DMG) $(MASTER_DMG) $(WC_DMG)
