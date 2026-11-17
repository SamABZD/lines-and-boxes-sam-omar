# GitHub research - Sprint 1, C only

Research date: 14 November 2026. Research preceded the original implementation and Makefile. Repository pages, recursive GitHub API file listings, and selected source files were inspected. None of these projects was cloned, built, executed, or incorporated into a game implementation.

## Comparison

| Repository | Relevant finding | Sprint 1 decision |
| --- | --- | --- |
| [RF-01/Dots-and-Boxes-Game](https://github.com/RF-01/Dots-and-Boxes-Game) | C console game with the exact 4x5 box dimensions and four-coordinate moves. The documented build compiles a single main source. | Closest behavior reference; design a separate modular implementation. |
| [ziadhishamali/Dots-and-Boxes](https://github.com/ziadhishamali/Dots-and-Boxes) | Multiple `.c`/`.h` files. `main.c` includes `windows.h` and calls `system("cls")`; documented board sizes differ. | Useful organization reference; unsuitable unchanged for Alpine. |
| [AbdelrahmanElmeniawy/Dots-and-Boxes](https://github.com/AbdelrahmanElmeniawy/Dots-and-Boxes) | `main.c` includes `windows.h` and `colors.h`. Root listing includes Code::Blocks artifacts and headers. | Lower priority because of console portability work and different organization. |
| [MbfcM/Dots-and-Boxes](https://github.com/MbfcM/Dots-and-Boxes) | Single `DotsAndBoxes.c`; includes `conio.c` and invokes Windows console commands. | Lower priority; does not supply the required portable multi-source structure. |

These are reference candidates, not verified working submissions. Source inspection supports the portability findings; no runtime correctness claims are made.

## Sources and reproducibility

The checked source files were:

- [RF-01 main.c](https://github.com/RF-01/Dots-and-Boxes-Game/blob/main/main.c): dimensions, board arrays, game functions.
- [ziadhishamali main.c](https://github.com/ziadhishamali/Dots-and-Boxes/blob/master/main.c): includes and console calls.
- [AbdelrahmanElmeniawy main.c](https://github.com/AbdelrahmanElmeniawy/Dots-and-Boxes/blob/master/main.c): includes and console calls.
- [MbfcM DotsAndBoxes.c](https://github.com/MbfcM/Dots-and-Boxes/blob/master/DotsAndBoxes.c): includes and console calls.

GitHub API recursive tree snapshots at inspection time:

| Repository | Default branch | Root tree SHA (not a commit SHA) |
| --- | --- | --- |
| RF-01/Dots-and-Boxes-Game | main | `082b291107bc13a080dddc8a9a941b162078fe29` |
| ziadhishamali/Dots-and-Boxes | master | `8141e3525cc3947b82abc21ca3fec105cc056cab` |
| AbdelrahmanElmeniawy/Dots-and-Boxes | master | `2dd3d54481d9f641c7ca5a041be84ad8708228f4` |
| MbfcM/Dots-and-Boxes | master | `5aa5636c0e33d70eb254bb4e322225f1eda4d22a` |

GitHub did not identify a license in API metadata for these four repositories. RF-01's README says MIT, but the inspected tree has no standalone license file. No code reuse is proposed or performed in this package.

## Recommended direction

Write original, portable C11 when implementation is authorized. Use standard terminal output, fixed board arrays, independent input parsing, and separate board/game/input modules. Avoid Windows APIs, external console libraries, stored executable files, and additional gameplay features outside Sprint 1.

The modular design is an engineering decision for this project, not a claim about the internals or performance of these repositories.
