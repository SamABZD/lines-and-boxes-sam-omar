#include "input.h"

#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdbool.h>
#include <stdlib.h>

InputStatus parse_move(const char *line, Move *move)
{
    int values[4];
    const char *cursor = line;

    for (unsigned i = 0U; i < 4U; ++i) {
        char *end;
        long value;

        while (isspace((unsigned char)*cursor)) {
            ++cursor;
        }
        errno = 0;
        value = strtol(cursor, &end, 10);
        if (end == cursor || errno == ERANGE || value < INT_MIN || value > INT_MAX) {
            return INPUT_INVALID;
        }
        if (*end != '\0' && !isspace((unsigned char)*end)) {
            return INPUT_INVALID;
        }
        values[i] = (int)value;
        cursor = end;
    }
    while (isspace((unsigned char)*cursor)) {
        ++cursor;
    }
    if (*cursor != '\0') {
        return INPUT_INVALID;
    }
    *move = (Move){values[0], values[1], values[2], values[3]};
    return INPUT_OK;
}

InputStatus input_read_move(FILE *input, Move *move)
{
    char line[MOVE_INPUT_CAPACITY];
    size_t used = 0U;
    bool too_long = false;
    bool embedded_nul = false;
    bool received = false;
    int character;

    /* Consume a whole line even when it is malformed or longer than the buffer. */
    while ((character = fgetc(input)) != EOF) {
        received = true;
        if (character == '\n') {
            break;
        }
        if (character == '\0') {
            embedded_nul = true;
        }
        if (used + 1U < sizeof line) {
            line[used++] = (char)character;
        } else {
            too_long = true;
        }
    }
    if (ferror(input)) {
        return INPUT_ERROR;
    }
    if (!received) {
        return INPUT_EOF;
    }
    line[used] = '\0';
    if (too_long) {
        return INPUT_TOO_LONG;
    }
    if (embedded_nul) {
        return INPUT_INVALID;
    }
    return parse_move(line, move);
}

const char *input_status_message(InputStatus status)
{
    switch (status) {
    case INPUT_OK:
        return "Input accepted.";
    case INPUT_EOF:
        return "Input ended.";
    case INPUT_INVALID:
        return "Enter exactly four decimal integers separated by whitespace.";
    case INPUT_TOO_LONG:
        return "Line too long; enter at most 127 characters.";
    case INPUT_ERROR:
        return "Unable to read input.";
    }
    return "Unknown input status.";
}
