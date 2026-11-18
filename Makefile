# Sprint 1 C build configuration.
# Run this Makefile with GNU Make on Linux, including Ubuntu WSL or Alpine.
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

CC ?= cc
GDB ?= gdb
VALGRIND ?= valgrind
CPPFLAGS ?=
CFLAGS ?=
LDFLAGS ?=
LDLIBS ?=
INPUT ?=
VALGRIND_LOG ?= $(LOG_DIR)/valgrind.%p.log
MODE ?= release

BUILD_ROOT := build
LOG_DIR := evidence
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

VALGRIND_FLAGS := --tool=memcheck --leak-check=full --show-leak-kinds=all \
                  --errors-for-leak-kinds=all --track-origins=yes --error-exitcode=99

.PHONY: all release debug static sanitize test gdb gdb-check valgrind memcheck memcheck-tests \
        check-tools check-sources check-tests help clean _build _test

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

gdb: debug
	$(GDB) ./$(BUILD_ROOT)/debug/dots_and_boxes

gdb-check: debug
	@mkdir -p $(LOG_DIR)
	@set -e; for name in scoring double-box invalid; do \
		$(GDB) -q -batch -x debug/$$name.gdb ./$(BUILD_ROOT)/debug/dots_and_boxes \
			> $(LOG_DIR)/gdb-$$name.log 2>&1 || \
			{ cat $(LOG_DIR)/gdb-$$name.log; exit 1; }; \
		printf 'PASS: GDB %s\n' "$$name"; \
	done

valgrind: debug
	@mkdir -p $(LOG_DIR)
	@if [ -n "$(INPUT)" ] && [ ! -r "$(INPUT)" ]; then \
		printf 'Input fixture is not readable: %s\n' "$(INPUT)" >&2; exit 1; \
	fi
	@if [ -n "$(INPUT)" ]; then \
		$(VALGRIND) $(VALGRIND_FLAGS) --log-file="$(VALGRIND_LOG)" \
			./$(BUILD_ROOT)/debug/dots_and_boxes < "$(INPUT)"; \
	else \
		$(VALGRIND) $(VALGRIND_FLAGS) --log-file="$(VALGRIND_LOG)" \
			./$(BUILD_ROOT)/debug/dots_and_boxes; \
	fi

memcheck-tests: test
	@mkdir -p $(LOG_DIR)
	$(VALGRIND) $(VALGRIND_FLAGS) --log-file=$(LOG_DIR)/valgrind-tests.%p.log \
		./$(BUILD_ROOT)/debug/test_runner

memcheck: memcheck-tests
	@set -e; for name in scoring double-box invalid full-game a-win b-win empty; do \
		$(VALGRIND) $(VALGRIND_FLAGS) --log-file=$(LOG_DIR)/valgrind-$$name.log \
			./$(BUILD_ROOT)/debug/dots_and_boxes < tests/fixtures/$$name.in \
			> $(LOG_DIR)/$$name.stdout.txt; \
		printf 'PASS: Memcheck %s\n' "$$name"; \
	done

check-tools:
	@set -e; for tool in $(CC) $(MAKE) $(GDB) $(VALGRIND); do \
		command -v "$$tool" || { printf 'Missing tool: %s\n' "$$tool" >&2; exit 1; }; \
	done

check-sources:
	@missing=0; for file in $(APP_SRC) $(HEADERS); do \
		if [ ! -f "$$file" ]; then printf 'Missing planned source: %s\n' "$$file" >&2; missing=1; fi; \
	done; \
	if [ "$$missing" -ne 0 ]; then \
		printf 'Restore the missing source files before building.\n' >&2; exit 1; \
	fi

check-tests: check-sources
	@missing=0; for file in $(TEST_SRC) tests/test.h tests/cli.sh; do \
		if [ ! -f "$$file" ]; then printf 'Missing planned test: %s\n' "$$file" >&2; missing=1; fi; \
	done; test "$$missing" -eq 0

_build: $(APP)

_test: $(TEST_APP) $(APP)
	./$(TEST_APP)
	sh tests/cli.sh ./$(APP)

$(APP): $(APP_OBJ)
	$(CC) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) $(LDFLAGS) $(MODE_LDFLAGS_$(MODE)) $^ $(LDLIBS) -o $@

$(TEST_APP): $(TEST_OBJ)
	$(CC) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) $(LDFLAGS) $(MODE_LDFLAGS_$(MODE)) $^ $(LDLIBS) -o $@

$(BUILD_DIR)/%.o: %.c Makefile
	@mkdir -p $(@D)
	$(CC) $(PROJECT_CPPFLAGS) $(CPPFLAGS) $(BASE_FLAGS) $(MODE_CFLAGS_$(MODE)) $(CFLAGS) \
		-MMD -MP -c $< -o $@

help:
	@printf '%s\n' \
	  'Dots and Boxes - Sprint 1 (C11)' \
	  'make / make release  Build optimized game in build/release/' \
	  'make debug           Build with GDB/Valgrind symbols in build/debug/' \
	  'make static          Build a self-contained Linux executable for the VM' \
	  'make test            Run unit and console regression tests' \
	  'make gdb             Open the debug game in GDB' \
	  'make gdb-check       Replay three GDB state-inspection sessions' \
	  'make valgrind        Run debug game under Memcheck; optional INPUT=file' \
	  'make memcheck-tests  Run unit tests under Memcheck' \
	  'make memcheck        Memcheck unit tests and seven console scenarios' \
	  'make sanitize        Run tests with ASan/UBSan, separately from Valgrind' \
	  'make check-tools     Locate C compiler, Make, GDB, and Valgrind' \
	  'make check-sources   Check the planned application sources and headers' \
	  'make clean           Remove build/; preserve evidence/'

clean:
	rm -rf $(BUILD_ROOT)

-include $(DEPS)
