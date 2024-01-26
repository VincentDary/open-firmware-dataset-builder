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

################################################################################
# Environment definition
################################################################################

SHELL=/usr/bin/bash
PYTHON=python3

ENV_ARCHIVES_DIR := ../../archives
ENV_BUILDS_DIR := ../../builds
ENV_SRC_DIR := ../../src
ENV_TOOLS_DIR := ../../tools
ENV_SCRIPTS_DIR := ../../scripts

SCRIPT_BOOTSTRAP_GIT_ARCHIVE := $(ENV_SCRIPTS_DIR)/bootstrap_git_archive.sh
SCRIPT_BOOTSTRAP_ARDUINO_CLI_ENV := $(ENV_SCRIPTS_DIR)/bootstrap_arduino_cli_env.sh
SCRIPT_FW_JSON_META_PY := ../../scripts/firmware_json_meta.py


################################################################################
# Toolchains
################################################################################

TOOLCHAIN_ARM_GNU_13_2_REL1 := arm-gnu-toolchain-13.2.rel1
TOOLCHAIN_ARM_GNU_13_2_REL1_PATH := $(ENV_TOOLS_DIR)/$(TOOLCHAIN_ARM_GNU_13_2_REL1)
TOOLCHAIN_ARM_GNU_13_2_REL1_BIN := $(TOOLCHAIN_ARM_GNU_13_2_REL1_PATH)/bin
TOOLCHAIN_ARM_GNU_13_2_REL1_ARM_NONE_EABI_BIN := $(TOOLCHAIN_ARM_GNU_13_2_REL1_PATH)/arm-none-eabi/bin
TOOLCHAIN_ARM_GNU_13_2_REL1_READELF := $(TOOLCHAIN_ARM_GNU_13_2_REL1_PATH)/bin/arm-none-eabi-readelf
TOOLCHAIN_ARM_GNU_13_2_REL1_OBJCOPY := $(TOOLCHAIN_ARM_GNU_13_2_REL1_PATH)/bin/arm-none-eabi-objcopy
TOOLCHAIN_ARM_GNU_13_2_REL1_PATH_BASE := "$(realpath $(TOOLCHAIN_ARM_GNU_13_2_REL1_BIN))":"$(realpath $(TOOLCHAIN_ARM_GNU_13_2_REL1_ARM_NONE_EABI_BIN))"

TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR := gcc-arm-none-eabi-7-2017-q4-major-linux
TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH := $(ENV_TOOLS_DIR)/$(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR)
TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_BIN := $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH)/bin
TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_ARM_NONE_EABI_BIN := $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH)/arm-none-eabi/bin
TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_READELF := $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH)/bin/arm-none-eabi-readelf
TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_PATH_BASE := "$(realpath $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_BIN))":"$(realpath $(TOOLCHAIN_ARM_GNU_7_2017_Q4_MAJOR_ARM_NONE_EABI_BIN))"


################################################################################
# Arduino Constants
################################################################################

ARDUINO_DEFAULT_ARM_TOOLCHAIN_PATH := packages/arduino/tools/arm-none-eabi-gcc
ARDUINO_DEFAULT_ARM_TOOLCHAIN_READELF := $(ARDUINO_DEFAULT_ARM_TOOLCHAIN_PATH)/TOOLCHAIN_VER/bin/arm-none-eabi-readelf


################################################################################
# Arduino builtin package
################################################################################

ARDUINO_PKG_BUILTIN := \
	ctags-5.8-arduino11-pm-x86_64-pc-linux-gnu.tar.bz2 \
	dfu-discovery_v0.1.2_Linux_64bit.tar.gz \
	mdns-discovery_v1.0.9_Linux_64bit.tar.gz\
	serial-discovery_v1.4.0_Linux_64bit.tar.gz \
	serial-monitor_v0.13.0_Linux_64bit.tar.gz


################################################################################
# Arduino core SAM
################################################################################

ARDUINO_SAM_1_6_12 := "arduino:sam@1.6.12"

