# Sprint 1 C build configuration.
# Run this Makefile with GNU Make on Linux, including Ubuntu WSL or Alpine.
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

CC ?= cc
CPPFLAGS ?=
CFLAGS ?=
LDFLAGS ?=
LDLIBS ?=
MODE ?= release

BUILD_ROOT := build
BUILD_DIR := $(BUILD_ROOT)/$(MODE)
APP := $(BUILD_DIR)/dots_and_boxes
TEST_APP := $(BUILD_DIR)/test_runner

LIB_SRC := src/board.c src/game.c src/input.c
APP_SRC := src/main.c $(LIB_SRC)
HEADERS := include/board.h include/game.h include/input.h
TEST_SRC := tests/test_main.c tests/test_board.c tests/test_game.c tests/test_input.c
APP_OBJ := $(patsubst %.c,$(BUILD_DIR)/%.o,$(APP_SRC))
TEST_OBJ := $(patsubst %.c,$(BUILD_DIR)/%.o,$(TEST_SRC) $(LIB_SRC))
DEPS := $(sort $(APP_OBJ:.o=.d) $(TEST_OBJ:.o=.d))

BASE_FLAGS := -std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wconversion \
              -Wstrict-prototypes -Wmissing-prototypes
PROJECT_CPPFLAGS := -Iinclude
MODE_CFLAGS_release := -O2 -DNDEBUG
MODE_CFLAGS_debug := -O0 -g3 -fno-omit-frame-pointer
MODE_CFLAGS_sanitize := -O1 -g3 -fno-omit-frame-pointer -fsanitize=address,undefined
MODE_LDFLAGS_sanitize := -fsanitize=address,undefined
MODE_CFLAGS_static := -O2 -DNDEBUG
MODE_LDFLAGS_static := -static

ifeq ($(filter $(MODE),release debug sanitize static),)
$(error MODE must be release, debug, sanitize, or static)
endif

.PHONY: all release debug static sanitize test check-sources check-tests help clean _build _test

all: release

release: check-sources
	$(MAKE) MODE=release _build

debug: check-sources
	$(MAKE) MODE=debug _build

static: check-sources
	$(MAKE) MODE=static _build

sanitize: check-tests
	$(MAKE) MODE=sanitize _test

test: check-tests
	$(MAKE) MODE=debug _test

check-sources:
	@missing=0; for file in $(APP_SRC) $(HEADERS); do \
		if [ ! -f "$$file" ]; then printf 'Missing planned source: %s\n' "$$file" >&2; missing=1; fi; \
	done; \
	if [ "$$missing" -ne 0 ]; then \
		printf 'Restore the missing source files before building.\n' >&2; exit 1; \
	fi

check-tests: check-sources
	@missing=0; for file in $(TEST_SRC) tests/test.h; do \
		if [ ! -f "$$file" ]; then printf 'Missing planned test: %s\n' "$$file" >&2; missing=1; fi; \
	done; test "$$missing" -eq 0

_build: $(APP)

_test: $(TEST_APP) $(APP)
	./$(TEST_APP)

$(APP): $(APP_OBJ)
	$(CC) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) $(LDFLAGS) $(MODE_LDFLAGS_$(MODE)) $^ $(LDLIBS) -o $@

$(TEST_APP): $(TEST_OBJ)
	$(CC) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) $(LDFLAGS) $(MODE_LDFLAGS_$(MODE)) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/%.o: %.c Makefile
	@mkdir -p $(@D)
	$(CC) $(PROJECT_CPPFLAGS) $(CPPFLAGS) $(BASE_FLAGS) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) \
		-MMD -MP -c $< -o $@

help:
	@printf '%s\n' 'make / make release: build the console game' 'make debug: build with debugger symbols' 'make test: run unit tests' 'make sanitize: run ASan/UBSan checks' 'make static: build without shared libraries' 'make clean: remove build/'

clean:
	rm -rf $(BUILD_ROOT)

-include $(DEPS)
