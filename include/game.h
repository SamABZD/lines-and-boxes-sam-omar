#ifndef DOTS_GAME_H
#define DOTS_GAME_H

#include "board.h"

typedef struct {
    Board board;
    unsigned scores[2];
    Player current_player;
    unsigned moves_played;
    unsigned claimed_boxes;
} Game;

void game_init(Game *game);
/* A rejected turn leaves the entire game unchanged and sets *claimed to zero. */
MoveStatus game_play_turn(Game *game, Move move, unsigned *claimed);
bool game_is_over(const Game *game);
/* PLAYER_NONE denotes either an unfinished game or a completed draw. */
Player game_winner(const Game *game);

#endif
