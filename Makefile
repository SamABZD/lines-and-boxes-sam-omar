CC ?= cc
GDB ?= gdb
VALGRIND ?= valgrind

CORE = src/board.c src/game.c src/input.c
GAME = src/main.c $(CORE)
TESTS = tests/test_main.c tests/test_board.c tests/test_game.c tests/test_input.c $(CORE)
HEADERS = include/board.h include/game.h include/input.h
COMPILE = $(CC) -Iinclude $(CPPFLAGS) -std=c11 -Wall -Wextra -Wpedantic \
	-Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes

DEBUG_FLAGS = -O0 -g3 -fno-omit-frame-pointer
SANITIZE_FLAGS = -O1 -g3 -fno-omit-frame-pointer -fsanitize=address,undefined
RELEASE_GAME = build/release/dots_and_boxes
DEBUG_GAME = build/debug/dots_and_boxes
DEBUG_TESTS = build/debug/test_runner
STATIC_GAME = build/static/dots_and_boxes
SANITIZE_GAME = build/sanitize/dots_and_boxes
SANITIZE_TESTS = build/sanitize/test_runner

LOG_DIR ?= build/logs
VALGRIND_LOG ?= $(LOG_DIR)/valgrind.%p.log
MEMCHECK = $(VALGRIND) --leak-check=full --show-leak-kinds=all \
	--errors-for-leak-kinds=all --track-origins=yes --error-exitcode=99
CASES = scoring double-box invalid full-game a-win b-win empty

.PHONY: all release debug static test sanitize gdb gdb-check valgrind memcheck-tests memcheck check-tools help clean
.DELETE_ON_ERROR:

all: release
release: $(RELEASE_GAME)
debug: $(DEBUG_GAME)
static: $(STATIC_GAME)

# Each command builds one executable from its C files.
$(RELEASE_GAME): $(GAME) $(HEADERS) Makefile
	@mkdir -p $(@D)
	$(COMPILE) -O2 -DNDEBUG $(CFLAGS) $(GAME) $(LDFLAGS) $(LDLIBS) -o $@

$(DEBUG_GAME): $(GAME) $(HEADERS) Makefile
	@mkdir -p $(@D)
	$(COMPILE) $(DEBUG_FLAGS) $(CFLAGS) $(GAME) $(LDFLAGS) $(LDLIBS) -o $@

$(STATIC_GAME): $(GAME) $(HEADERS) Makefile
	@mkdir -p $(@D)
	$(COMPILE) -O2 -DNDEBUG $(CFLAGS) $(GAME) $(LDFLAGS) -static $(LDLIBS) -o $@

$(DEBUG_TESTS): $(TESTS) $(HEADERS) tests/test.h Makefile
	@mkdir -p $(@D)
	$(COMPILE) $(DEBUG_FLAGS) $(CFLAGS) $(TESTS) $(LDFLAGS) $(LDLIBS) -o $@

$(SANITIZE_GAME): $(GAME) $(HEADERS) Makefile
	@mkdir -p $(@D)
	$(COMPILE) $(SANITIZE_FLAGS) $(CFLAGS) $(GAME) $(LDFLAGS) $(LDLIBS) -o $@

$(SANITIZE_TESTS): $(TESTS) $(HEADERS) tests/test.h Makefile
	@mkdir -p $(@D)
	$(COMPILE) $(SANITIZE_FLAGS) $(CFLAGS) $(TESTS) $(LDFLAGS) $(LDLIBS) -o $@

test: $(DEBUG_TESTS) $(DEBUG_GAME)
	./$(DEBUG_TESTS)
	sh tests/cli.sh ./$(DEBUG_GAME)

sanitize: $(SANITIZE_TESTS) $(SANITIZE_GAME)
	./$(SANITIZE_TESTS)
	sh tests/cli.sh ./$(SANITIZE_GAME)

gdb: debug
	$(GDB) ./$(DEBUG_GAME)

gdb-check: debug
	@mkdir -p "$(LOG_DIR)"
	@set -e; for name in scoring double-box invalid; do \
		log="$(LOG_DIR)/gdb-$$name.log"; \
		$(GDB) -q -batch -x "debug/$$name.gdb" ./$(DEBUG_GAME) > "$$log" 2>&1 || { cat "$$log"; exit 1; }; \
		printf 'PASS: GDB %s\n' "$$name"; \
	done

valgrind: debug
	@mkdir -p "$(LOG_DIR)"
	@if [ -n "$(INPUT)" ]; then \
		$(MEMCHECK) --log-file="$(VALGRIND_LOG)" ./$(DEBUG_GAME) < "$(INPUT)"; \
	else \
		$(MEMCHECK) --log-file="$(VALGRIND_LOG)" ./$(DEBUG_GAME); \
	fi

memcheck-tests: test
	@mkdir -p "$(LOG_DIR)"
	$(MEMCHECK) --log-file="$(LOG_DIR)/valgrind-tests.%p.log" ./$(DEBUG_TESTS)

memcheck: memcheck-tests
	@set -e; for name in $(CASES); do \
		$(MEMCHECK) --log-file="$(LOG_DIR)/valgrind-$$name.log" ./$(DEBUG_GAME) \
			< "tests/fixtures/$$name.in" > "$(LOG_DIR)/$$name.stdout.txt"; \
		printf 'PASS: Memcheck %s\n' "$$name"; \
	done

check-tools:
	@set -e; for tool in $(firstword $(CC)) $(MAKE) $(GDB) $(VALGRIND); do command -v "$$tool"; done

help:
	@printf '%s\n' 'make          Build the game' 'make test     Run the tests' \
		'make gdb      Open GDB' 'make gdb-check  Run GDB checks' \
		'make memcheck  Run Valgrind checks' 'make sanitize  Run sanitizer checks'

clean:
	rm -rf build/release build/debug build/static build/sanitize build/logs
