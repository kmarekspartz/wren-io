WREN_DIR := deps/wren

# Compiler flags.
CFLAGS := -std=c99 -Wall -Werror -Wextra
DEBUG_CFLAGS := -O0 -DDEBUG -g -v
RELEASE_CFLAGS := -Os

# Detect the OS.
TARGET_OS := $(lastword $(subst -, ,$(shell $(CC) -dumpmachine)))

# Don't add -fPIC on Windows since it generates a warning which gets promoted
# to an error by -Werror.
ifeq      ($(TARGET_OS),mingw32)
else ifeq ($(TARGET_OS),cygwin)
	# Do nothing.
else
	CFLAGS += -fPIC
endif

# Files.
SOURCES := $(wildcard src/*.c)
HEADERS := $(wildcard src/*.h)
OBJECTS := $(SOURCES:.c=.o)

DEBUG_OBJECTS := $(addprefix build/debug/, $(notdir $(OBJECTS)))
RELEASE_OBJECTS := $(addprefix build/release/, $(notdir $(OBJECTS)))

.PHONY: all wren wren-debug clean debug test docs watchdocs release prep c-wren git-pull-wren

all: release

clean:
	@rm -rf include lib build wren-io wrend-io deps src/wren_io_*.c src/wren_io_*.h

prep: lib include
	@make c-wren
	@mkdir -p build/debug build/release

# Dependencies
deps:
	@mkdir deps

include: wren wren-debug
	@mkdir -p include
	@cp deps/wren/include/* include

lib: wren wren-debug
	@mkdir -p lib
	@cp deps/wren/lib*.a lib

# Make upstream wren.
wren: git-pull-wren
	@make -C $(WREN_DIR)

git-pull-wren: deps
	@cd deps && [ -d wren ] || git clone git@github.com:munificent/wren.git

wren-debug: git-pull-wren
	@make debug -C $(WREN_DIR)

# Debug build.
debug: prep
	@make c-wren
	@make wrend-io

# Debug command-line interpreter.
wrend-io: $(DEBUG_OBJECTS)
	$(CC) $(CFLAGS) $(DEBUG_CFLAGS) -Isrc -Iinclude -o $@ $^ -lwren -Llib

# Debug object files.
build/debug/%.o: src/%.c $(HEADERS)
	$(CC) -c $(CFLAGS) $(DEBUG_CFLAGS) -Isrc  -Iinclude -o $@ $<

# Release build.
release: prep
	@make wren-io

# Release command-line interpreter.
wren-io: $(RELEASE_OBJECTS)
	$(CC) $(CFLAGS) $(RELEASE_CFLAGS) -Isrc -Iinclude -o wren-io $^ -lwren -Llib

# Release object files.
build/release/%.o: src/%.c $(HEADERS)
	$(CC) -c $(CFLAGS) $(RELEASE_CFLAGS) -Isrc -Iinclude -o $@ $<

test: debug
	@./script/test.py

c-wren:
	@./script/generate_c_wren.py

docs:
	@./script/generate_docs.py

watchdocs:
	@./script/generate_docs.py --watch
