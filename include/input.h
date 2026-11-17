#ifndef DOTS_INPUT_H
#define DOTS_INPUT_H

#include <stdio.h>

#include "board.h"

#define MOVE_INPUT_CAPACITY 128U

typedef enum {
    INPUT_OK = 0,
    INPUT_EOF,
    INPUT_INVALID,
    INPUT_TOO_LONG,
    INPUT_ERROR
} InputStatus;

/* On failure *move is unchanged. All pointer arguments must be non-null. */
InputStatus parse_move(const char *line, Move *move);
InputStatus input_read_move(FILE *input, Move *move);
const char *input_status_message(InputStatus status);

#endif
