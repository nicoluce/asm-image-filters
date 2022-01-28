CFLAGS=-Wall -Wextra -pedantic -O3 -ggdb -std=c99

BUILD_DIR = ../build
BIN = asm_image_proc

OBJS           = libbmp.o
OBJS_WITH_PATH = $(addprefix $(BUILD_DIR)/, $(OBJS))


.PHONY: all clean libbmp

all: $(OBJS_WITH_PATH)

lib: all

$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS_WITH_PATH)