ARDUINO_CORE_SAM_1_6_12_PKG := \
	gcc-arm-none-eabi-4.8.3-2014q1-linux64.tar.gz \
	bossac-1.6.1-arduino-x86_64-linux-gnu.tar.gz \
	sam-1.6.12.tar.bz2

REPO_ARDUINO_CORE_SAM_URL := https://github.com/arduino/ArduinoCore-sam

ARDUINO_CORE_SAM_1_6_12_TOOLCHAIN_NAME := gcc-arm-none-eabi-4.8.3-2014q1
ARDUINO_CORE_SAM_1_6_12_TOOLCHAIN_VER := 4.8.3-2014q1
ARDUINO_CORE_SAM_1_6_12_READELF := $(subst TOOLCHAIN_VER,$(ARDUINO_CORE_SAM_1_6_12_TOOLCHAIN_VER),$(ARDUINO_DEFAULT_ARM_TOOLCHAIN_READELF))
ARDUINO_CORE_SAM_1_6_12_GIT_COMMIT := 0840aa277a7a6519147fcf041b0b3c5ae5dcbac1

FQBN_ARDUINO_SAM_ARDUINO_DUE_X_DBG := arduino:sam:arduino_due_x_dbg


################################################################################
# Arduino core STM32
################################################################################

ARDUINO_CORE_STM32 := "STMicroelectronics:stm32@2.6.0"

ARDUINO_CORE_STM32_2_6_0_PKG := \
	xpack-arm-none-eabi-gcc-12.2.1-1.2-linux-x64.tar.gz \
	xpack-openocd-0.12.0-1-linux-x64.tar.gz \
	CMSIS-5.7.0.tar.bz2  \
	STM32Tools-2.2.1-linux.tar.bz2 \
	STM32-2.6.0.tar.bz2

REPO_ARDUINO_CORE_STM32_URL := https://github.com/stm32duino/Arduino_Core_STM32
REPO_ARDUINO_STM32_CMSIS_URL := https://github.com/stm32duino/ArduinoModule-CMSIS

ARDUINO_CORE_STM32_TOOLCHAIN_PATH := packages/STMicroelectronics/tools/xpack-arm-none-eabi-gcc/TOOLCHAIN_VER

ARDUINO_CORE_STM32_2_6_0_TOOLCHAIN_NAME := xpack-arm-none-eabi-gcc-12.2.1-1.2
ARDUINO_CORE_STM32_2_6_0_VER := 12.2.1-1.2
ARDUINO_CORE_STM32_2_6_0_TOOLCHAIN_PATH := $(subst TOOLCHAIN_VER,$(ARDUINO_CORE_STM32_2_6_0_VER),$(ARDUINO_CORE_STM32_TOOLCHAIN_PATH))
ARDUINO_CORE_STM32_2_6_0_READELF := $(ARDUINO_CORE_STM32_2_6_0_TOOLCHAIN_PATH)/bin/arm-none-eabi-readelf
ARDUINO_CORE_STM32_2_6_0_GIT_COMMIT := 2.6.0
ARDUINO_CORE_STM32_2_6_0_CMSIS_GIT_COMMIT := 5.7.0


FQBN_ARDUINO_NUCLEO_144_F429ZI := STMicroelectronics:stm32:Nucleo_144:pnum=NUCLEO_F429ZI,upload_method=MassStorage,usb=none,opt=ogstd
FQBN_ARDUINO_NUCLEO_64_F103RB := STMicroelectronics:stm32:Nucleo_64:pnum=NUCLEO_F103RB,upload_method=MassStorage,usb=none,opt=ogstd


################################################################################
# Arduino libraries
################################################################################

REPO_ARDUINO_LIBRARIES_SERVO_URL := https://github.com/arduino-libraries/Servo.git
REPO_ARDUINO_LIBRARIES_SERVO := github.com_arduino-libraries_Servo

