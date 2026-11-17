#include "test.h"

#include <limits.h>
#include <string.h>

#include "board.h"

static unsigned apply(Board *board, Move move, Player player)
{
    unsigned claimed = 99U;
    CHECK(board_apply_move(board, move, player, &claimed) == MOVE_OK);
    return claimed;
}

static void test_all_edges(void)
{
    Board board;
    unsigned claimed_total = 0U;

    board_init(&board);
    for (int row = 0; row < DOT_ROWS; ++row) {
        for (int col = 0; col < BOX_COLS; ++col) {
            Move forward = {row, col, row, col + 1};
            Move reverse = {row, col + 1, row, col};
            CHECK(board_validate_move(&board, forward) == MOVE_OK);
            CHECK(board_validate_move(&board, reverse) == MOVE_OK);
            CHECK(apply(&board, reverse, PLAYER_A) == 0U);
            CHECK(board.horizontal[row][col]);
            CHECK(board_validate_move(&board, forward) == MOVE_ALREADY_DRAWN);
        }
    }
    for (int row = 0; row < BOX_ROWS; ++row) {
        for (int col = 0; col < DOT_COLS; ++col) {
            Move forward = {row, col, row + 1, col};
            Move reverse = {row + 1, col, row, col};
            CHECK(board_validate_move(&board, forward) == MOVE_OK);
            CHECK(board_validate_move(&board, reverse) == MOVE_OK);
            claimed_total += apply(&board, reverse, PLAYER_B);
            CHECK(board.vertical[row][col]);
            CHECK(board_validate_move(&board, forward) == MOVE_ALREADY_DRAWN);
        }
    }
    CHECK(claimed_total == TOTAL_BOXES);
    for (int row = 0; row < BOX_ROWS; ++row) {
        for (int col = 0; col < BOX_COLS; ++col) {
            CHECK(board.owners[row][col] == PLAYER_B);
        }
    }
}

static void test_double_boxes(void)
{
    Board board;
    /* Two horizontally adjacent boxes, sharing a vertical edge. */
    const Move vertical_case[] = {
        {0, 0, 0, 1}, {0, 1, 0, 2}, {1, 0, 1, 1},
        {1, 1, 1, 2}, {0, 0, 1, 0}, {0, 2, 1, 2}
    };
    /* Two vertically adjacent boxes, sharing a horizontal edge. */
    const Move horizontal_case[] = {
        {0, 0, 0, 1}, {2, 0, 2, 1}, {0, 0, 1, 0},
        {1, 0, 2, 0}, {0, 1, 1, 1}, {1, 1, 2, 1}
    };

    board_init(&board);
    for (size_t i = 0U; i < sizeof vertical_case / sizeof vertical_case[0]; ++i) {
        CHECK(apply(&board, vertical_case[i], PLAYER_A) == 0U);
    }
    CHECK(apply(&board, (Move){0, 1, 1, 1}, PLAYER_B) == 2U);
    CHECK(board.owners[0][0] == PLAYER_B);
    CHECK(board.owners[0][1] == PLAYER_B);
    board_init(&board);
    for (size_t i = 0U; i < sizeof horizontal_case / sizeof horizontal_case[0]; ++i) {
        CHECK(apply(&board, horizontal_case[i], PLAYER_A) == 0U);
    }
    CHECK(apply(&board, (Move){1, 0, 1, 1}, PLAYER_A) == 2U);
    CHECK(board.owners[0][0] == PLAYER_A);
    CHECK(board.owners[1][0] == PLAYER_A);
}

void test_board(void)
{
    Board board;
    Board before;
    unsigned claimed;
    const Move invalid[] = {
        {-1, 0, 0, 0}, {DOT_ROWS, 0, DOT_ROWS - 1, 0},
        {0, DOT_COLS, 0, DOT_COLS - 1}, {0, 0, 1, 1},
        {0, 0, 0, 2}, {0, 0, 0, 0},
        {INT_MIN, INT_MAX, INT_MAX, INT_MIN}
    };

    board_init(&board);
    CHECK(player_label(PLAYER_A) == 'A');
    CHECK(player_label(PLAYER_B) == 'B');
    CHECK(player_label(PLAYER_NONE) == ' ');
    for (size_t i = 0U; i < sizeof invalid / sizeof invalid[0]; ++i) {
        memcpy(&before, &board, sizeof before);
        claimed = 99U;
        CHECK(board_apply_move(&board, invalid[i], PLAYER_A, &claimed) != MOVE_OK);
        CHECK(claimed == 0U);
        CHECK(memcmp(&before, &board, sizeof board) == 0);
    }
    CHECK(board_apply_move(&board, (Move){0, 0, 0, 1}, PLAYER_NONE,
                           &claimed) == MOVE_INVALID_PLAYER);
    CHECK(!board.horizontal[0][0]);
    CHECK(apply(&board, (Move){0, 0, 0, 1}, PLAYER_A) == 0U);
    memcpy(&before, &board, sizeof before);
    CHECK(board_apply_move(&board, (Move){0, 1, 0, 0}, PLAYER_B,
                           &claimed) == MOVE_ALREADY_DRAWN);
    CHECK(claimed == 0U);
    CHECK(memcmp(&before, &board, sizeof board) == 0);
    test_all_edges();
    test_double_boxes();
}
