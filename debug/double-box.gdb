set pagination off
set confirm off
break game_play_turn if game->moves_played == 6
run < tests/fixtures/double-box.in
printf "\nGDB: inspect the shared edge before A claims two boxes\n"
print move
set $state = game
watch -l $state->scores[0]
continue
printf "\nGDB: A's score changed by two\n"
bt
finish
print *$state
if $state->scores[0] != 2 || $state->scores[1] != 0 || $state->current_player != PLAYER_A || $state->claimed_boxes != 2 || $state->moves_played != 7 || $state->board.owners[0][0] != PLAYER_A || $state->board.owners[0][1] != PLAYER_A
    printf "FAIL: unexpected double-box state\n"
    quit 1
end
delete breakpoints
continue
if $_exitcode != 0
    quit 1
end
printf "PASS: GDB verified two owners, two points, and A's retained turn\n"
quit 0
