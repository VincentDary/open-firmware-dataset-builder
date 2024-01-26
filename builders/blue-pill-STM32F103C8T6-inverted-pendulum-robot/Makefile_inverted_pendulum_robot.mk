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

TARGET=inverted_pendulum

BUILD_DIR = build

C_SOURCES = \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_i2c.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_tim_ex.c \
	Drivers/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_uart.c \
  Src/MPU6050/MPU6050.c \
	Src/main.c \
	Src/stm32f1xx_hal_msp.c \
  Src/stm32f1xx_it.c \
  Src/system_stm32f1xx.c

C_OBJS := $(patsubst %.c, %.o, $(C_SOURCES))

C_INCLUDES =  -IDrivers/STM32F1xx_HAL_Driver/Inc
C_INCLUDES += -IDrivers/STM32F1xx_HAL_Driver/Inc/Legacy
C_INCLUDES += -IDrivers/CMSIS/Device/ST/STM32F1xx/Include
C_INCLUDES += -IDrivers/CMSIS/Include
C_INCLUDES += -ISrc/MPU6050
C_INCLUDES += -IInc

ASM_SOURCES = startup/startup_stm32f103xb.s
ASM_OBJS := $(patsubst %.s, %.o, $(ASM_SOURCES))

ifeq ($(DEBUG), 1)
C_DEBUG_FLAGS = -Og -g3
ASM_DEBUG_FLAG = -g
endif


all: $(BUILD_DIR) $(ASM_OBJS) $(C_OBJS) $(TARGET).elf post-build


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


$(ASM_OBJS): $(ASM_SOURCES)
	$(AS) -mcpu=cortex-m3 -mthumb -mfloat-abi=soft $(ASM_DEBUG_FLAG) \
		-o "$(BUILD_DIR)/$(notdir $@)" "$(@:%.o=%.s)"


$(C_OBJS): $(C_SOURCES)
	$(CC) \
		-mcpu=cortex-m3 -mthumb -mfloat-abi=soft \
		'-D__weak=__attribute__((weak))' \
		'-D__packed="__attribute__((__packed__))"' \
		-DUSE_HAL_DRIVER -DSTM32F103xB \
		$(C_INCLUDES) \
		$(C_DEBUG_FLAGS) -Wall -fmessage-length=0 -ffunction-sections -c \
		-fmessage-length=0 -MMD -MP -MF"$(BUILD_DIR)/$(notdir $(@:%.o=%.d))" -MT"$@" \
		-o "$(BUILD_DIR)/$(notdir $@)" "$(@:%.o=%.c)"


$(TARGET).elf: ./STM32F103C8Tx_FLASH.ld
	$(CC) \
		-mcpu=cortex-m3 -mthumb \
		-mfloat-abi=soft -specs=nosys.specs -specs=nano.specs -u _printf_float \
		-T./STM32F103C8Tx_FLASH.ld \
		-Wl,-Map=$(BUILD_DIR)/$(TARGET).map -Wl,--gc-sections \
		-o "$(BUILD_DIR)/$@" \
		$(addprefix $(BUILD_DIR)/, $(notdir $(C_OBJS))) \
		$(addprefix $(BUILD_DIR)/, $(notdir $(ASM_OBJS))) \
		-lm


post-build:
		$(CP) -O binary $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).bin
		$(SZ) $(BUILD_DIR)/$(TARGET).elf


clean:
	rm -rf $(BUILD_DIR)
