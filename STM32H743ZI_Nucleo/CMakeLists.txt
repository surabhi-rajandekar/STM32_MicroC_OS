cmake_minimum_required(VERSION 3.18)

# Setup compiler settings
set(CMAKE_C_STANDARD                11)
set(CMAKE_C_STANDARD_REQUIRED       ON)
set(CMAKE_C_EXTENSIONS              ON)
set(CMAKE_CXX_STANDARD              20)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            ON)
set(PROJ_PATH                       ${CMAKE_CURRENT_SOURCE_DIR})
set(MICRO_OS_PATH                   ${CMAKE_CURRENT_SOURCE_DIR}/Micrium/Software)
set(ST_PATH                         ${CMAKE_CURRENT_SOURCE_DIR}/ST)
message("Build type: "              ${CMAKE_BUILD_TYPE})
set(CMAKE_CROSSCOMPILING     1)

#
# Core project settings
#
project(BLINKY)
enable_language(C CXX ASM)

#
# Core MCU flags, CPU, instruction set and FPU setup
# Needs to be set properly for your MCU
#
set(CPU_PARAMETERS
    -mthumb

    # This needs attention to properly set for used MCU
    -mcpu=cortex-m7                 # Modified
    -mfpu=fpv5-d16                  # Modified
    -mfloat-abi=hard                # Modified
)

# Set linker script
set(linker_script_SRC               ${PROJ_PATH}/ST/BSP/Startup/STM32H7xx/GCC/stm32h7_flash.ld) # Modified
set(EXECUTABLE                      ${CMAKE_PROJECT_NAME})

#
# List of source files to compile
#

# Split source files into directories

set(MICRIUM_UC_CPU
    ${MICRO_OS_PATH}/uC-CPU/cpu_core.c
    ${MICRO_OS_PATH}/uC-CPU/ARM-Cortex-M4/GNU/cpu_c.c
)

set(MICRIUM_UC_LIB
    ${MICRO_OS_PATH}/uC-LIB/lib_ascii.c
    ${MICRO_OS_PATH}/uC-LIB/lib_math.c
    ${MICRO_OS_PATH}/uC-LIB/lib_mem.c
    ${MICRO_OS_PATH}/uC-LIB/lib_str.c 
)

set(MICRIUM_UCOS_III
    ${MICRO_OS_PATH}/uCOS-III/Source/os_cfg_app.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_core.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_dbg.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_flag.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_mem.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_mon.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_msg.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_mutex.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_prio.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_q.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_sem.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_stat.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_task.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_tick.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_time.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_tmr.c
    ${MICRO_OS_PATH}/uCOS-III/Source/os_var.c
    ${MICRO_OS_PATH}/uCOS-III/Ports/ARM-Cortex-M/ARMv7-M/GNU/os_cpu_c.c
)

set(ST_BSP
    ${ST_PATH}/BSP/Interrupts/bsp_int_armv7m.c
    ${ST_PATH}/BSP/Startup/STM32H7xx/system_stm32h7xx.c
    ${ST_PATH}/BSP/STM32H743ZI_Nucleo/bsp_clk.c
    ${ST_PATH}/BSP/STM32H743ZI_Nucleo/bsp_cpu.c
    ${ST_PATH}/BSP/STM32H743ZI_Nucleo/bsp_led.c
    ${ST_PATH}/BSP/STM32H743ZI_Nucleo/bsp_os.c
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_gpio.c
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal.c
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc.c
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_cortex.c
    ${ST_PATH}/BSP/SDK/STM32CubeH7/Drivers/STM32H7xx_HAL_Driver/Src/stm32h7xx_hal_rcc_ex.c
    )

set(ST_STM32H743ZI_NUCLEO
    ${ST_PATH}/STM32H743ZI_Nucleo/Blinky/OS3/main.c
    ${ST_PATH}/STM32H743ZI_Nucleo/Blinky/OS3/os_app_hooks.c
)

set(ASM_SOURCES
    ${ST_PATH}/BSP/Startup/STM32H7xx/GCC/startup_stm32h743xx.s
    ${MICRO_OS_PATH}/uCOS-III/Ports/ARM-Cortex-M/ARMv7-M/GNU/os_cpu_a.s
    ${MICRO_OS_PATH}/uC-CPU/ARM-Cortex-M4/GNU/cpu_a.s 
)

set(sources_SRCS
    ${ASM_SOURCES}
    ${MICRIUM_UC_CPU}
    ${MICRIUM_UC_LIB}
    ${MICRIUM_UCOS_III}
    ${ST_BSP}
    ${ST_STM32H743ZI_NUCLEO}
)

#print source files
#message(source files="${sources_SRCS}")

#
# Include directories
#
set(include_path_DIRS               # Modified
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


#
# Symbols definition
#
set(symbols_SYMB                    # Modified
    "DEBUG"
    "STM32H743ZI"
    "STM32H743xx"
)

# Executable files
add_executable(${EXECUTABLE} ${sources_SRCS})

# Include paths
target_include_directories(${EXECUTABLE} PRIVATE ${include_path_DIRS})

# Project symbols
target_compile_definitions(${EXECUTABLE} PRIVATE ${symbols_SYMB})

# Compiler options
target_compile_options(${EXECUTABLE} PRIVATE
    ${CPU_PARAMETERS}
    -Wall
    -Wextra
    -Wpedantic
    -Wno-unused-parameter
    # Full debug configuration
    -Og -g3 -ggdb
)

# Linker options
target_link_options(${EXECUTABLE} PRIVATE
    -T${linker_script_SRC}
    ${CPU_PARAMETERS}
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    --specs=nosys.specs
    -u _printf_float                # STDIO float formatting support
    -Wl,--start-group
    -lc
    -lm
    -lstdc++
    -lsupc++
    -Wl,--end-group
    -Wl,--print-memory-usage
)

# Execute post-build to print size
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>
)

# Convert output to hex and binary
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.hex
)

# Convert to bin file -> add conditional check?
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.bin
)