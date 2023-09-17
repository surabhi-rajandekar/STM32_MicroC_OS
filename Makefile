#!/usr/bin/ld

#Variables
WORKSPACE_PATH := /home/surabhi/Projects/STM32_MicroC_OS
MICRO_OS_PATH := $(WORKSPACE_PATH)/infra/uC-OS3

MICRO_OS_SOURCES := $(wildcard $(MICRO_OS_PATH)/Cfg/Template/*.c) \
					$(wildcard $(MICRO_OS_PATH)/Source/*.c)

MICRO_OS_DEFINES := $(wildcard $(MICRO_OS_PATH)/Cfg/Template/*.h) \
					$(wildcard $(MICRO_OS_PATH)/Source/*.h)

#MICRO_OS_INCLUDES := $(wildcard $(WORKSPACE_PATH)/infra/uC-OS3/*.h)

CC_DEFINES := 	$(WORKSPACE_PATH)/drivers/src/ \
				$(WORKSPACE_PATH)/src/ \
				$(MICRO_OS_SOURCES)

CC_INCLUDES :=	$(WORKSPACE_PATH)/drivers/inc/ \
				$(MICRO_OS_DEFINES)


# now we have a target called main, which compiles main.c when called,
# if I run without a target name, first target in the file is run
#format:
# target: prerequisite
# compile commands
build/obj/main: src/main.c
#"@" tells the gmake to not print the command on the terminal.
	@cc src/main.c -o build/obj/main	
	@echo ${CC_DEFINES}
	@echo $(CC_INCLUDES)

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