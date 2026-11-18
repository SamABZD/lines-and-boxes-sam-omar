# Lines and Boxes - Sam and Omar

Private repository: [SamABZD/lines-and-boxes-sam-omar](https://github.com/SamABZD/lines-and-boxes-sam-omar).

Sprint 1 console game, written in portable C11, for two local players on a board of 4x5 boxes (5x6 dots). Completing a box earns a point and another turn. A shared edge can complete two boxes. The game ends when all 20 boxes are claimed and declares the winner or a draw.

## Current modules

- `src/board.c` and `include/board.h`: board storage, valid-edge checks, rendering, and awarding completed boxes, including two boxes from one shared edge.
- `src/input.c` and `include/input.h`: safe parsing of four coordinates and recovery after malformed or overlong input.
- `src/game.c` and `include/game.h`: alternating turns, scores, extra turns after captures, move counts, game completion, and winner/draw detection.
- `src/main.c`: terminal prompts, board/score display, input errors, the game loop, and final results.
- `tests/`: board/input and game-state unit checks, plus console fixtures and regression checks in `tests/cli.sh`.
- `Makefile`: builds the console game and unit-test runner using GNU Make.
- `github-research.md`: references inspected before the original implementation; no source code was copied.

## Build and verify

On Linux or Ubuntu WSL, with a C compiler and GNU Make:

```sh
make
./build/release/dots_and_boxes
make test
```

Enter four decimal integers: `r1 c1 r2 c2`. Dot rows are 0..4 and columns are 0..5. For example, `0 0 0 1` draws the upper-left horizontal edge. Reversed endpoints identify the same edge. Invalid input leaves the current player's turn unchanged. Ctrl+D at an empty prompt exits cleanly.

`make test` runs the unit suite in `build/debug/test_runner` and seven console scenarios covering captures, invalid moves, wins, draws, and EOF. `make debug`, `make sanitize`, and `make static` select debugger-friendly, ASan/UBSan, and static builds. Build modes use separate directories. Run `make clean` before changing compiler flags within an existing mode; it removes `build/`.

## Delivery progress

1. Board/input foundations and their tests.
2. Game-state management and its unit tests.
3. Interactive console interface and application build.
4. Console fixtures and regression checks (this commit).
5. GDB/Valgrind verification, debugging notes, and the automatically starting Alpine VM (pending).

The gameplay batch is split into smaller commits that will be added over time. This delivery regroups an existing Sprint 1 implementation. Commit dates record when the batches are actually committed, rather than when the code was originally written. The technical report is excluded throughout.
