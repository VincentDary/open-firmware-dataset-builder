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

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
CP = arm-none-eabi-objcopy
AR = arm-none-eabi-ar
SZ = arm-none-eabi-size

TARGET=Firmware_V101-103C8

BUILD_DIR = build

C_SOURCES = \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_i2c.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c \
  Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c \
  Src/i2c.c \
  Src/timing.c \
  Src/MadgwickAHRS.c \
  Src/stm32f1xx_it.c \
  Src/circular_buffer.c \
  Src/MS5611.c \
  Src/pid.c \
  Src/main.c \
  Src/system_stm32f1xx.c \
  Src/joystick.c \
  Src/common.c \
  Src/serial.c \
  Src/MPU9250.c \
  Src/telemetry.c \
  Src/motor.c \
  Src/stm32f1xx_hal_msp.c \
  Src/devices.c \
  Src/peripherals.c \
  Src/msp.c

C_OBJS := $(patsubst %.c, %.o, $(C_SOURCES))

C_INCLUDES = -IInc
C_INCLUDES += -IDrivers/CMSIS/Include
C_INCLUDES += -IDrivers/CMSIS/Device/ST/STM32F1xx/Include
C_INCLUDES += -IDrivers/STM32F1xx_HAL_Driver/Inc
C_INCLUDES += -IDrivers/STM32F1xx_HAL_Driver/Inc/Legacy

ASM_SOURCES = \
  startup/startup_stm32f103xb.s
ASM_OBJS := $(patsubst %.s, %.o, $(ASM_SOURCES))

ifeq ($(DEBUG), 1)
DEBUG_FLAG = -g
endif


all: create_build_dir $(ASM_OBJS) $(C_OBJS) $(TARGET).elf post-build


create_build_dir:
	mkdir -p $(BUILD_DIR)

$(ASM_OBJS): $(ASM_SOURCES)
	$(CC) -c -mthumb -mcpu=cortex-m3 $(DEBUG_FLAG) \
	-Wa,--no-warn -x assembler-with-cpp -specs=nano.specs \
	-o "$(BUILD_DIR)/$(notdir $@)" "$(@:%.o=%.s)"


$(C_OBJS): $(C_SOURCES)
	$(CC) -c -mthumb -mcpu=cortex-m3 -std=gnu11 \
		-D'__weak=__attribute__((weak))' -D'__packed=__attribute__((__packed__))' \
		-DUSE_HAL_DRIVER -DSTM32F103xB \
		$(C_INCLUDES) \
		-Os -ffunction-sections -fdata-sections $(DEBUG_FLAG) -fstack-usage -Wall -specs=nano.specs \
		-o "$(BUILD_DIR)/$(notdir $@)" "$(@:%.o=%.c)"


$(TARGET).elf: ./STM32F103C8_FLASH.ld
	$(CC) -o $(BUILD_DIR)/Firmware_V101-103C8.elf \
		$(addprefix $(BUILD_DIR)/, $(notdir $(C_OBJS))) \
		$(addprefix $(BUILD_DIR)/, $(notdir $(ASM_OBJS))) \
		-mthumb -mcpu=cortex-m3 \
		-T./STM32F103C8_FLASH.ld -specs=nosys.specs -static \
		-Wl,-Map=$(BUILD_DIR)/$(TARGET).map -Wl,--gc-sections \
		-Wl,--defsym=malloc_getpagesize_P=0x80 -Wl,--start-group -lc -lm \
		-Wl,--end-group -specs=nano.specs

post-build:
	$(CP) -O binary $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin
	$(SZ) $(BUILD_DIR)/$(TARGET).elf

clean:
	rm -rf $(BUILD_DIR)
