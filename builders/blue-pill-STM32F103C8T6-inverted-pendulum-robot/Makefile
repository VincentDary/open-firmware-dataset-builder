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
# https://github.com/mbocaneg/Inverted-Pendulum-Robot
#
################################################################################

ROOT_DIR_NAME := $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))

include ../constant.mk

SRC := $(ENV_SRC_DIR)/$(ROOT_DIR_NAME)
BUILD := $(ENV_BUILDS_DIR)/$(ROOT_DIR_NAME)

READELF := $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_READELF)

FW_SRC := $(SRC)/$(REPO_MBOCANEG_INVERTED_PENDULUM_ROBOT)
GIT_COMMIT_MBOCANEG_INVERTED_PENDULUM_ROBOT := b04c16c593440ca10ebf91823280c426d7749872
TARGET := inverted_pendulum
FW_ELF := $(BUILD)/$(TARGET).elf


.PHONY: all firmware_build firmware_metadata_gen clean_src clean release


all: firmware_build firmware_metadata_gen clean_src


release: all


firmware_build:
	mkdir -p $(BUILD) $(SRC)

	# Firmware source code bootstrap.
	$(SCRIPT_BOOTSTRAP_GIT_ARCHIVE) \
		$(ENV_ARCHIVES_DIR)/$(REPO_MBOCANEG_INVERTED_PENDULUM_ROBOT).tar.gz $(SRC) \
		$(GIT_COMMIT_MBOCANEG_INVERTED_PENDULUM_ROBOT)

	# Firmware build.
	cp -v Makefile_inverted_pendulum_robot.mk $(FW_SRC)/Makefile
	cd $(FW_SRC) && $(MAKE) PATH=$(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH_BASE):$(PATH) DEBUG=1
	cp -v $(FW_SRC)/build/$(TARGET)* $(BUILD)


firmware_metadata_gen: $(FW_ELF)
	variant=$$($(READELF) -A $(FW_ELF) |tr -d ' '|grep -Po  '(?<=Tag_CPU_arch:).*'); \
	entry_point=$$($(READELF) -h $(FW_ELF) |grep 'Entry point address:' |grep -Po '0x[0-9a-fA-F]*'); \
	blob_size=$$(stat --printf=%s $(BUILD)/$(TARGET).bin); \
	blob_base_addr=0x$$($(READELF) -S $(FW_ELF) |grep '\.isr_vector' |grep -Po '[0-9a-fA-F]{8}'); \
	blob_endian=$$($(READELF) -h $(FW_ELF) |grep 'Data:' |grep -Po  '(little|big) endian' |grep -Po '(little|big)'); \
	blob_sha1=$$(sha1sum $(BUILD)/$(TARGET).bin |cut -d " " -f 1) \
	; \
	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_load_meta \
		--processor-id main \
		--processor arm \
		--processor-variant $$variant \
		--processor-model STM32F103C8T6 \
		--entry-point $$entry_point \
		--load $(TARGET).bin 0x0 $$blob_size $$blob_base_addr \
		--out $(BUILD)/firmware_load_metadata.json \
	; \
	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_build_meta \
		--filename $(TARGET).bin \
		--file-size $$blob_size \
		--sha1 $$blob_sha1 \
		--endian $$blob_endian \
		--compiler gcc \
		--toolchain $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR) \
		--processor arm \
		--processor-variant $$variant \
		--processor-model STM32F103C8T6 \
		--entry-point $$entry_point \
		--src "$(REPO_MBOCANEG_INVERTED_PENDULUM_ROBOT_URL)" \
			  $(GIT_COMMIT_MBOCANEG_INVERTED_PENDULUM_ROBOT) \
		--out $(BUILD)/$(TARGET).json

	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_all_meta \
		--board blue-pill \
		--load-meta-file $(BUILD)/firmware_load_metadata.json \
		--firmware-build-meta-file $(BUILD)/$(TARGET).json \
		--out $(BUILD)/firmware_metadata.json

	rm -f $(BUILD)/firmware_load_metadata.json $(BUILD)/$(TARGET).json


clean_src:
	rm -rf $(SRC)


clean:
	rm -rf $(BUILD) $(SRC)
