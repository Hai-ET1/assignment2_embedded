include sources.mk

# Platform Overrides
PLATFORM = HOST
TARGET = c1m2
# Thêm -Wno-attributes để tránh lỗi trên GCC bản mới
GCFLAGS = -Wall -Werror -g -O0 -std=c99 -Wno-attributes

# Architectures Specific Flags
ifeq ($(PLATFORM),MSP432)
	LINKER_FILE = msp432p401r.lds
	CPU = cortex-m4
	ARCH = thumb
	ARCH_CAT = armv7e-m
	FPU = fpv4-sp-d16
	FLOAT_ABI = hard 
	SPECS = nosys.specs
else
	CPU = $(shell cpu)
	ARCH = $(shell arch)
endif

# Compiler & Linker Flags
ifeq ($(PLATFORM),MSP432)
	CC = arm-none-eabi-gcc
	LD = arm-none-eabi-ld
	# QUAN TRỌNG: Thêm các thông số CPU/FPU vào LDFLAGS để Linker không bị lỗi VFP
	LDFLAGS = -Wl,-Map=$(TARGET).map -T $(LINKER_FILE) -mcpu=$(CPU) -m$(ARCH) -march=$(ARCH_CAT) -mfloat-abi=$(FLOAT_ABI) -mfpu=$(FPU) --specs=$(SPECS)
	CFLAGS = -mcpu=$(CPU) -m$(ARCH) -march=$(ARCH_CAT) -mfloat-abi=$(FLOAT_ABI) -mfpu=$(FPU) --specs=$(SPECS) $(GCFLAGS)
	CPPFLAGS = -DMSP432 $(INCLUDES)
	SIZE = arm-none-eabi-size
	OBJDUMP = arm-none-eabi-objdump
else
	CC = gcc
	LDFLAGS = -Wl,-Map=$(TARGET).map
	CFLAGS = $(GCFLAGS)
	CPPFLAGS = -DHOST $(INCLUDES)
	SIZE = size
	OBJDUMP = objdump
endif

OBJS = $(SOURCES:.c=.o)
DEPS = $(SOURCES:.c=.d)

.PHONY: build
build: $(TARGET).out

# Lệnh liên kết cuối cùng
$(TARGET).out: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) $(CFLAGS) -o $@
	$(SIZE) $@
	$(OBJDUMP) -D $(TARGET).out > $(TARGET).asm

# Lệnh biên dịch file đối tượng
%.o : %.c
	$(CC) -c $< $(CFLAGS) $(CPPFLAGS) -o $@

.PHONY: clean
clean:
	rm -f src/*.o *.out *.map *.asm *.d *.i