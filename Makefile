CFLAGS64 = -ggdb -Wall -Wextra -std=c99 -pedantic -m64
# CFLAGS64 = -O3 -Wall -std=c99 -pedantic -m64

CFLAGS   = $(CFLAGS64)

BUILD_DIR = build
BIN = asm_image_proc

FILTERS = cropflip sepia

FILTERS_OBJ =  $(addsuffix .o, $(FILTERS)) $(addsuffix _asm.o, $(FILTERS))
LIBS_OBJS   = libbmp.o
MAIN_OBJS   = main.o
MAIN_OBJS_WITH_PATH = $(addprefix $(BUILD_DIR)/, $(MAIN_OBJS))

OBJS = $(MAIN_OBJS) $(LIBS_OBJS) $(FILTERS_OBJ)
OBJS_WITH_PATH = $(addprefix $(BUILD_DIR)/, $(OBJS))

.PHONY: all clean FORCE

all: $(BUILD_DIR)/$(BIN)


$(BUILD_DIR)/$(BIN): FORCE $(MAIN_OBJS_WITH_PATH)
	$(CC) $(CFLAGS) $(OBJS_WITH_PATH) -o $@ -lm

export CFLAGS64
FORCE:
	make -C external
	make -C filters

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $< -lm

clean:
	rm -fr $(BUILD_DIR)/*
