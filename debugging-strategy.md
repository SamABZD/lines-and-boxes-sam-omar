# Sprint 1 debugging strategy and results

Verification date: 14 November 2026. Environment: Ubuntu 24.04.5 LTS under WSL, GCC 13.3.0, GNU Make 4.3, GDB 15.1, Valgrind 3.22.0. Actual game and test binaries were run. The Alpine VM was also booted and played; VM evidence is separate from the WSL debugging evidence.

The complete delivery was rechecked on 18 November 2026. See `evidence/current-verification.txt` for the fresh GDB, Valgrind, and sanitizer commands and exit statuses, and `evidence/alpine-current-boot.log` for the new cold-boot/full-game check. Older build and verification notes remain as historical evidence.

## Reproduce the checks

From the project root, with the required tools installed:

```sh
make test
make gdb-check
make memcheck
make sanitize
```

The debug build uses C11, strict warnings, `-O0`, `-g3`, and frame pointers. ASan/UBSan binaries are built and run separately from Valgrind. Record the source commit, tool versions, input fixture, expected state, actual state, and exit status with every investigation. For an existing build, clean first if changing compiler or flags.

## State invariants and cases

The unit suite checks input parsing and line recovery, initialization, every legal edge in both directions, boundary coordinates, extreme integers, duplicates, invalid-player rejection, single-box scoring, two-box captures in both orientations, turn transitions, and final states. It plays one ordered and 100 deterministically shuffled complete games. After each accepted edge it independently counts drawn edges and owners, checks complete-box ownership, and verifies scores/counters. Repeating the move must leave the game unchanged.

The seven console fixtures are `scoring`, `double-box`, `invalid`, `full-game`, `a-win`, `b-win`, and `empty`. The shell runner checks real program output, ownership rendering, invalid-input counts, winner messages, and the expected 50 board/score displays in a full game (initial display plus 49 moves).

Expected complete-game results:

| Fixture | Expected and observed result |
| --- | --- |
| full-game.in | A=10, B=10; draw |
| a-win.in | A=19, B=1; A wins |
| b-win.in | A=1, B=19; B wins |

## GDB: inspect live state, not just process startup

`make gdb-check` replays three checked-in command scripts and writes `evidence/gdb-*.log`. Each session uses a conditional breakpoint, inspects the relevant move/state, and asserts the expected result before allowing normal exit.

| Script | Inspection and verified result |
| --- | --- |
| debug/scoring.gdb | Break before move four; watch B's score change 0 to 1; inspect owner B and retained turn |
| debug/double-box.gdb | Break before move seven; watch A's score change 0 to 2; inspect both owners and retained turn |
| debug/invalid.gdb | Break on the reversed duplicate; inspect MOVE_ALREADY_DRAWN; verify one drawn edge, zero scores, and B still to move |

To investigate interactively:

```sh
make gdb
```

```text
break game_play_turn
run < tests/fixtures/scoring.in
info args
print *game
watch -l game->scores[1]
continue
bt
finish
```

Only watch a state object while it is alive. Delete watchpoints before leaving the object's lifetime. For crashes, retain `bt full` and `info locals`; for incorrect state, stop at the first divergence and replay the same fixture after a fix. See the [GDB breakpoint/watchpoint manual](https://sourceware.org/gdb/current/onlinedocs/gdb.html/Breakpoints.html).

## Valgrind: normal completion, rejection, and EOF

`make memcheck` runs the unit test binary and all seven console fixtures under Memcheck. Each game has a separate log and stdout transcript in `evidence/`. Required options are:

```text
--tool=memcheck --leak-check=full --show-leak-kinds=all
--errors-for-leak-kinds=all --track-origins=yes --error-exitcode=99
```

The actual logs report zero errors and all heap blocks freed. No suppressions were added. The game itself has no explicit heap allocation; standard I/O still allocates buffers, which are checked and released at exit. Individual replay is available with `make valgrind INPUT=tests/fixtures/invalid.in`.

A clean Memcheck result does not prove game-rule correctness or detect every within-object stack/static overrun. The invariant suite, exhaustive edge-bound checks, and separate ASan/UBSan runs provide additional coverage. Guidance: [Valgrind Quick Start](https://valgrind.org/docs/manual/quick-start.html), [Memcheck options](https://valgrind.org/docs/manual/mc-manual.html#mc-manual.options).

## Results and actual corrections

| Check | Observed result |
| --- | --- |
| Unit/invariant suite | PASS: 278,162 assertions |
| Console suite | PASS: seven scenarios |
| GDB sessions | PASS: all three checked states; normal exit |
| Valgrind unit suite and seven game cases | Zero reported errors; all heap blocks freed |
| AddressSanitizer/UndefinedBehaviorSanitizer | Unit and console suites pass |
| Alpine VM | Two cold boots; no login prompt; valid/invalid input, scoring, complete game, and restart verified |

Two verification issues were corrected: CRLF in generated expectation files, and a GDB watchpoint left active after the watched stack object's lifetime. Text files now use LF, and debugger scripts delete breakpoints/watchpoints before process exit. The first GDB log is retained alongside the successful rerun. See `evidence/debugging-notes.md`.

No C game logic or memory defect was observed in these runs. No invented defect or unexecuted passing result is included in these notes. For a future real defect, record symptom, evidence, root cause, change, regression result, and the fixing commit.
