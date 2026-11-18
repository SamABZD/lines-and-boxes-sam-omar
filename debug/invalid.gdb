set pagination off
set confirm off
break board_apply_move if move.r1 == 0 && move.c1 == 1 && move.r2 == 0 && move.c2 == 0
run < tests/fixtures/invalid.in
printf "\nGDB: inspect a reversed duplicate before rejection\n"
print move
print board->horizontal[0][0]
finish
printf "\nGDB: board_apply_move returned MOVE_ALREADY_DRAWN\n"
if $ != MOVE_ALREADY_DRAWN
    quit 1
end
bt
set $state = game
finish
print *$state
if $state->scores[0] != 0 || $state->scores[1] != 0 || $state->current_player != PLAYER_B || $state->moves_played != 1 || $state->claimed_boxes != 0 || $state->board.horizontal[0][0] != 1
    printf "FAIL: rejected move mutated game state\n"
    quit 1
end
delete breakpoints
continue
if $_exitcode != 0
    quit 1
end
printf "PASS: GDB verified duplicate rejection without a lost turn\n"
quit 0
