# Debugging and testing

Run these commands from the project folder on Linux with GDB and Valgrind installed.

```sh
make test
make gdb-check
make memcheck
make sanitize
```

- The unit tests check input, board boundaries, scoring, and turn changes. The terminal tests replay seven cases, including both winners, a draw, and invalid moves.
- In GDB, break before the move that finishes a box and watch the player's score. The scripts in `debug/` check one box, two boxes, and a repeated move. A repeated move must leave the board, scores, and turn unchanged.
- Valgrind checks the unit tests and all seven terminal cases for memory errors and leaks. For a single case, run `make valgrind INPUT=tests/fixtures/scoring.in`.

All seven terminal cases and all three GDB checks passed. Valgrind reported zero errors and no leaks. AddressSanitizer and UndefinedBehaviorSanitizer also passed. See the [test output](evidence/current-verification.txt) and the logs in `evidence/`. Running the checks again writes new logs to `build/logs/`.

Two issues came up in the tests. Windows line endings caused a score comparison to fail, so the fixtures use LF. A GDB watchpoint also fired after the game state had gone out of scope, so the scripts remove their watchpoints before the program exits.
