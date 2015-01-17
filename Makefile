WREN_DIR = ../wren

# Compiler flags.
CFLAGS = -std=c99 -Wall -Werror -Wextra
DEBUG_CFLAGS = -O0 -DDEBUG -g
RELEASE_CFLAGS = -Os

# Files.
SOURCES = $(wildcard src/*.c)
HEADERS = $(wildcard src/*.h) $(WREN_DIR)/include/wren.h
OBJECTS = $(SOURCES:.c=.o)

.PHONY: all wren wren-clean wren-debug clean debug test docs watchdocs prep

all: release

# Make upstream wren.
wren:
	@make -C $(WREN_DIR)

wren-clean:
	@make clean -C $(WREN_DIR)

wren-debug:
	@make debug -C $(WREN_DIR)

clean: wren-clean
	@rm -rf build wren-io wrend-io

test: debug
	@./script/test.py

docs:
	@./script/generate_docs.py

watchdocs:
	@./script/generate_docs.py --watch

prep:
	@mkdir -p build/debug build/release

# Debug build.
debug: prep wren-debug wrend-io

# Debug command-line interpreter.
wrend-io: build/debug/main.o
	$(CC) $(CFLAGS) $(DEBUG_CFLAGS) -Iinclude -o wrend-io $^ -lm -lwrend -L$(WREN_DIR)

# Debug object files.
build/debug/%.o: src/%.c $(HEADERS)
	$(CC) -c -fPIC $(CFLAGS) $(DEBUG_CFLAGS) -Iinclude -o $@ $<

# Release build.
release: prep wren-io

# Release command-line interpreter.
wren-io: build/release/main.o
	$(CC) $(CFLAGS) $(RELEASE_CFLAGS) -Iinclude -o wren-io $^ -lm -lwren -L$(WREN_DIR)

# Release object files.
build/release/%.o: src/%.c $(HEADERS)
	$(CC) -c -fPIC $(CFLAGS) $(RELEASE_CFLAGS) -Iinclude -o $@ $<
