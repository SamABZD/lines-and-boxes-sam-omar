# Lines and Boxes - Sam and Omar

Private repository: [SamABZD/lines-and-boxes-sam-omar](https://github.com/SamABZD/lines-and-boxes-sam-omar).

Sprint 1, written in portable C11, for a two-player Dots and Boxes game with 4x5 boxes (5x6 dots). The current library implements board rules, safe input, and game-state management.

## Current modules

- `src/board.c` and `include/board.h`: board storage, valid-edge checks, rendering, and awarding completed boxes, including two boxes from one shared edge.
- `src/input.c` and `include/input.h`: safe parsing of four coordinates and recovery after malformed or overlong input.
- `src/game.c` and `include/game.h`: alternating turns, scores, extra turns after captures, move counts, game completion, and winner/draw detection.
- `tests/`: board/input checks plus game-state invariants, single/double captures, rejected turns, and complete games in ordered and shuffled edge sequences.
- `Makefile`: builds the core library and test runner using GNU Make.
- `github-research.md`: references inspected before the original implementation; no source code was copied.

## Build and verify

On Linux or Ubuntu WSL, with a C compiler, GNU Make, and `ar`:

```sh
make
make test
```

The library is `build/core/libdots_core.a`; the test runner is `build/core/test_runner`. The interactive terminal interface will arrive in a later commit.

## Delivery progress

1. Board/input foundations and their tests.
2. Game-state management and its unit tests (this commit).
3. Interactive console interface and application build (pending).
4. Console fixtures and regression checks (pending).
5. GDB/Valgrind verification, debugging notes, and the automatically starting Alpine VM (pending).

The gameplay batch is split into smaller commits that will be added over time. This delivery regroups an existing Sprint 1 implementation. Commit dates record when the batches are actually committed, rather than when the code was originally written. The technical report is excluded throughout.
