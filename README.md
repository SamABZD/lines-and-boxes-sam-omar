# Lines and Boxes

Sam and Omar, Sprint 1.

This is a two-player terminal game written in C. The board has 4 rows and 5 columns of boxes.

## Build and play

Run these commands from the project folder on Linux with a C compiler and GNU Make.

```sh
make
./dotsboxes
```

Enter two neighboring dots as `row1 col1 row2 col2`. Rows go from 0 to 4 and columns from 0 to 5. For example, `0 0 0 1` draws the top-left horizontal line.

Each completed box is worth one point and gives the player another turn. One line can close two boxes. Invalid moves do not cost a turn. The game ends when all 20 boxes are taken.

## Tests

```sh
make test
make gdb
make valgrind
```

The checks and results are in the [debugging notes](debugging-strategy.md). The source and VM image are in the [Sprint 1 download](https://github.com/SamABZD/lines-and-boxes-sam-omar/releases/latest).

The [screenshots](evidence/screenshots/README.md) show startup, gameplay, and the test results.
