################################################################################
#
# Copyright 2023-2024 Vincent Dary
#
# This file is part of open-firmware-dataset-builder (OFDB).
#
# open-firmware-dataset-builder is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# open-firmware-dataset-builder is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# open-firmware-dataset-builder. If not, see <https://www.gnu.org/licenses/>.
#
################################################################################

RELEASE_BASE_DIR := ../releases
RELEASE_VER := 1.0.0
RELEASE_DIR_NAME := open-firmware-dataset-V$(RELEASE_VER)
RELEASE_DIR := $(RELEASE_BASE_DIR)/$(RELEASE_DIR_NAME)
RELEASE_ARCHIVE_NAME := $(RELEASE_DIR_NAME).tar.gz
RELEASE_NOTE_FILE := $(RELEASE_DIR)/README.txt
RELEASE_LICENCE := ../data/odf_cc_by-nc-nd_4.0_legalcode.txt
RELEASE_NOTE := ../data/ofd_release_notes.txt
RELEASE_VERSION_BANNER := "\n\nOpen Firmware Dataset (OFD) - version $(RELEASE_VER)"


SUB_DIRS := $(shell find . -type d -not -path ".")


all: $(SUB_DIRS)


clean: $(SUB_DIRS)


release: $(RELEASE_BASE_DIR)/$(RELEASE_ARCHIVE_NAME)


$(RELEASE_BASE_DIR)/$(RELEASE_ARCHIVE_NAME): $(SUB_DIRS)
	rm -rf $(RELEASE_DIR)
	mkdir $(RELEASE_DIR)
	mv ../builds $(RELEASE_DIR)
	mkdir ../builds
	echo -e $(RELEASE_VERSION_BANNER) > $(RELEASE_NOTE_FILE)
	cat $(RELEASE_NOTE) >> $(RELEASE_NOTE_FILE)
	cp -v $(RELEASE_LICENCE) $(RELEASE_DIR)/License
	cd $(RELEASE_BASE_DIR) && tar -czf $(RELEASE_ARCHIVE_NAME) $(RELEASE_DIR_NAME)
	cd $(RELEASE_BASE_DIR) && rm -rf $(RELEASE_DIR_NAME)


$(SUB_DIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


.PHONY: all clean $(SUB_DIRS)
