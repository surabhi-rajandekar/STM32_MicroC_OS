# Target
TARGET := stm32h743zi

# Build configuration
DEBUG = 1 
OPT = -Og

# Paths
WORKSPACE_PATH := C:/Users/srajandekar/Personal_Projects/STM32_MicroC_OS/STM32H743ZI_Nucleo

MICRO_OS_PATH := $(WORKSPACE_PATH)/Micrium/Software
ST_PATH := $(WORKSPACE_PATH)\ST

TOOLCHAIN_PATH := C:/Program Files (x86)/Arm GNU Toolchain arm-none-eabi/11.2 2022.02/bin

BUILD_DIR := $(WORKSPACE_PATH)/Build

# Specify source directories
SRC_DIRS := \
	$(MICRO_OS_PATH)/uC-CPU \
	$(MICRO_OS_PATH)/uC-CPU/ARM-Cortex-M4/GNU \
	$(MICRO_OS_PATH)/uC-LIB \
	$(MICRO_OS_PATH)/uCOS-III/Source \
	$(MICRO_OS_PATH)/uCOS-III/Ports/ARM-Cortex-M/ARMv7-M/GNU \
	$(ST_PATH)/BSP/Interrupts \
	$(ST_PATH)/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src \
	$(ST_PATH)/BSP/Startup/STM32H7xx \
	$(ST_PATH)/BSP/STM32H743ZI_Nucleo \
	$(ST_PATH)/STM32H743ZI_Nucleo/Blinky/OS3

# Source files
C_SOURCES := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.c))
ASM_SOURCES := $(ST_PATH)/BSP/Startup/STM32H7xx/GCC/startup_stm32h743xx.s \
				$(MICRO_OS_PATH)/uCOS-III/Ports/ARM-Cortex-M/ARMv7-M/GNU/os_cpu_a.s \
				$(MICRO_OS_PATH)/uC-CPU/ARM-Cortex-M4/GNU/cpu_a.s 

# Includes
set(include_path_DIRS 
    ${MICRO_OS_PATH}/uC-CPU
    ${MICRO_OS_PATH}/uC-CPU/ARM-Cortex-M4/GNU
    ${MICRO_OS_PATH}/uC-LIB
    ${MICRO_OS_PATH}/uCOS-III/Source
    ${MICRO_OS_PATH}/uCOS-III/Ports/ARM-Cortex-M/ARMv7-M/GNU
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/CMSIS/Device/ST/STM32H7xx/Include
    ${ST_PATH}/BSP/STM32H743ZI_Nucleo
    ${ST_PATH}/STM32H743ZI_Nucleo/Blinky
    ${ST_PATH}/STM32H743ZI_Nucleo/Blinky/OS3
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Inc
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Inc/Legacy
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/CMSIS/Include
)

# Binaries
PREFIX = arm-none-eabi-
CC = $(TOOLCHAIN_PATH)/$(PREFIX)gcc
AS = $(TOOLCHAIN_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(TOOLCHAIN_PATH)/$(PREFIX)objcopy
SZ = $(TOOLCHAIN_PATH)/$(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# CFLAGS
CPU = -mcpu=cortex-m7
FPU = -mfpu=fpv5-d16
FLOAT-ABI = -mfloat-abi=hard
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)
C_DEFS = -DSTM32H743xx

CFLAGS += $(MCU) $(C_DEFS) $(addprefix -I,$(C_INCLUDES)) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g3 -gdwarf-2
endif

CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

LDSCRIPT = $(ST_PATH)/BSP/Startup/STM32H7xx/GCC/stm32h7_flash.ld
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# dependencies
-include $(wildcard $(BUILD_DIR)/*.d)

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@echo "Compiling $<"
	$(CC) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@echo "Assembling $<"
	$(AS) -c $(CFLAGS) -o $@ $<

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	@echo "Linking $(TARGET).elf"
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "BUILD_DIR.hex called"
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo "BUILD_DIR.bin called"
	$(BIN) $< $@	

$(BUILD_DIR):
	@echo "BUILD_DIR called"
	mkdir $@	

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
