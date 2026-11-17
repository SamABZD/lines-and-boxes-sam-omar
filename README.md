# Lines and Boxes - Sam and Omar

Private repository: [SamABZD/lines-and-boxes-sam-omar](https://github.com/SamABZD/lines-and-boxes-sam-omar).

Sprint 1, written in portable C11. This first batch contains the foundation for a two-player Dots and Boxes game with 4x5 boxes (5x6 dots).

## Current batch

- `src/board.c` and `include/board.h`: board storage, valid-edge checks, rendering, and awarding completed boxes, including two boxes from one shared edge.
- `src/input.c` and `include/input.h`: safe parsing of four coordinates and recovery after malformed or overlong input.
- `tests/`: regression tests for board rules, input parsing, and unchanged state after rejected input.
- `Makefile`: builds the core library and test runner using GNU Make.
- `github-research.md`: references inspected before the original implementation; no source code was copied.

## Build and verify

On Linux or Ubuntu WSL, with a C compiler, GNU Make, and `ar`:

```sh
make
make test
```

The library is `build/core/libdots_core.a`; the test runner is `build/core/test_runner`. The interactive game will arrive in batch 2.

## Three-commit delivery

1. Board/input foundations and their tests (this commit).
2. Two-player console gameplay, scoring/extra turns, and complete-game tests.
3. GDB/Valgrind verification, debugging notes, and the automatically starting Alpine VM.

This delivery regroups an existing Sprint 1 implementation. The dates of these three commits record when the batches are actually committed, rather than when the code was originally written. The technical report is excluded from all three batches.