REPO_ARDUINO_LIBRARIES_LIQUID_CRYSTRAL_URL := https://github.com/arduino-libraries/LiquidCrystal.git
REPO_ARDUINO_LIBRARIES_LIQUID_CRYSTRAL := github.com_arduino-libraries_LiquidCrystal

REPO_SMARMENGOL_MODBUS_MASTER_SLAVE_FOR_ARDUINO_URL := https://github.com/smarmengol/Modbus-Master-Slave-for-Arduino.git
REPO_SMARMENGOL_MODBUS_MASTER_SLAVE_FOR_ARDUINO := github.com_smarmengol_Modbus-Master-Slave-for-Arduino

REPO_ROCKETSTREAM_MAX31855_URL := https://github.com/rocketscream/MAX31855.git
REPO_ROCKETSTREAM_MAX31855 := github.com_rocketscream_MAX31855

REPO_ADAFRUIT_MAX6675_LIBRARY_URL := https://github.com/adafruit/MAX6675-library.git
REPO_ADAFRUIT_MAX6675_LIBRARY := github.com_adafruit_MAX6675-library

REPO_BR3TTB_ARDUINO_PID_LIBRARY_URL := https://github.com/br3ttb/Arduino-PID-Library.git
REPO_BR3TTB_ARDUINO_PID_LIBRARY := github.com_br3ttb_Arduino-PID-Library

REPO_FIRMATA_ARDUINO_URL := https://github.com/firmata/arduino.git
REPO_FIRMATA_ARDUINO := github.com_firmata_arduino


################################################################################
# Arduino projects
################################################################################

REPO_ROCKETSTREAM_REFLOW_OVEN_CONTROLLER_URL := https://github.com/rocketscream/Reflow-Oven-Controller.git
REPO_ROCKETSTREAM_REFLOW_OVEN_CONTROLLER := github.com_rocketscream_Reflow-Oven-Controller

REPO_JABELONE_CAR_CONTROLLER_URL := https://github.com/jabelone/car-controller.git
REPO_JABELONE_CAR_CONTROLLER := github.com_jabelone_car-controller


################################################################################
# Embedded OS
################################################################################

REPO_RIOT_OS_RIOT_URL := https://github.com/RIOT-OS/RIOT.git
REPO_RIOT_OS_RIOT := github.com_RIOT-OS_RIOT


################################################################################
# Firmware Projects
################################################################################

REPO_RIS3_LAB_P2IM_REAL_FIRMWARE_URL := https://github.com/RiS3-Lab/p2im-real_firmware.git
REPO_RIS3_LAB_P2IM_REAL_FIRMWARE_GIT_COMMIT := d4c7456574ce2c2ed038e6f14fea8e3142b3c1f7
RIS3_LAB_P2IM_HEAT_PRESS_URL := https://raw.githubusercontent.com/RiS3-Lab/p2im-real_firmware/931bd89e30366d554a80bcfb4bff9858b1be7480/Heat_Press/HeatPress.ino
RIS3_LAB_P2IM_HEAT_PRESS_INO_FILE_931bd89 := RiS3-Lab_p2im-real_firmware_Heat_Press_HeatPress_931bd89.ino

REPO_DEADSY_GRBL_STM32F4_URL := https://github.com/deadsy/grbl_stm32f4.git
REPO_DEADSY_GRBL_STM32F4 := github.com_deadsy_grbl_stm32f4

REPO_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER_URL := https://github.com/heethesh/eYSIP-2017_Control_and_Algorithms_development_for_Quadcopter.git
REPO_HEETHESH_EYSIP_2017_CA_FOR_QUADCOPTER := github.com_heethesh_eYSIP-2017_Control_and_Algorithms_development_for_Quadcopter

REPO_MBOCANEG_INVERTED_PENDULUM_ROBOT_URL := https://github.com/mbocaneg/Inverted-Pendulum-Robot.git
REPO_MBOCANEG_INVERTED_PENDULUM_ROBOT := github.com_mbocaneg_Inverted-Pendulum-Robot
