set pagination off
set confirm off
break game_play_turn if game->moves_played == 3
run < tests/fixtures/scoring.in
printf "\nGDB: inspect the fourth move before B scores\n"
print move
print *game
set $state = game
watch -l $state->scores[1]
continue
printf "\nGDB: B's score changed at this stack frame\n"
bt
finish
print *$state
if $state->scores[0] != 0 || $state->scores[1] != 1 || $state->current_player != PLAYER_B || $state->claimed_boxes != 1 || $state->moves_played != 4 || $state->board.owners[0][0] != PLAYER_B
    printf "FAIL: unexpected scoring state\n"
    quit 1
end
delete breakpoints
continue
if $_exitcode != 0
    quit 1
end
printf "PASS: GDB verified B's point, box ownership, and retained turn\n"
quit 0
