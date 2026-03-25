ifeq ($(PLATFORM),MSP432)
	SOURCES = src/main.c \
		  src/memory.c \
		  src/startup_msp432p401r_gcc.c \
		  src/system_msp432p401r.c \
		  src/interrupts_msp432p401r_gcc.c

	INCLUDES = -Iinclude/CMSIS \
		   -Iinclude/common \
		   -Iinclude/msp432
else
	SOURCES = src/main.c \
		  src/memory.c

	INCLUDES = -Iinclude/common
endif