#include "test.h"

#include <stdint.h>
#include <string.h>

#include "game.h"

static void check_invariants(const Game *game)
{
    unsigned edges = 0U;
    unsigned owners[2] = {0U, 0U};

    for (int row = 0; row < DOT_ROWS; ++row) {
        for (int col = 0; col < BOX_COLS; ++col) {
            edges += game->board.horizontal[row][col] ? 1U : 0U;
        }
    }
    for (int row = 0; row < BOX_ROWS; ++row) {
        for (int col = 0; col < DOT_COLS; ++col) {
            edges += game->board.vertical[row][col] ? 1U : 0U;
        }
    }
    for (int row = 0; row < BOX_ROWS; ++row) {
        for (int col = 0; col < BOX_COLS; ++col) {
            Player owner = game->board.owners[row][col];
            bool complete = game->board.horizontal[row][col] &&
                            game->board.horizontal[row + 1][col] &&
                            game->board.vertical[row][col] &&
                            game->board.vertical[row][col + 1];
            CHECK(owner == PLAYER_NONE || owner == PLAYER_A || owner == PLAYER_B);
            CHECK((owner != PLAYER_NONE) == complete);
            if (owner != PLAYER_NONE) {
                ++owners[(unsigned)owner - 1U];
            }
        }
    }
    CHECK(edges == game->moves_played);
    CHECK(edges <= TOTAL_EDGES);
    CHECK(owners[0] == game->scores[0]);
    CHECK(owners[1] == game->scores[1]);
    CHECK(owners[0] + owners[1] == game->claimed_boxes);
    CHECK(game->claimed_boxes <= TOTAL_BOXES);
    CHECK(game->current_player == PLAYER_A || game->current_player == PLAYER_B);
    CHECK(game_is_over(game) == (edges == TOTAL_EDGES));
}

static void enumerate_edges(Move edges[TOTAL_EDGES])
{
    unsigned count = 0U;

    for (int row = 0; row < DOT_ROWS; ++row) {
        for (int col = 0; col < BOX_COLS; ++col) {
            edges[count++] = (Move){row, col, row, col + 1};
        }
    }
    for (int row = 0; row < BOX_ROWS; ++row) {
        for (int col = 0; col < DOT_COLS; ++col) {
            edges[count++] = (Move){row, col, row + 1, col};
        }
    }
    CHECK(count == TOTAL_EDGES);
}

static void play_complete_game(uint32_t seed, Player *winner)
{
    Move edges[TOTAL_EDGES];
    Game game;
    bool ordered = seed == 0U;

    enumerate_edges(edges);
    if (seed != 0U) {
        for (unsigned i = TOTAL_EDGES - 1U; i > 0U; --i) {
            unsigned j;
            Move temporary;
            seed = seed * UINT32_C(1664525) + UINT32_C(1013904223);
            j = seed % (i + 1U);
            temporary = edges[i];
            edges[i] = edges[j];
            edges[j] = temporary;
        }
    }
    game_init(&game);
    check_invariants(&game);
    for (unsigned i = 0U; i < TOTAL_EDGES; ++i) {
        unsigned claimed;
        unsigned ignored;
        Game before;
        Player active = game.current_player;

        CHECK(game_play_turn(&game, edges[i], &claimed) == MOVE_OK);
        CHECK(claimed <= 2U);
        CHECK(game.current_player == (claimed > 0U ? active :
              active == PLAYER_A ? PLAYER_B : PLAYER_A));
        check_invariants(&game);
        memcpy(&before, &game, sizeof before);
        CHECK(game_play_turn(&game, edges[i], &ignored) ==
              (game_is_over(&game) ? MOVE_GAME_OVER : MOVE_ALREADY_DRAWN));
        CHECK(ignored == 0U);
        CHECK(memcmp(&before, &game, sizeof game) == 0);
    }
    CHECK(game.claimed_boxes == TOTAL_BOXES);
    CHECK(game.scores[0] + game.scores[1] == TOTAL_BOXES);
    if (ordered) {
        CHECK(game.scores[0] == 10U && game.scores[1] == 10U);
        CHECK(game_winner(&game) == PLAYER_NONE);
    }
    *winner = game_winner(&game);
    game_init(&game);
    check_invariants(&game);
    CHECK(game.current_player == PLAYER_A);
    CHECK(game.moves_played == 0U);
}

void test_game(void)
{
    Game game;
    Game before;
    unsigned claimed;
    Player winner;
    bool saw_a = false;
    bool saw_b = false;
    const Move one_box[] = {
        {0, 0, 0, 1}, {0, 0, 1, 0}, {1, 0, 1, 1}, {0, 1, 1, 1}
    };
    const Move two_boxes[] = {
        {0, 0, 0, 1}, {0, 1, 0, 2}, {1, 0, 1, 1}, {1, 1, 1, 2},
        {0, 0, 1, 0}, {0, 2, 1, 2}, {0, 1, 1, 1}
    };

    game_init(&game);
    CHECK(game_winner(&game) == PLAYER_NONE);
    check_invariants(&game);
    memcpy(&before, &game, sizeof before);
    CHECK(game_play_turn(&game, (Move){0, 0, 1, 1}, &claimed) == MOVE_NOT_ADJACENT);
    CHECK(memcmp(&before, &game, sizeof game) == 0);
    for (size_t i = 0U; i < sizeof one_box / sizeof one_box[0]; ++i) {
        CHECK(game_play_turn(&game, one_box[i], &claimed) == MOVE_OK);
    }
    CHECK(claimed == 1U);
    CHECK(game.scores[0] == 0U && game.scores[1] == 1U);
    CHECK(game.current_player == PLAYER_B);
    CHECK(game.board.owners[0][0] == PLAYER_B);
    check_invariants(&game);

    game_init(&game);
    for (size_t i = 0U; i < sizeof two_boxes / sizeof two_boxes[0]; ++i) {
        CHECK(game_play_turn(&game, two_boxes[i], &claimed) == MOVE_OK);
    }
    CHECK(claimed == 2U);
    CHECK(game.scores[0] == 2U && game.scores[1] == 0U);
    CHECK(game.current_player == PLAYER_A);
    check_invariants(&game);
    play_complete_game(0U, &winner);
    CHECK(winner == PLAYER_NONE);
    for (uint32_t seed = 1U; seed <= 100U; ++seed) {
        play_complete_game(seed, &winner);
        saw_a = saw_a || winner == PLAYER_A;
        saw_b = saw_b || winner == PLAYER_B;
    }
    CHECK(saw_a && saw_b);
}
