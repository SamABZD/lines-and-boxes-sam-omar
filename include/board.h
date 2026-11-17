#ifndef DOTS_BOARD_H
#define DOTS_BOARD_H

#include <stdbool.h>
#include <stdio.h>

#define BOX_ROWS 4
#define BOX_COLS 5
#define DOT_ROWS (BOX_ROWS + 1)
#define DOT_COLS (BOX_COLS + 1)
#define TOTAL_BOXES (BOX_ROWS * BOX_COLS)
#define TOTAL_EDGES (DOT_ROWS * BOX_COLS + BOX_ROWS * DOT_COLS)

typedef enum {
    PLAYER_NONE = 0,
    PLAYER_A = 1,
    PLAYER_B = 2
} Player;

typedef struct {
    int r1;
    int c1;
    int r2;
    int c2;
} Move;

typedef enum {
    MOVE_OK = 0,
    MOVE_OUT_OF_RANGE,
    MOVE_NOT_ADJACENT,
    MOVE_ALREADY_DRAWN,
    MOVE_INVALID_PLAYER,
    MOVE_GAME_OVER
} MoveStatus;

typedef struct {
    bool horizontal[DOT_ROWS][BOX_COLS];
    bool vertical[BOX_ROWS][DOT_COLS];
    Player owners[BOX_ROWS][BOX_COLS];
} Board;

/* Pointer arguments must be non-null and refer to initialized objects. */
void board_init(Board *board);
MoveStatus board_validate_move(const Board *board, Move move);
/* On rejection the board is unchanged and *claimed is zero. */
MoveStatus board_apply_move(Board *board, Move move, Player player,
                            unsigned *claimed);
void board_render(const Board *board, FILE *output);
char player_label(Player player);
const char *move_status_message(MoveStatus status);

#endif
