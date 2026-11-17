#include "board.h"

void board_init(Board *board)
{
    *board = (Board){0};
}

static bool coordinates_in_range(Move move)
{
    return move.r1 >= 0 && move.r1 < DOT_ROWS &&
           move.r2 >= 0 && move.r2 < DOT_ROWS &&
           move.c1 >= 0 && move.c1 < DOT_COLS &&
           move.c2 >= 0 && move.c2 < DOT_COLS;
}

MoveStatus board_validate_move(const Board *board, Move move)
{
    int row;
    int col;
    bool horizontal;
    bool vertical;

    /* Check limits before arithmetic or indexing, including INT_MIN inputs. */
    if (!coordinates_in_range(move)) {
        return MOVE_OUT_OF_RANGE;
    }
    horizontal = move.r1 == move.r2 &&
                 (move.c1 + 1 == move.c2 || move.c2 + 1 == move.c1);
    vertical = move.c1 == move.c2 &&
               (move.r1 + 1 == move.r2 || move.r2 + 1 == move.r1);
    if (!horizontal && !vertical) {
        return MOVE_NOT_ADJACENT;
    }
    row = move.r1 < move.r2 ? move.r1 : move.r2;
    col = move.c1 < move.c2 ? move.c1 : move.c2;
    if ((horizontal && board->horizontal[row][col]) ||
        (vertical && board->vertical[row][col])) {
        return MOVE_ALREADY_DRAWN;
    }
    return MOVE_OK;
}

static unsigned claim_box(Board *board, int row, int col, Player player)
{
    if (board->owners[row][col] != PLAYER_NONE) {
        return 0U;
    }
    if (board->horizontal[row][col] &&
        board->horizontal[row + 1][col] &&
        board->vertical[row][col] &&
        board->vertical[row][col + 1]) {
        board->owners[row][col] = player;
        return 1U;
    }
    return 0U;
}

MoveStatus board_apply_move(Board *board, Move move, Player player,
                            unsigned *claimed)
{
    MoveStatus status;
    int row;
    int col;

    *claimed = 0U;
    if (player != PLAYER_A && player != PLAYER_B) {
        return MOVE_INVALID_PLAYER;
    }
    status = board_validate_move(board, move);
    if (status != MOVE_OK) {
        return status;
    }
    row = move.r1 < move.r2 ? move.r1 : move.r2;
    col = move.c1 < move.c2 ? move.c1 : move.c2;
    if (move.r1 == move.r2) {
        board->horizontal[row][col] = true;
        if (row > 0) {
            *claimed += claim_box(board, row - 1, col, player);
        }
        if (row < BOX_ROWS) {
            *claimed += claim_box(board, row, col, player);
        }
    } else {
        board->vertical[row][col] = true;
        if (col > 0) {
            *claimed += claim_box(board, row, col - 1, player);
        }
        if (col < BOX_COLS) {
            *claimed += claim_box(board, row, col, player);
        }
    }
    return MOVE_OK;
}

char player_label(Player player)
{
    return player == PLAYER_A ? 'A' : player == PLAYER_B ? 'B' : ' ';
}

void board_render(const Board *board, FILE *output)
{
    fputs("    ", output);
    for (int col = 0; col < DOT_COLS; ++col) {
        fprintf(output, "%d   ", col);
    }
    fputc('\n', output);
    for (int row = 0; row < DOT_ROWS; ++row) {
        fprintf(output, "%d   ", row);
        for (int col = 0; col < DOT_COLS; ++col) {
            fputc('.', output);
            if (col < BOX_COLS) {
                fputs(board->horizontal[row][col] ? "---" : "   ", output);
            }
        }
        fputc('\n', output);
        if (row < BOX_ROWS) {
            fputs("    ", output);
            for (int col = 0; col < DOT_COLS; ++col) {
                fputc(board->vertical[row][col] ? '|' : ' ', output);
                if (col < BOX_COLS) {
                    fprintf(output, " %c ", player_label(board->owners[row][col]));
                }
            }
            fputc('\n', output);
        }
    }
}

const char *move_status_message(MoveStatus status)
{
    switch (status) {
    case MOVE_OK:
        return "Move accepted.";
    case MOVE_OUT_OF_RANGE:
        return "Dot rows must be 0..4 and columns must be 0..5.";
    case MOVE_NOT_ADJACENT:
        return "Connect two distinct, horizontally or vertically adjacent dots.";
    case MOVE_ALREADY_DRAWN:
        return "That edge is already drawn.";
    case MOVE_INVALID_PLAYER:
        return "Invalid player.";
    case MOVE_GAME_OVER:
        return "All boxes have already been claimed.";
    }
    return "Unknown move status.";
}
