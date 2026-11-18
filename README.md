# Lines and Boxes - Sam and Omar

Repository: [SamABZD/lines-and-boxes-sam-omar](https://github.com/SamABZD/lines-and-boxes-sam-omar) (private).

Original C11 console game for two local players on a 4x5 board of boxes. A completed box earns a point and another turn. A shared edge can complete two boxes. The game ends after all 20 boxes are claimed and announces A, B, or a draw.

Only Sprint 1 is implemented. This repository regroups an existing implementation into meaningful increments: board/input foundations; game-state rules and tests; the interactive console interface; console regression tests; and debugger/memory verification plus Alpine VM startup. The implementation and its original verification existed before this regrouping. GitHub research preceded the original implementation. Commit timestamps record when each increment is actually committed.

## Build and play

On Linux or Ubuntu WSL, from the project root:

```sh
make
./build/release/dots_and_boxes
```

Requires a C compiler and GNU Make. Enter four decimal integers: `r1 c1 r2 c2`. Dot rows are 0..4 and columns are 0..5. For example, `0 0 0 1` draws the upper-left horizontal connection. Reversed endpoints identify the same edge. Invalid input preserves the current turn. Ctrl+D at an empty prompt exits cleanly.

Application source: `src/main.c`, `src/board.c`, `src/game.c`, `src/input.c`; public headers are in `include/`. The game uses standard C facilities and no graphical library.

## Verify and debug

```sh
make test
make gdb-check
make memcheck
make sanitize
```

Install GDB and Valgrind before the relevant checks. Use `make gdb` for an interactive debugger. For one memory-check case:

```sh
make valgrind INPUT=tests/fixtures/scoring.in
```

`make help` lists all targets. Release, debug, sanitizer, and static builds use different directories. If changing compiler/flags for an existing mode, run `make clean` before rebuilding. `make clean` removes all of `build/`, including generated VM images; keep a copy of the supplied archive if needed.

Verified: 278,162 assertions, seven console scenarios, three GDB state checks, and Valgrind unit/game runs with zero reported errors and all heap allocations freed. ASan/UBSan checks pass. See `debugging-strategy.md` and `evidence/` for actual commands and results.

## Start the Alpine VM

Sprint 1 asks for a small Linux VM that starts the game automatically without a desktop or login prompt. Alpine is the Linux distribution used for this requirement; QEMU runs the virtual machine.

[Download the complete Sprint 1 ZIP](https://github.com/SamABZD/lines-and-boxes-sam-omar/releases/download/sprint-1/LinesAndBoxes_Sam_Omar_Sprint1.zip), extract it, and open its project folder. The ZIP includes `build/vm/vmlinuz-virt` and `build/vm/initramfs.cpio.gz`. With QEMU installed on Linux/WSL:

```sh
sh vm/run.sh
```

QEMU boots Alpine 3.24.4 directly into the game without a login prompt. Press Ctrl+A, then X to exit QEMU. The VM has 128 MiB RAM, one emulated x86_64 CPU, no network, and no disk. A completed or exited game restarts automatically. Each VM boot starts a fresh board. The game also starts on the VGA console.

To recreate the image from pinned official Alpine assets, install `cpio`, `gzip`, `tar`, a static-capable C toolchain, and curl or wget, then run as root:

```sh
sudo sh vm/build-image.sh
```

The script changes only its temporary root filesystem and build outputs. See `alpine-vm-plan.md` for the architecture, verification, and optional conventional installation approach.

## Supporting files

- `github-research.md`: repositories inspected before the original implementation; no code was copied.
- `debugging-strategy.md`: reproducible debugging strategy and results.
- `evidence/`: original unit/console results, GDB logs, Valgrind logs, VM boot/play logs, and a genuine QEMU screenshot.
- `vm/`: scripts, startup configuration, and pinned sources for the bootable Alpine VM.

The technical report is intentionally excluded. Generated VM images are supplied in the GitHub release ZIP; their build scripts and pinned checksums are tracked in this repository. Historical verification logs retain their original dates, paths, and baseline identifiers. Fresh verification is in `evidence/current-verification.txt` and `evidence/alpine-current-boot.log`.
