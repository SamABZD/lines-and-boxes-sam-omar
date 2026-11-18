#include "game.h"

void game_init(Game *game)
{
    *game = (Game){0};
    board_init(&game->board);
    game->current_player = PLAYER_A;
}

bool game_is_over(const Game *game)
{
    return game->claimed_boxes == TOTAL_BOXES;
}

MoveStatus game_play_turn(Game *game, Move move, unsigned *claimed)
{
    MoveStatus status;

    *claimed = 0U;
    if (game_is_over(game)) {
        return MOVE_GAME_OVER;
    }
    status = board_apply_move(&game->board, move, game->current_player, claimed);
    if (status != MOVE_OK) {
        return status;
    }
    ++game->moves_played;
    game->claimed_boxes += *claimed;
    game->scores[(unsigned)game->current_player - 1U] += *claimed;
    if (*claimed == 0U) {
        game->current_player = game->current_player == PLAYER_A ? PLAYER_B : PLAYER_A;
    }
    return MOVE_OK;
}

Player game_winner(const Game *game)
{
    if (!game_is_over(game) || game->scores[0] == game->scores[1]) {
        return PLAYER_NONE;
    }
    return game->scores[0] > game->scores[1] ? PLAYER_A : PLAYER_B;
}
