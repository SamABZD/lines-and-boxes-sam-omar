#include <stdio.h>
#include <stdlib.h>

#include "game.h"
#include "input.h"

static void display_game(const Game *game)
{
    board_render(&game->board, stdout);
    printf("Scores: A=%u B=%u | Claimed: %u/%d | Moves: %u/%d\n\n",
           game->scores[0], game->scores[1], game->claimed_boxes,
           TOTAL_BOXES, game->moves_played, TOTAL_EDGES);
}

int main(void)
{
    Game game;

    game_init(&game);
    puts("DOTS AND BOXES - two players, 4x5 boxes");
    puts("Enter r1 c1 r2 c2 to join adjacent dots (rows 0..4, columns 0..5).");
    puts("Complete a box to score and play again. EOF exits the game.\n");
    display_game(&game);
    while (!game_is_over(&game)) {
        Move move;
        unsigned claimed;
        Player player = game.current_player;
        InputStatus input_status;
        MoveStatus move_status;

        printf("Player %c: enter r1 c1 r2 c2 > ", player_label(player));
        if (fflush(stdout) == EOF) {
            fputs("Unable to write output.\n", stderr);
            return EXIT_FAILURE;
        }
        input_status = input_read_move(stdin, &move);
        if (input_status == INPUT_EOF) {
            puts("\nInput ended. Game stopped before completion.");
            return EXIT_SUCCESS;
        }
        if (input_status == INPUT_ERROR) {
            fprintf(stderr, "\n%s\n", input_status_message(input_status));
            return EXIT_FAILURE;
        }
        if (input_status != INPUT_OK) {
            printf("Invalid input: %s Same player's turn.\n",
                   input_status_message(input_status));
            continue;
        }
        move_status = game_play_turn(&game, move, &claimed);
        if (move_status != MOVE_OK) {
            printf("Invalid move: %s Same player's turn.\n",
                   move_status_message(move_status));
            continue;
        }
        if (claimed != 0U) {
            printf("Player %c claimed %u box%s.\n", player_label(player), claimed,
                   claimed == 1U ? "" : "es");
            if (!game_is_over(&game)) {
                printf("Player %c plays again.\n", player_label(player));
            }
        }
        display_game(&game);
    }
    printf("Final score: A=%u B=%u\n", game.scores[0], game.scores[1]);
    if (game_winner(&game) == PLAYER_NONE) {
        puts("It's a draw!");
    } else {
        printf("Player %c wins!\n", player_label(game_winner(&game)));
    }
    return ferror(stdout) ? EXIT_FAILURE : EXIT_SUCCESS;
}
