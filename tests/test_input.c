#include "test.h"

#include <string.h>

#include "input.h"

static FILE *input_stream(const char *text)
{
    FILE *stream = tmpfile();
    CHECK(stream != NULL);
    CHECK(fputs(text, stream) >= 0);
    rewind(stream);
    return stream;
}

void test_input(void)
{
    const char *invalid[] = {
        "", " ", "hello", "0 0 0", "0 0 0 1 2", "0 0 0 1 extra",
        "0+0 0 1", "0 0 0 1.0", "0 0 0 1x", "0x0 0 0 1",
        "999999999999999999999999999999 0 0 1",
        "-999999999999999999999999999999 0 0 1"
    };
    Move move = {9, 8, 7, 6};
    Move before;
    FILE *stream;
    const char binary_input[] = "0 0\0 0 1\n0 0 0 1\n";

    for (size_t i = 0U; i < sizeof invalid / sizeof invalid[0]; ++i) {
        before = move;
        CHECK(parse_move(invalid[i], &move) == INPUT_INVALID);
        CHECK(move.r1 == before.r1 && move.c1 == before.c1 &&
              move.r2 == before.r2 && move.c2 == before.c2);
    }
    CHECK(parse_move(" \t+0 0 0 1 \r\n", &move) == INPUT_OK);
    CHECK(move.r1 == 0 && move.c1 == 0 && move.r2 == 0 && move.c2 == 1);
    CHECK(parse_move("-1 0 0 0", &move) == INPUT_OK);
    CHECK(move.r1 == -1); /* Parsing and coordinate validation are separate. */
    stream = input_stream("\nhello\r\n0 0 0 1\r\n1 0 1 1");
    CHECK(input_read_move(stream, &move) == INPUT_INVALID);
    CHECK(input_read_move(stream, &move) == INPUT_INVALID);
    CHECK(input_read_move(stream, &move) == INPUT_OK);
    CHECK(move.r2 == 0 && move.c2 == 1);
    CHECK(input_read_move(stream, &move) == INPUT_OK);
    CHECK(move.r2 == 1 && move.c2 == 1);
    CHECK(input_read_move(stream, &move) == INPUT_EOF);
    CHECK(fclose(stream) == 0);

    stream = tmpfile();
    CHECK(stream != NULL);
    for (unsigned i = 0U; i < MOVE_INPUT_CAPACITY + 10U; ++i) {
        CHECK(fputc('x', stream) != EOF);
    }
    CHECK(fputs("\n0 0 0 1\n", stream) >= 0);
    rewind(stream);
    before = move;
    CHECK(input_read_move(stream, &move) == INPUT_TOO_LONG);
    CHECK(memcmp(&before, &move, sizeof move) == 0);
    CHECK(input_read_move(stream, &move) == INPUT_OK);
    CHECK(input_read_move(stream, &move) == INPUT_EOF);
    CHECK(fclose(stream) == 0);

    stream = tmpfile();
    CHECK(stream != NULL);
    CHECK(fwrite(binary_input, 1U, sizeof binary_input - 1U, stream) ==
          sizeof binary_input - 1U);
    rewind(stream);
    CHECK(input_read_move(stream, &move) == INPUT_INVALID);
    CHECK(input_read_move(stream, &move) == INPUT_OK);
    CHECK(fclose(stream) == 0);

    stream = input_stream("");
    CHECK(input_read_move(stream, &move) == INPUT_EOF);
    CHECK(fclose(stream) == 0);
}
