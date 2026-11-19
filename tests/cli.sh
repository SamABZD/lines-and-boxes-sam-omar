#!/bin/sh
set -eu

game=${1:-./dotsboxes}
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT HUP INT TERM

expect() {
    if ! grep -Fq "$1" "$2"; then
        printf 'Missing expected output: %s\n' "$1" >&2
        cat "$2" >&2
        exit 1
    fi
}

for name in scoring double-box invalid full-game a-win b-win empty; do
    "$game" < "tests/fixtures/$name.in" > "$temporary/$name.out"
done

expect 'Scores: A=0 B=1 | Claimed: 1/20 | Moves: 4/49' "$temporary/scoring.out"
expect 'Player B plays again.' "$temporary/scoring.out"
expect '| B |' "$temporary/scoring.out"
expect 'Scores: A=2 B=0 | Claimed: 2/20 | Moves: 7/49' "$temporary/double-box.out"
expect 'Player A claimed 2 boxes.' "$temporary/double-box.out"
expect 'Player A plays again.' "$temporary/double-box.out"
expect 'Scores: A=0 B=0 | Claimed: 0/20 | Moves: 1/49' "$temporary/invalid.out"
expect 'That edge is already drawn.' "$temporary/invalid.out"
test "$(grep -c 'Invalid input:' "$temporary/invalid.out")" -eq 4
test "$(grep -c 'Invalid move:' "$temporary/invalid.out")" -eq 7
expect 'Final score: A=10 B=10' "$temporary/full-game.out"
expect "It's a draw!" "$temporary/full-game.out"
expect "$(cat tests/fixtures/a-win.expected)" "$temporary/a-win.out"
expect 'Player A wins!' "$temporary/a-win.out"
expect "$(cat tests/fixtures/b-win.expected)" "$temporary/b-win.out"
expect 'Player B wins!' "$temporary/b-win.out"
expect 'Input ended. Game stopped before completion.' "$temporary/empty.out"
if grep -Fq 'Final score:' "$temporary/empty.out"; then
    printf 'EOF must not declare a completed game.\n' >&2
    exit 1
fi
test "$(grep -c 'Scores:' "$temporary/full-game.out")" -eq 50
printf 'PASS: 7 console scenarios\n'
