#!/usr/bin/ld

# Target
TARGET := stm32h743zi

# Build configuration
DEBUG = 1 
OPT = -Og

# Paths
WORKSPACE_PATH := /home/surabhi/Projects/STM32_MicroC_OS
MICRO_OS_PATH := $(WORKSPACE_PATH)/infra/uC-OS3
TOOLCHAIN_PATH := \
/home/surabhi/toolchain/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux/gcc-arm-none-eabi-10.3-2021.10/bin

BUILD_DIR := $(WORKSPACE_PATH)/build

# Specify source directories
SRC_DIRS := \
    $(WORKSPACE_PATH)/src \
    $(WORKSPACE_PATH)/infra/STM32_system/Source 
    #$(MICRO_OS_PATH)/Cfg/Template \
    #$(MICRO_OS_PATH)/Source

C_SOURCES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
ASM_SOURCES := $(WORKSPACE_PATH)/linker/startup_stm32h743xx.s

# Includes
C_INCLUDES +=	-I$(WORKSPACE_PATH)/inc/ \
				-I$(WORKSPACE_PATH)/drivers/inc/ \
				-I$(WORKSPACE_PATH)/infra/CMSIS/Device/ST/STM32H7xx/Include \
				-I$(WORKSPACE_PATH)/infra/CMSIS/Include \
				-I$(WORKSPACE_PATH)/infra/STM32_system/Include/ 
				#-I$(MICRO_OS_PATH)/Cfg/Template/ \
				#-I$(MICRO_OS_PATH)/Source/

## Binaries
PREFIX = arm-none-eabi-
CC = $(TOOLCHAIN_PATH)/$(PREFIX)gcc
AS = $(TOOLCHAIN_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(TOOLCHAIN_PATH)/$(PREFIX)objcopy
SZ = $(TOOLCHAIN_PATH)/$(PREFIX)size
# to convert elf to hex or binary 
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# CFLAGS
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

# linker script
LDSCRIPT = $(WORKSPACE_PATH)/linker/STM32H743ZITx_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# default action: build all, dependencies .elf, .hex, .bin - no commands
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin
	@echo "phony all called"
# now we have a target called main, which compiles main.c when called,
# if I run without a target name, first target in the file is run
#format:
# target: prerequisite
# compile commands
#build/obj/main: src/main.c
#"@" tells the gmake to not print the command on the terminal.
#@cc src/main.c -o build/obj/main	
#@echo ${C_DEFINES}
#@echo $(C_INCLUDES)

#example target, without prerequisites
hello:
	@echo "Hello, Surabhi!"
	@echo "Hey, again!"

## clean -> delete all builds
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

## Build the application

#create a list of objects
# add a prefix of $(BUILD_DIR)/ to all C_SOURCES, but for all C_SOURCES
# replace all .c file suffixes to .o
#$(info All C sources: ${C_SOURCES})
#OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
OBJECTS := $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o))) \
#$(BUILD_DIR)/startup_stm32h743xx.o
#$(info All C objects: ${OBJECTS})

#specify the path where some of the prerequisites exist	
# here $dir would extract all dir names in C_SOURCES until the last /
# from all the filenames in C_SOURCES
# sort sorts the words in lexical order & removes duplicate words
vpath %.c $(sort $(dir $(C_SOURCES)))

# list of objects for ASM
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# targets: normal-prerequisites | order-only prerequisites
# normal ones have to be built before the target but the order-only don't force
# the order-only to be built before target is built, since we don't care if the
# timestamps in BUILD_DIR change before target is built, since anyways they are 
# updated every build
# Build object files for C source files
# Compile C source files

# Build object files for C source files
$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "Compiling $<"
	$(CC) -c $(CFLAGS) -o $@ $<

# Build rule for ASM source files
$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo "Assembling $<"
	$(AS) -c $(CFLAGS) -o $@ $<

# Link all object files to create the final ELF file
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	@echo "Linking $(TARGET).elf"
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@


# $@ is the filename of the pre-requisite
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "BUILD_DIR.hex called"
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "BUILD_DIR.bin called"
	$(BIN) $< $@	

# $@ used when there are multiple targets, build the code for all target
# $@ is the name of the target being generated
$(BUILD_DIR):
	@echo "BUILD_DIR called"
	mkdir $@	

# dependencies
-include $(wildcard $(BUILD_DIR)/*.d)