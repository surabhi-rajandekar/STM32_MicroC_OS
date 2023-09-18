#!/usr/bin/ld

# Target
TARGET := stm32h743zi

## Build configuration
DEBUG = 1 
OPT = -Og

## Paths
WORKSPACE_PATH := /home/surabhi/Projects/STM32_MicroC_OS

MICRO_OS_PATH := $(WORKSPACE_PATH)/infra/uC-OS3

TOOLCHAIN_PATH := \
/home/surabhi/toolchain/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux/gcc-arm-none-eabi-10.3-2021.10/bin

BUILD_DIR := $(WORKSPACE_PATH)/build

## Sources
MICRO_OS_SOURCES := $(wildcard $(MICRO_OS_PATH)/Cfg/Template/*.c) \
					$(wildcard $(MICRO_OS_PATH)/Source/*.c)

C_SOURCES := 	$(WORKSPACE_PATH)/drivers/src/ \
				$(WORKSPACE_PATH)/src/ \
				$(MICRO_OS_SOURCES)

ASM_SOURCES := $(WORKSPACE_PATH)/linker/startup_stm32h743xx.s

## Includes
MICRO_OS_INCLUDES := $(wildcard $(MICRO_OS_PATH)/Cfg/Template/*.h) \
					$(wildcard $(MICRO_OS_PATH)/Source/*.h)

C_INCLUDES :=	$(WORKSPACE_PATH)/drivers/inc/ \
				$(MICRO_OS_DEFINES)

## Binaries
PREFIX = arm-none-eabi-
CC = $(TOOLCHAIN_PATH)/$(PREFIX)gcc
AS = $(TOOLCHAIN_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(TOOLCHAIN_PATH)/$(PREFIX)objcopy
SZ = $(TOOLCHAIN_PATH)/$(PREFIX)size
# to convert elf to hex or binary 
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

## CFLAGS
# cpu
CPU = -mcpu=cortex-m7

# fpu
FPU = -mfpu=fpv5-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DSTM32H743xx


# AS includes
AS_INCLUDES = 

# compile gcc flags
CFLAGS += $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
# -g3: produce verbose debug output
# -gdwarf-2 produce debug info in DWARF ver 2 format
CFLAGS += -g3 -gdwarf-2
endif

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

# link script
LDSCRIPT = $(WORKSPACE_PATH)/linker/STM32H743ZITx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all, dependencies .elf, .hex, .bin - no commands
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# now we have a target called main, which compiles main.c when called,
# if I run without a target name, first target in the file is run
#format:
# target: prerequisite
# compile commands
build/obj/main: src/main.c
#"@" tells the gmake to not print the command on the terminal.
	@cc src/main.c -o build/obj/main	
	@echo ${C_DEFINES}
	@echo $(C_INCLUDES)

#example target, without prerequisites
hello:
	@echo "Hello, Surabhi!"
	@echo "Hey, again!"

#clean -> delete all builds
clean:
	rm -rf build/obj/*

#Optional commands used during testing

#MICRO_OS_SOURCES := $(shell find $(MICRO_OS_PATH)/Cfg/Template -name '*.c') \
					$(shell find $(MICRO_OS_PATH)/Source -name '*.c')