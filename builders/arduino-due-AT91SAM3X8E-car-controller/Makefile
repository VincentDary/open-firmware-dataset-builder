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
#
# firmware code:
# - https://github.com/jabelone/car-controller
# - https://github.com/arduino-libraries/Servo
#
################################################################################

ROOT_DIR_NAME := $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))

include ../constant.mk

SRC := $(ENV_SRC_DIR)/$(ROOT_DIR_NAME)
BUILD := $(ENV_BUILDS_DIR)/$(ROOT_DIR_NAME)

ARDUINO_CORE_FILE := $(SRC)/arduino_core.txt
ARDUINO_PKG_FILE := $(SRC)/arduino_pkg.txt
READELF := $(SRC)/arduino15/$(ARDUINO_CORE_SAM_1_6_12_READELF)

GIT_COMMIT_ARDUINO_LIBRARIES_SERVO := d1fb5d6f3a8bc2116b1ec92303243ba3f44ae8dc
GIT_COMMIT_JABELONE_CAR_CONTROLLER := 9b9ece829741bb0d774c161ff3f19159ac927b83

ARDUINO_PRJ_NAME := car_controller.ino
FW_ELF := $(BUILD)/$(ARDUINO_PRJ_NAME).elf


.PHONY: all firmware_build firmware_metadata_gen clean_src clean release


all: firmware_build firmware_metadata_gen clean_src


release: all


firmware_build:
	mkdir -p $(BUILD) $(SRC)

	# Firmware source code bootstrap.
	$(SCRIPT_BOOTSTRAP_GIT_ARCHIVE) \
		$(ENV_ARCHIVES_DIR)/$(REPO_ARDUINO_LIBRARIES_SERVO).tar.gz \
		$(SRC) \
		$(GIT_COMMIT_ARDUINO_LIBRARIES_SERVO)

	$(SCRIPT_BOOTSTRAP_GIT_ARCHIVE) \
		$(ENV_ARCHIVES_DIR)/$(REPO_JABELONE_CAR_CONTROLLER).tar.gz \
		$(SRC) \
		$(GIT_COMMIT_JABELONE_CAR_CONTROLLER)

	# Arduino environment bootstrap.
	echo $(ARDUINO_SAM_1_6_12) | tr ' ' '\n' > $(ARDUINO_CORE_FILE)
	echo "$(ARDUINO_PKG_BUILTIN) $(ARDUINO_CORE_SAM_1_6_12_PKG)" | tr ' ' '\n' > $(ARDUINO_PKG_FILE)
	$(SCRIPT_BOOTSTRAP_ARDUINO_CLI_ENV) \
		$(ENV_ARCHIVES_DIR) $(SRC) $(ARDUINO_PKG_FILE) $(ARDUINO_CORE_FILE)

	# Firmware build.
	cd $(SRC)/$(REPO_JABELONE_CAR_CONTROLLER)/car_controller \
		&& ../../arduino-cli/arduino-cli \
			  	--config-file ../../arduino15/arduino-cli.yaml \
		 		compile \
				--verbose \
				--fqbn $(FQBN_ARDUINO_SAM_ARDUINO_DUE_X_DBG) \
				--library ../../$(REPO_ARDUINO_LIBRARIES_SERVO) \
				--output-dir ../../$(BUILD) \
				$(ARDUINO_PRJ_NAME)


firmware_metadata_gen: $(FW_ELF)
	variant=$$($(READELF) -A $(FW_ELF) |tr -d ' '|grep -Po  '(?<=Tag_CPU_arch:).*'); \
	entry_point=$$($(READELF) -h $(FW_ELF) |grep 'Entry point address:' |grep -Po '0x[0-9a-fA-F]*'); \
	blob_size=$$(stat --printf=%s $(BUILD)/$(ARDUINO_PRJ_NAME).bin); \
	blob_base_addr=0x$$($(READELF) -S $(FW_ELF) |grep '\.text' |grep -Po '[0-9a-fA-F]{8}'); \
	blob_endian=$$($(READELF) -h $(FW_ELF) |grep 'Data:' |grep -Po  '(little|big) endian' |grep -Po '(little|big)'); \
	blob_sha1=$$(sha1sum $(BUILD)/$(ARDUINO_PRJ_NAME).bin |cut -d " " -f 1) \
	; \
	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_load_meta \
		--processor-id main \
		--processor arm \
		--processor-variant $$variant \
		--processor-model AT91SAM3X8E \
		--entry-point $$entry_point \
		--load $(ARDUINO_PRJ_NAME).bin 0x0 $$blob_size $$blob_base_addr \
		--out $(BUILD)/firmware_load_metadata.json \
	; \
	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_build_meta \
		--filename $(ARDUINO_PRJ_NAME).bin \
		--file-size $$blob_size \
		--sha1 $$blob_sha1 \
		--endian $$blob_endian \
		--compiler gcc \
		--toolchain $(ARDUINO_CORE_SAM_1_6_12_TOOLCHAIN_NAME) \
		--processor arm \
		--processor-variant $$variant \
		--processor-model AT91SAM3X8E \
		--entry-point $$entry_point \
	  	--src "$(REPO_ARDUINO_CORE_SAM_URL)" $(ARDUINO_CORE_SAM_1_6_12_GIT_COMMIT) \
		--src "$(REPO_JABELONE_CAR_CONTROLLER_URL)" $(GIT_COMMIT_JABELONE_CAR_CONTROLLER) \
		--src "$(REPO_ARDUINO_LIBRARIES_SERVO_URL)" $(GIT_COMMIT_ARDUINO_LIBRARIES_SERVO) \
		--out $(BUILD)/$(ARDUINO_PRJ_NAME).json

	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_all_meta \
		--board aduino-due \
		--load-meta-file $(BUILD)/firmware_load_metadata.json \
		--firmware-build-meta-file $(BUILD)/$(ARDUINO_PRJ_NAME).json \
		--out $(BUILD)/firmware_metadata.json

	rm -f $(BUILD)/firmware_load_metadata.json $(BUILD)/$(ARDUINO_PRJ_NAME).json


clean_src:
	rm -rf $(SRC)


clean:
	rm -rf $(BUILD) $(SRC)
