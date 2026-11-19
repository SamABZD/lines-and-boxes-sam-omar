CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -g
CPPFLAGS = -Iinclude

CORE = src/board.c src/input.c src/game.c
SOURCES = src/main.c $(CORE)
OBJECTS = $(SOURCES:.c=.o)
HEADERS = include/board.h include/input.h include/game.h
OUTPUT = dotsboxes

$(OUTPUT): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

src/%.o: src/%.c $(HEADERS) Makefile
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

.PHONY: test gdb valgrind static clean

TESTS = tests/test_main.c tests/test_board.c tests/test_input.c tests/test_game.c

build/test_runner: $(TESTS) $(CORE:.c=.o) $(HEADERS) tests/test.h Makefile
	@mkdir -p build
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) $(TESTS) $(CORE:.c=.o) $(LDLIBS) -o $@

test: $(OUTPUT) build/test_runner
	./build/test_runner
	sh tests/cli.sh ./$(OUTPUT)

gdb: $(OUTPUT)
	gdb ./$(OUTPUT)

valgrind: $(OUTPUT)
	valgrind --leak-check=full --error-exitcode=1 --log-file=valgrind.txt ./$(OUTPUT)
	@cat valgrind.txt

# The VM uses a static copy of the game.
static: build/static/dots_and_boxes

build/static/dots_and_boxes: $(SOURCES) $(HEADERS) Makefile
	@mkdir -p build/static
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -static $(SOURCES) $(LDLIBS) -o $@

clean:
	rm -f $(OBJECTS) $(OUTPUT) build/test_runner build/static/dots_and_boxes valgrind.txt
