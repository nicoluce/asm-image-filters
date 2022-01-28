
ASM = nasm
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	ASMFLAGS64 = -felf64 -g -F dwarf
endif
ifeq ($(UNAME_S),Darwin)
	ASMFLAGS64 = -fmacho64 -g -DDARWIN
endif

ASMFLAGS = $(ASMFLAGS64)

CFLAGS64 ?=-Wall -Wextra -pedantic -ggdb
CFLAGS=$(CFLAGS64)


BUILD_DIR = ../build

FILTERS = cropflip sepia

FILTERS_OBJ =  $(addsuffix .o, $(FILTERS)) $(addsuffix _asm.o, $(FILTERS))
FILTERS_OBJ_WITH_PATH = $(addprefix  $(BUILD_DIR)/, $(FILTERS_OBJ))

.PHONY: filters clean

filters: $(FILTERS_OBJ_WITH_PATH)

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean:
	rm -f $(FILTERS_OBJ_WITH_PATH)
