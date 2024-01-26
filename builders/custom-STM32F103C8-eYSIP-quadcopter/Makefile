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
# - https://github.com/heethesh/eYSIP-2017_Control_and_Algorithms_development_for_Quadcopter
#
################################################################################

ROOT_DIR_NAME := $(notdir $(realpath $(dir $(lastword $(MAKEFILE_LIST)))))

include ../constant.mk

SRC := $(ENV_SRC_DIR)/$(ROOT_DIR_NAME)
BUILD := $(ENV_BUILDS_DIR)/$(ROOT_DIR_NAME)

READELF := $(TOOLCHAIN_ARM_GNU_13_2_REL1_READELF)

GIT_COMMIT_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER := e0baf05873a03292b146b7aa298357f3275b8b12
FW_SRC := $(SRC)/$(REPO_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER)
TARGET := Firmware_V101-103C8
FW_ELF := $(BUILD)/$(TARGET).elf


.PHONY: all firmware_build firmware_metadata_gen clean_src clean release


all: firmware_build firmware_metadata_gen clean_src


release: all


firmware_build:
	mkdir -p $(BUILD) $(SRC)

	# Firmware source code bootstrap.
	$(SCRIPT_BOOTSTRAP_GIT_ARCHIVE) \
		$(ENV_ARCHIVES_DIR)/$(REPO_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER).tar.gz \
		$(SRC) \
		$(GIT_COMMIT_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER)

	# Firmware build.
	cp -v Makefile_Firmware_V101-103C8.mk $(FW_SRC)/firmware/Makefile
	cd $(FW_SRC)/firmware && $(MAKE) PATH=$(TOOLCHAIN_ARM_GNU_13_2_REL1_PATH_BASE):$(PATH)
	cp -v $(FW_SRC)/firmware/build/$(TARGET).* $(BUILD)


firmware_metadata_gen: $(FW_ELF)
	variant=$$($(READELF) -A $(FW_ELF) |tr -d ' '|grep -Po  '(?<=Tag_CPU_arch:).*'); \
	entry_point=$$($(READELF) -h $(FW_ELF) |grep 'Entry point address:' |grep -Po '0x[0-9a-fA-F]*'); \
	blob_size=$$(stat --printf=%s $(BUILD)/$(TARGET).bin); \
	blob_base_addr=0x$$($(READELF) -s $(FW_ELF) |grep '\.isr_vector' |grep -Po '[0-9a-fA-F]{8}'); \
	blob_endian=$$($(READELF) -h $(FW_ELF) |grep 'Data:' |grep -Po  '(little|big) endian' |grep -Po '(little|big)'); \
	blob_sha1=$$(sha1sum $(BUILD)/$(TARGET).bin |cut -d " " -f 1) \
	; \
	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_load_meta \
		--processor-id main \
		--processor arm \
		--processor-variant $$variant \
		--processor-model STM32F103C8 \
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
		--toolchain $(TOOLCHAIN_ARM_GNU_13_2_REL1) \
		--processor arm \
		--processor-variant $$variant \
		--processor-model STM32F103C8 \
		--entry-point $$entry_point \
		--src "$(REPO_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER_URL)" \
			  $(GIT_COMMIT_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER) \
		--out $(BUILD)/$(TARGET).json

	$(PYTHON) $(SCRIPT_FW_JSON_META_PY) \
		firmware_all_meta \
		--board custom \
		--load-meta-file $(BUILD)/firmware_load_metadata.json \
		--firmware-build-meta-file $(BUILD)/$(TARGET).json \
		--out $(BUILD)/firmware_metadata.json

	rm -f $(BUILD)/firmware_load_metadata.json $(BUILD)/$(TARGET).json


clean_src:
	rm -rf $(SRC)


clean:
	rm -rf $(BUILD) $(SRC)
