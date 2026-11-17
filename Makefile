# Batch 1: portable board rules and safe input, built with GNU Make on Linux/WSL.
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
CC ?= cc
AR ?= ar
CPPFLAGS ?=
CFLAGS ?= -O0 -g3
LDFLAGS ?=
LDLIBS ?=
BUILD := build/core
CORE_SRC := src/board.c src/input.c
TEST_SRC := tests/test_main.c tests/test_board.c tests/test_input.c
CORE_OBJ := $(patsubst %.c,$(BUILD)/%.o,$(CORE_SRC))
TEST_OBJ := $(patsubst %.c,$(BUILD)/%.o,$(TEST_SRC))
FLAGS := -std=c11 -Wall -Wextra -Wpedantic -Wshadow -Wconversion \
         -Wstrict-prototypes -Wmissing-prototypes
DEPS := $(CORE_OBJ:.o=.d) $(TEST_OBJ:.o=.d)

.PHONY: all test clean help
all: $(BUILD)/libdots_core.a

$(BUILD)/libdots_core.a: $(CORE_OBJ)
	$(AR) rcs $@ $^

$(BUILD)/test_runner: $(TEST_OBJ) $(BUILD)/libdots_core.a
	$(CC) $(CFLAGS) $(LDFLAGS) $^ $(LDLIBS) -o $@

test: $(BUILD)/test_runner
	./$(BUILD)/test_runner

$(BUILD)/%.o: %.c Makefile
	@mkdir -p $(@D)
	$(CC) -Iinclude $(CPPFLAGS) $(FLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

help:
	@printf '%s\n' 'make: build the board/input library' 'make test: run board/input tests' 'make clean: remove build/core only'

clean:
	rm -rf $(BUILD)

-include $(DEPS)
